/***************
 * Mitchell Brown
 * Operating Systems I (CS 344)
 * Assignment 3, smallsh
 ***************/


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <signal.h>


int blockBg = 1; // bool to block/allow background processes


/* Function Prototypes */
void readArgs(char *[], int [], size_t);
int processArgs(char *[], int [], size_t, int);
int executeChild(char *[], int [], size_t);
void printStatus(int, pid_t);
void foregroundMode();
void killProcess();


int main()
{
    int childStatus = 0; // Status of previously returned child process


    /* Much code from the signal handlers was sourced and adapted from the 
       "Examples: Catching & Ignoring Signals" section of the "Signal Handling API" Exploration */
    
    // Declare the two signal handler structures
    struct sigaction handle_SIGSTP = {{0}};
	struct sigaction handle_SIGINT = {{0}};

    // Use ^Z to enter foreground only mode
    // Redirect SIGTSTP to a handler to switch fg and bg modes
    handle_SIGSTP.sa_handler = foregroundMode;
    // Block other catchable signals while switching between modes
    sigfillset(&handle_SIGSTP.sa_mask);
    // No flags to set
    handle_SIGSTP.sa_flags = 0;
    // Install the signal handler to SIGTSTP
    sigaction(SIGTSTP, &handle_SIGSTP, NULL);

    // Prevent ^C from exiting the Shell
    // Redirect SIGINT to a handler to let the user know processes will be terminated
    handle_SIGINT.sa_handler = killProcess;
    // Block other catchable signals
    sigfillset(&handle_SIGINT.sa_mask);
    // No flags to set
    handle_SIGINT.sa_flags = 0;
    // Install the signal handler to SIGINT
    sigaction(SIGINT, &handle_SIGINT, NULL);


    while(1)
    {
        char **argv = malloc(512*sizeof(char*));
        /* argc tracks argv information:
            index 0 == number of arguments
            index 1 == location of input file in argv
            index 2 == location of output file in argv
            index 3 == (bool) if the '&' char was found at the end of argv
        */
        int argc[4] = {0};
        readArgs(argv, argc, 4); // Grab user inputs and place in an array
        childStatus = processArgs(argv, argc, 4, childStatus); // Send argv to execute commands

        /* Free up argv after each input */
        for (int row = 0; row == 512; row++)
        {
            free(argv[row]);
        }
        free(argv);
    }
}


/* Read user arguments, split them into an array */
void readArgs(char *argv[], int argc[], size_t sizeArgc)
{   
    /* Grab input */
    char input[2048];
    printf(": ");
    fgets(input, sizeof input, stdin);
    input[strcspn(input, "\n")] = 0; // Remove the \n from the fgets
    
    if (input[0] == '\0' || input[0] == '#')
    {
        /* Handle blank lines and comments */
        /* Set char 0 to null so the while loop doesn't process comments */
        input[0] = '\0';
    }

    int buffer = 0; // input buffer
    int argvBuffer = 0; // Output buffer (tracks char location in current argv row)
    int ignoreSpace = 1;
    argv[0] = malloc(128*sizeof(char));
    while (input[buffer] != '\0')
    {
        if (ignoreSpace == 1 && argc[0] == 1 && strcmp(argv[0], "echo") == 0)
        {
            // Ignore spaces if writing with echo
            ignoreSpace = 0;
        }
        else if (ignoreSpace == 0 && input[buffer] == ' ' && (input[buffer+1] == '<' || input[buffer+1] == '>'))
        {
            // Stop ignoring spaces if an input/output file is detected 
            ignoreSpace = 1;
        }

        if (ignoreSpace == 1 && input[buffer] == ' ')
        {
            /* Iterate to the next argv row to store the next argument */
            argc[0]++;
            argv[argc[0]] = malloc(128*sizeof(char));
            argvBuffer = 0;
        }
        else if (input[buffer] == '<')
        {
            argc[1] = argc[0]+1; // set input file location to the current argument index
            argv[argc[0]] = NULL;
        }
        else if (input[buffer] == '>')
        {
            argc[2] = argc[0]+1; // set output file location to the current argument index
            argv[argc[0]] = NULL;
        }
        else if (input[buffer] == '&' && input[buffer+1] == '\0')
        {
            argc[3] = 1; // Let the program know the user requested to run in the background
            argc[0]--;
        }
        else
        {
            /* Grab chars from input and store in argv */
            if (input[buffer] == '$' && input[buffer+1] == '$')
            {
                /* $$ Expansion */
                char pid[64];
                sprintf(pid, "%d", getpid());
                int pidBuffer = 0;
                while (pid[pidBuffer] != '\0')
                {
                    argv[argc[0]][argvBuffer] = pid[pidBuffer];
                    pidBuffer++;
                    argvBuffer++;
                }
                buffer++;
            }
            else
            {
                /* Store the char in argv[buffer] */
                argv[argc[0]][argvBuffer] = input[buffer];
            }
            argvBuffer++;
        }
        buffer++;
    }
    argv[argc[0]+1] = NULL;
}


