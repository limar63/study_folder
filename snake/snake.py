import tkinter
import re
from random import randint
 
def moving_stuff(event):
        canvas.move(snake, 15, 15)
             
def creating_obstacles(event):
        for y in range(0, height):
                for x in range(0, width):    
                        if m[y][x] == 1:
                                canvas.create_rectangle(x * 25, y * 25, x * 25 + 25, y * 25 + 25, fill = 'black')

def creating_canvas(lst):
        c = tkinter.Canvas(root, width = width * 25, height = height * 25)
        c.pack()        
        creating_obstacles(c)
        return c
     

                
def moving():
        
        
        global x1, y1, x_change, y_change, snake_body, checker, speed

        canvas.delete(tkinter.ALL)
        checker = 1
        creating_obstacles()
        canvas.create_rectangle(apple_x * 25, apple_y * 25, apple_x * 25 + 25, apple_y * 25 + 25, fill = 'green')
        x1 += x_change
        if x1 > width - 1:
                x1 = 0
        elif x1 < 0:
                x1 = width - 1
        y1 += y_change
        if y1 > height - 1:
                y1 = 0
        elif y1 < 0:
                y1 = height - 1
        if [x1, y1] in snake_body:
                return
        if x1 == apple_x and y1 == apple_y:
                snake_body += [[x1, y1]]
                speed *= 0.9
                creating_apple()
        else:
                snake_body += [[x1, y1]]
                del snake_body[0]
        for i in snake_body:
                player(i[0] * 25, i[1] * 25, i[0] * 25 + 25, i[1] * 25 + 25, fill = 'black')
        print(snake_body)
        root.after(int(speed), moving)

def up_snake(event):
        global x_change, y_change, checker
        if y_change == 1 or checker == 0:
                return
        x_change = 0
        y_change = -1
        checker = 0
             
def left_snake(event):
        global x_change, y_change, checker
        if x_change == 1 or checker == 0:
                return
        x_change = -1
        y_change = 0
        checker = 0
        
def down_snake(event):
        global x_change, y_change, checker
        if y_change == -1 or checker == 0:
                return
        x_change = 0
        y_change = 1
        checker = 0

def right_snake(event):    
        global x_change, y_change, checker
        if x_change == -1 or checker == 0:
                return
        x_change = 1
        y_change = 0     
        checker = 0

def creating_apple():
        global apple_x, apple_y
        apple_x = randint(0, width - 1)
        apple_y = randint(0, height - 1)
        if m[apple_y][apple_x] == 1 or [apple_x, apple_y] in snake_body:
                creating_apple()

def string_validating(string_line): #функция валидации строки с пом. регекса
        split_string = string_line.split('\n') #Получаем массив строк без символа перехода на новую строчку
        if len(split_string) < 5 or len(split_string[0]) < 5:
                return False
        for i in split_string[1:]:
                if len(i) != len(split_string[0]) - 1:
                        return False #Возвращаем False, если формат матрицы некорректный          
        print(string_line)
        if re.match(r'\[(\[(0,|1,)+(0|1)\],\n)+\[(0,|1,)+(0|1)\]\]$', string_line):
                return True #Возвращаем True, если регекс проверка выполняется
        else: 
                return False #Возвращаем False, если регекс проверка не выполняется
                
def string_to_matrix(string_line): #функция валидации и получения из стоки интовую матрицу с 0 и 1
	if string_validating(string_line):
		string_matrix = string_line.replace('[', '').replace(']', '').replace(',', '').split('\n') #Получаем полуфабрикат-матрицу для перевода в интовую матрицу	
		string_matrix = string_matrix[:len(string_matrix) - 1]
		return [[int(i) for i in j] for j in string_matrix]
	else: #Случай некорректного значения файла
		print('Fix your string file to make it look like a proper matrix')

root = tkinter.Tk()
x1 = 5
y1 = 5
snake_body = [[x1, y1]]
x_change = 0
y_change = -1
checker = 1 #Перременная, проверяющая что команда задачи движения была дана лишь один раз
m = []
with open('text_file', 'r') as myfile: #Чтение текстовой информации с файла
	m = string_to_matrix(myfile.read().strip('\n'))
if m:
        height = len(m)
        width = len(m[0])
        creating_apple()
        canvas = creating_canvas(m)
        player = canvas.create_rectangle
        speed = 650
 

        root.bind("<Up>", up_snake)
        root.bind("<Left>", left_snake)
        root.bind("<Down>", down_snake)
        root.bind("<Right>", right_snake)
 
        root.after(300, moving)
        root.mainloop()

#Змейка проходит до конца - выходит из противоположного, препятствия с файла, сохранение состояния игры и загрузка состояния игры, pickle для этого. Перенести в мувинг дроу ректангл, ифы в функции движения чтобы нельзя было нажимать противоположные
#Калькулятор обратной поискозаписи
#Почитать про Lisp