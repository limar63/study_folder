import curses
import re

def recursion_launch_input(): # функция проверки корректного инпута в консоль на ввод числа мутаций
	x = 0
	check = False
	while check == False:
		try:
			x = int(stdscr.getkey())
			if x < 1 or x > 100:
				stdscr.clear()				
				stdscr.addstr('please, input a proper integer value from 1 to 100 (included)\n')
				stdscr.refresh()
				continue
			check = True
		except ValueError:
			stdscr.clear()		
			stdscr.addstr('please, input a proper integer value from 1 to 100 (included)\n')
			stdscr.refresh()
			continue
	return x

def matrix_to_string(matrix): #перевод из матрицы в строку
	return '\n'.join(''.join(['[ ]', '[0]'][j] for j in i) for i in matrix)

def new_matrix(width, height): #создание новой матрицы заполненной нулями
	return [[0 for j in range(width)] for i in range(height)]
 
def recursion_launch(matrix, check, count): #Возможность выбора количества перебора
	if check == 0:
		stdscr.clear()
		count += 1
		stdscr.addstr('Final mutation number ' + str(count) + ' is:\n' + matrix_to_string(matrix)) #отображение последнего перебора	
		stdscr.refresh()
		return
	stdscr.clear()
	count += 1
	stdscr.addstr('Mutation number ' + str(count) + ':\n' + matrix_to_string(matrix) + '\n' + 'press any key to continue to the next mutation')
	stdscr.refresh()
	stdscr.getch()
	recursion_launch(next_generation(matrix), check - 1, count) #рекурсионный запуск следующего витка

def count_neighbors(matrix, x, y): #получение значения всех соседей элемента матрицы
	return get_cell(matrix, x-1, y-1) \
	+ get_cell(matrix, x - 1, y) \
	+ get_cell(matrix, x - 1, y + 1) \
	+ get_cell(matrix, x, y + 1) \
	+ get_cell(matrix, x + 1, y + 1) \
	+ get_cell(matrix, x + 1, y) \
	+ get_cell(matrix, x + 1, y - 1) \
	+ get_cell(matrix, x, y - 1)

def get_cell(matrix, x, y): #функция обращения к элементу матрицы с реализацией тороидирования
	width = len(matrix[0])
	height = len(matrix)
	if y == -1:
		y = height - 1
	elif y == height:
		y = 0
		
	if x == -1:
		x = width - 1
	elif x == width:
		x = 0

	return matrix[y][x]

def neighbor_display(matrix): #Функция для отладки (отображает матрицей кол-ва соседей)
	width = len(matrix[0])
	height = len(matrix)
	for y in range(height):
		for x in range(width):
			print('[' + str(count_neighbors(matrix, x, y)) + ']', end = '')
			print ('\n', end = '')
	return

def next_generation(matrix): #получение следующей итерации матрицы
	width = len(matrix[0])
	height = len(matrix)
	new_mat = new_matrix(width, height)
	for y in range(height):
		for x in range(width):
			if not matrix[y][x] and count_neighbors(matrix, x, y) == 3:
				new_mat[y][x] = 1
			elif matrix[y][x] and (count_neighbors(matrix, x, y) in [2, 3]):
				new_mat[y][x] = 1  	
	return new_mat

def string_batching(line, window): #Функция разрезания строки на лист с элементами-кусками в window символов
	return [line[i: i + window] for i in range(0, len(line), window)]

def string_validating(string_line): #функция валидации строки с пом. регекса
	split_string = string_line.split('\n') #Получаем массив строк без символа перехода на новую строчку
	if len(split_string) < 3 or len(split_string[0]) < 9:
		return False
	for i in split_string:
		if len(i) != len(split_string[0]):
			return False #Возвращаем False, если формат матрицы некорректный 
	if re.match(r'(\[\s\]|\[0\]|\n)+$', string_line):
		return True #Возвращаем True, если регекс проверка выполняется
	else: 
		return False #Возвращаем False, если регекс проверка не выполняется

def string_to_matrix(string_line): #функция валидации и получения из стоки интовую матрицу с 0 и 1
	if string_validating(string_line):
		string_matrix = string_line.replace('[', '').replace(']', '').replace('0', '1').replace(' ', '0').split('\n') #Получаем полуфабрикат-матрицу для перевода в интовую матрицу	
		string_matrix = string_matrix[:len(string_matrix) - 1]
		return [[int(i) for i in j] for j in string_matrix]
	else: #Случай некорректного значения файла
		stdscr.clear()
		stdscr.addstr('Fix your string file to make it look like a proper matrix')
		stdscr.refresh()


stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(True)
mat1 = []
with open('text_file', 'r') as myfile: #Чтение текстовой информации с файла
	mat1 = string_to_matrix(myfile.read().strip('\n'))
if mat1:
	stdscr.addstr('Input the amount of times you want to mutate your matrix \n')
	n = recursion_launch_input()
	stdscr.clear()
	stdscr.addstr('Original matrix is:' + '\n' + matrix_to_string(mat1) + '\n' + 'press any key to start the mutation')
	stdscr.getch()
	recursion_launch(next_generation(mat1), n - 1, 0) #-1 и отображение некстген матрицы чтобы не показывать по второму разу оригинал и при этом чтоб отобразить текст, отличающийся от текста тела рекурсии без лишних проверок и операторов
stdscr.getch()
myfile.close()


curses.echo()
curses.nocbreak()
stdscr.keypad(False)

curses.endwin()