import tkinter
import re
import pickle
from random import randint
  
 
def creating_obstacles(canvas): #Создание сцен
   for i in obstacles:
      canvas.create_rectangle(i[0] * 25, i[1] * 25, i[0] * 25 + 25, i[1] * 25 + 25, fill = 'black') # У нас массивы [x, y], поэтому [0] это х, а [1] это у

def creating_canvas(lst): #Функция создания канваса с препятствиями из подаваемого массива интовых 0 и 1 (можно перенести и прямо в код без функции по-хорошему)
   c = tkinter.Canvas(root, width = width * 25, height = height * 25)
   c.pack()   
   creating_obstacles(c)
   return c
 
def moving(): #Основная функция движение  
   global x1, y1, x_change, y_change, snake_body, checker, speed, obstacles
   
   canvas.delete(tkinter.ALL) #Очистка канваса для перерисовки всех элементов на нем
   checker = 1 #Перевод чекера в 1, показывающий, что команд поворота пока еще не было подано
   creating_obstacles(canvas) #Перерисовываем препятствия
   canvas.create_rectangle(apple_x * 25, apple_y * 25, apple_x * 25 + 25, apple_y * 25 + 25, fill = 'green') #Рисуем яблоко
   
   x1 += x_change #функция считывания движения с поворотом по х
   
   if x1 > width - 1: #Сцепка краев карты по х
      x1 = 0
   elif x1 < 0:
      x1 = width - 1
      
   y1 += y_change #функция считывания движения с поворотом по у
   
   if y1 > height - 1: #Сцепка краев карты по у
      y1 = 0
   elif y1 < 0:
      y1 = height - 1
      
   if [x1, y1] in snake_body or [x1, y1] in obstacles: #Проверка, не пора ли змее сдохнуть
      data["snake"] = [] #Очистка словаря от значений тела змеи
      with open('data.pickle', 'wb') as f: #Записывание очищенных значений тела в сейв
         pickle.dump(data, f)
      return
      
   if x1 == apple_x and y1 == apple_y: #Скушивание яблока и ускорение змеи с добавлением лишней клетки
      snake_body += [[x1, y1]]
      speed *= 0.9
      speed = int(speed)
      creating_apple()
   else: #Обычное перемещение змеи
      snake_body += [[x1, y1]]
      del snake_body[0]
      
   for i in snake_body: #Отрисовка тела змеи
      player(i[0] * 25, i[1] * 25, i[0] * 25 + 25, i[1] * 25 + 25, fill = 'grey')
      
   data["xchange"] = x_change #Изменение значений словаря
   data["ychange"] = y_change
   data["speed_value"] = speed
   with open('data.pickle', 'wb') as f: #Запись новых значений словаря
      pickle.dump(data, f)
   print(data) #Для проверки значений словаря в консоли
   root.after(speed, moving) #Рекурсия функции движения

def up_snake(event): #Поворот в верх
   global x_change, y_change, checker
   if y_change == 1 or checker == 0: #Проверка, что нельзя совершить поворот (не будет прямого перехода с нижнего движения вверх и с движения в лево в движение право и т.п.) и что будет совершено лишь одно действие поворота за время одного шага программы
      return
   x_change = 0
   y_change = -1
   checker = 0
        
def left_snake(event): #Поворот в лево
   global x_change, y_change, checker 
   if x_change == 1 or checker == 0: #Проверка, что нельзя совершить поворот (не будет прямого перехода с нижнего движения вверх и с движения в лево в движение право и т.п.) и что будет совершено лишь одно действие поворота за время одного шага программы
      return
   x_change = -1
   y_change = 0
   checker = 0
   
def down_snake(event): #Поворот в низ
   global x_change, y_change, checker
   if y_change == -1 or checker == 0: #Проверка, что нельзя совершить поворот (не будет прямого перехода с нижнего движения вверх и с движения в лево в движение право и т.п.) и что будет совершено лишь одно действие поворота за время одного шага программы
      return
   x_change = 0
   y_change = 1
   checker = 0

def right_snake(event):  #Поворот в право   
   global x_change, y_change, checker
   if x_change == -1 or checker == 0: #Проверка, что нельзя совершить поворот (не будет прямого перехода с нижнего движения вверх и с движения в лево в движение право и т.п.) и что будет совершено лишь одно действие поворота за время одного шага программы
      return
   x_change = 1
   y_change = 0     
   checker = 0

def creating_apple(): #Получение новой рандомной координаты яблока
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
x1 = 5 #Точка головы. Если на точке 5-5 будет стена - скорее всего не будет работать программа, но мне лень писать еще одно условие проверки на стену/рандомизацию спауна
y1 = 5
apple_x = 0 #х координата яблока
apple_y = 0 #у координата яблока
snake_body = [[x1, y1]] #Тело змеи
x_change = 0 #параметр поворота змеи по х
y_change = -1 #параметр поворота змеи по у
checker = 1 #Переменная, проверяющая что команда задачи движения была дана лишь один раз
obstacles = []
m = []   
with open('text_file', 'r') as myfile: #Чтение текстовой информации с файла
	m = string_to_matrix(myfile.read().strip('\n'))
if m:
   
   height = len(m) #Параметры подаваемого массива
   width = len(m[0]) 
   creating_apple() #Создание рандомной точки яблока
   canvas = creating_canvas(m) #Канвас на котором идет отрисовка
   player = canvas.create_rectangle #голова змеи
   speed = 650 #скорость перемещения змейки
   for y in range(0, height):
      for x in range(0, width):
         if m[y][x] == 1:
            obstacles += [[x, y]]
   with open('data.pickle', 'rb') as f: #Распаковка сейва с пикуля
      data = pickle.load(f)
   if not data["snake"]: #Если сейв пустой, то в пикуль запиливаются дефолтные данные
      data = {"snake":snake_body, "applex":apple_x, "appley":apple_y, "x":x_change, "y":y_change} 
   else: #Запиливание параметров с сейв файла
      snake_body = data["snake"]
      apple_x = data["applex"]
      apple_y = data["appley"]
      x_change = data["xchange"]
      y_change = data["ychange"]
      x1 = snake_body[len(snake_body) - 1][0]
      y1 = snake_body[len(snake_body) - 1][1]
      speed = data["speed_value"]

   root.bind("<Up>", up_snake) #привязка управления к стрелкам клавы
   root.bind("<Left>", left_snake)
   root.bind("<Down>", down_snake)
   root.bind("<Right>", right_snake)
 
   root.after(speed, moving)  #Запуск функции движения
   root.mainloop() #Запуск основного цикла гуишки