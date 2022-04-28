import tkinter as tk
from functools import partial

class Nurikabe:
    def __init__(self):
        """
        This method sets up the game and executes the GUI.
        """

        window = tk.Tk()
        self.grid_frame = tk.Frame(window)

        # Set up the gameboard
        self.grid_size = 7
        self.values = [[2, 6, 5],
                       [4, 3, 3],
                       [5, 1, 5],
                       [6, 2, 3],
                       [6, 6, 4]]

        self.nums = list()
        self.shaded = 0
        self.create_board()

        # Create the buttons and labels
        self.buttons = [[tk.Button(self.grid_frame) for _ in range(self.grid_size)] for _ in range(self.grid_size)]
        self.fin_button = tk.Button(window, text="Finish", command=self.check_sol)
        self.lbl_output = tk.Label(window, text="", width=25, wraplength=225)

        for i in range(self.grid_size):
            for j in range(self.grid_size):
                self.buttons[i][j].config(command=partial(self.mark_button, i, j))
                self.buttons[i][j].grid(row=i, column=j)
                if self.nums[i][j] != 0:
                    self.buttons[i][j].config(text=str(self.nums[i][j]))

        self.grid_frame.pack()
        self.fin_button.pack()
        self.lbl_output.pack()
        window.mainloop()

    def create_board(self):
        """
        Creates a list that stores the game board
        """

        self.nums = [[0 for _ in range(self.grid_size)] for _ in range(self.grid_size)]
        unshaded_val = 0
        for row in self.values:
            # Finds the sum of the values to be left unshaded
            unshaded_val += row[2]

            # Adds the values into nums
            self.nums[row[0]][row[1]] = row[2]

        self.shaded = self.grid_size ** 2 - unshaded_val  # The number of cells that need to be shaded

    def mark_button(self, n1, n2):
        """
        Allows the buttons to toggle between "Marked" and "Unmarked"
        :param n1: the x-location of the selected button
        :param n2: the y-location of the selected button
        """

        if self.nums[n1][n2] == 0:
            # Marks a button
            self.buttons[n1][n2].config(text="M")
            self.nums[n1][n2] = -1
        elif self.nums[n1][n2] == -1:
            # Removes the mark from a button
            self.buttons[n1][n2].config(text="")
            self.nums[n1][n2] = 0

    def check_sol(self):
        """
        Checks the solution when the user presses "Finish"
        """

        valid_unshaded = self.check_unshaded()  # Run BFS on the numbers

        # Run BFS on the shaded region
        visited = list()
        count_shaded = 0
        queue = list()
        queue.append([0, 0])
        found_square = False

        while queue:
            node = queue.pop()
            count_shaded += 1
            for i in (-1, 1):
                # Adds children of the node to the queue
                if 0 <= node[0]+i < self.grid_size and [node[0]+i, node[1]] not in visited and self.nums[node[0]+i][node[1]] == -1:
                    queue.append([node[0]+i, node[1]])
                if 0 <= node[1]+i < self.grid_size and [node[0], node[1]+i] not in visited and self.nums[node[0]][node[1]+i] == -1:
                    queue.append([node[0], node[1]+i])

            # Checks if there is a 2x2 block
            if node[0]+1 < self.grid_size-1 and node[1]+1 < self.grid_size-1 and self.nums[node[0]+1][node[1]] == -1 and self.nums[node[0]][node[1]+1] == -1 and self.nums[node[0]+1][node[1]+1] == -1:
                found_square = True

            visited.append(node)

        # Determines if the user has correctly solved the puzzle or not
        if not valid_unshaded:
            self.lbl_output["text"] = "One or more of your unshaded regions is invalid."
        elif found_square:
            self.lbl_output["text"] = "2x2 Found."
        elif count_shaded != self.shaded:
            self.lbl_output["text"] = "The shaded region is not contiguous."
        else:
            self.lbl_output["text"] = "This solution is valid."

    def check_unshaded(self):
        """
        Runs BFS on the numbers on the board
        """
        for value in self.values:
            # Executes a new BFS for each number
            queue = list()
            visited = list()
            queue.append([value[0], value[1]])
            count_unshaded = 0
            while queue:
                node = queue.pop()
                count_unshaded += 1
                for move in (-1, 1):
                    # Adds children of the node to the queue
                    if 0 <= node[0]+move < self.grid_size and [node[0]+move, node[1]] not in visited and self.nums[node[0]+move][node[1]] >= 0:
                        queue.append([node[0] + move, node[1]])
                    if 0 <= node[1] + move < self.grid_size and [node[0], node[1] + move] not in visited and self.nums[node[0]][node[1] + move] >= 0:
                        queue.append([node[0], node[1] + move])

                visited.append(node)

            if count_unshaded != value[2]:
                # Return False if one of the regions is not correct
                return False

        return True


if __name__ == "__main__":
    Nurikabe()