/* Process the arguments and execute commands */
int processArgs(char *argv[], int argc[], size_t sizeArgc, int childStatus)
{    
    if (strcmp(argv[0], "\0") == 0 || argv[0][0] == '#'); // If there is a comment/blank line, do nothing
    else if (strcmp(argv[0], "exit") == 0)
    {
        /* Exit the program */
        exit(0);
    }
    else if (strcmp(argv[0], "cd") == 0)
    {
        /* cd command */
        if (argc[0] == 0)
        {
            /* Go home if no directory is provided */
            chdir(getenv("HOME"));
        }
        else
        {
            /* Change to the requested directory */
            chdir(argv[1]);
        }
    }
    else if (strcmp(argv[0], "status") == 0)
    {
        /* status command */
        printStatus(childStatus, -1);
    }
    else
    {
        /* Execute Other Commands */
        childStatus = executeChild(argv, argc, 4);
    }

    if (blockBg == 1)
    {
        pid_t finPid;
        while ((finPid = waitpid(-1, &childStatus, WNOHANG)) > 0)
        {
            printStatus(childStatus, finPid);
        }
    }


    return childStatus;
}


/* Execute Other Commands */
int executeChild(char *argv[], int argc[], size_t sizeArgc)
{
    /*  Much code from this method was sourced and adapted from:
        1. "Using dup2 for Redirection" section of the "Processes and I/O" Exploration
        2. "Using exec() with fork()" section from the "Process API - Executing a New Program" Exploration */
    
    int childStatus;
	pid_t spawnPid = fork();

	switch(spawnPid){
        case -1:
            perror("fork()\n");
            exit(1);
            break;
        case 0: ;
            /* Input file */
            int sourceFD;
            if (argc[1] > 0)
            {
                // Open source file
                sourceFD = open(argv[argc[1]], O_RDONLY);
                if (sourceFD == -1) { 
                    printf("cannot open %s for input\n", argv[argc[1]]); 
                    exit(1);
                }

                // Redirect stdin to source file
                int result = dup2(sourceFD, 0);
                if (result == -1) { 
                    exit(1);
                }
            }

            /* Output File */
            int targetFD;
            if (argc[2] > 0)
            {
                // Open target file
                targetFD = open(argv[argc[2]], O_WRONLY | O_CREAT, 0777);
                if (targetFD == -1) { 
                    exit(1);
                }
            
                // Redirect stdout to target file
                int result = dup2(targetFD, 1);
                if (result == -1) { 
                    exit(1);
                }
            }
            // In the child process
            fcntl(sourceFD, F_SETFD, FD_CLOEXEC);
            fcntl(targetFD, F_SETFD, FD_CLOEXEC);
            execvp(argv[0], argv);
            
            // Print if there is an error
            perror(argv[0]);
            exit(1);
            break;
        default:
            // In the parent process
            // Wait for child's termination
            if (blockBg == 1 && argc[3] == 1)
            {
                // If the & flag was detected, run the process in the background
                waitpid(spawnPid, &childStatus, WNOHANG);
                printf("background pid is %ld\n", (long)spawnPid);
            }
            else
            {
                waitpid(spawnPid, &childStatus, 0);
            }
        return childStatus;
	}
}


/* Print the exit status of a process */
void printStatus(int childStatus, pid_t bgPid)
{
    if (bgPid != -1)
    {
        // Print if the terminating process was running in the background
        printf("background pid %ld is done: ", (long)bgPid);
    }

    if(WIFEXITED(childStatus))
    {
        /* Print if the process exited normally */
        printf("exit value %d\n", WEXITSTATUS(childStatus));
    }
    else
    {
        /* Print if the process was terminated */
        printf("terminated by signal %d\n", childStatus);
    }
}


/* Switch in and out of foreground-only mode when SIGTSTP is detected */
void foregroundMode()
{
    if (blockBg == 1)
    {
        char* message = "Entering foreground-only mode (& is now ignored)\n";
        write(STDOUT_FILENO, message, strlen(message));
        blockBg = 0;
    }
    else
    {
        char* message = "Exiting foreground-only mode\n";
        write(STDOUT_FILENO, message, strlen(message));
        blockBg = 1;
    }
}


/* Print when SIGINT is detected */
void killProcess()
{
    printf("\nTerminating Processes:\n");
}
