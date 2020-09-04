from tkinter import *

def print_char(event):
	label1.configure(text = event.char)
	
	
def print_su(event):
	label1.configure(text = "Shift Up")
	
def print_cd(event):
	label1.configure(text = "Control Down")	

root = Tk()

label1 = Label(root, width = 12, font = ("Ubuntu", 100))
label1.pack()


for i in range(65, 123):
	root.bind(chr(i), print_char)

root.bind("<Shift-Up>", print_su)
root.bind("<Control-Down>", print_cd)

root.mainloop()