import re

def matrix_to_string(matrix): #перевод из матрицы в строку
	return '\n'.join(''.join(['[ ]', '[0]'][j] for j in i) for i in matrix)

def new_matrix(width, height): #создание новой матрицы заполненной нулями
	return [[0 for j in range(width)] for i in range(height)]
 
def recursion_launch(matrix, count): #Возможность выбора количества перебора
	if count == 0: 
		return print(matrix_to_string(matrix)) #отображение последнего перебора
	print(matrix_to_string(matrix))
	print()
	input('press any key to continue to the next mutation')
	recursion_launch(next_generation(matrix), count - 1) #рекурсионный запуск следующего витка

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
	for i in split_string:
		if len(i) != len(split_string[0]):
			return False #Возвращаем False, если формат матрицы некорректный 
		if re.match(r'(\[\s\]|\[0\]|\n)+', string_line):
			return True #Возвращаем True, если регекс проверка выполняется
		else: return False #Возвращаем False, если регекс проверка не выполняется

def string_to_matrix(string_line): #функция валидации и получения из стоки интовую матрицу с 0 и 1
	if string_validating(string_line):
		string_matrix = string_line.replace('[', '').replace(']', '').replace('0', '1').replace(' ', '0').split('\n') #Получаем полуфабрикат-матрицу для перевода в интовую матрицу	
		string_matrix = string_matrix[:len(string_matrix) - 1]
		return [[int(i) for i in j] for j in string_matrix]
	else:
		return print('Fix your string to make it look like a proper matrix')

with open('text_file', 'r') as myfile:
	mat1 = string_to_matrix(myfile.read())
n = int(input("Input the amount of times you want to mutate your matrix \n"))
print("Original matrix")
recursion_launch(mat1, n)