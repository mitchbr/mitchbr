To compile the program:
gcc -std=gnu99 -Wall smallsh.c -o smallsh

Basic command structure:
command [arg1 arg2 ...] [< input_file] [> output_file] [&]

Some features included in this shell:
1. Built in commands:
	- exit: leaves the shell prompt and returns to the default OS shell
	- cd: changes present working directory
	- status: prints out either the exit status or the terminating signal of the last foreground process

2. Command redirection: When a command not built into the shell is called, it will fork into a new process. These processes can be ran in the background using the & symbol at the very end of the command

3. Input and Output redirection: Redirects stdin and stdout to files using [< input_file] and [> output_file] in the command line

4. Signals:
	- CTRL-C kills all child processes but does not exit the shell
	- CTRL-Z allows the user to enter/exit foreground only mode, where new commands cannot be ran in the background

5. Other features:
	- $$ expansion: typing two dollar signs anywhere in a command will expand into the PID of the smallsh
	- Comments and blank lines: hitting enter on a blank line for beginning a line with # will create a comment and not try to execute