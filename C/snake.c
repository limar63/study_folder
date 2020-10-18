#include <stdlib.h>
#include <curses.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

struct snake_piece {
    int x, y;
    struct snake_piece * next;
};

/*struct return_two_ints {                                        //struct to get two results in return from a function
    int first, second;
} return_apple;*/

int snake_length;                                               //snake length variable

struct  snake_piece * snake_tail;                               //first piece of a snake

struct  snake_piece * snake_head;                               //last piece of a snake

int x_app;                                                      //variable that will contain x coordinate of the apple

int y_app;                                                      //variable that will contain y coordinate of the apple

int x_change;                                                   //variable for turning the snake around after getting user input on x axis

int y_change;                                                   //variable for turning the snake around after getting user input on y axis

int x_limit;                                                    //variable for choosing the size of the field on x axis

int y_limit;                                                    //variable for choosing the size of the field on y axis

int x;                                                          //variable for current active cord on x axis

int y;                                                          //variable for current active cord on y axis

int apple_check(int xapp, int yapp) {
	struct snake_piece * current_piece = snake_head;
	while ((*current_piece).next != NULL) {
        if ((*current_piece).x == xapp && (*current_piece).y == yapp) {
            return 1;
        }
        current_piece = (*current_piece).next;
    }
	return 0;
}



void apple_create() {
    int x_res = rand() % x_limit;
    int y_res = rand() % y_limit;
    if (apple_check(x_res, y_res) == 1) {
        return apple_create();
    } else {
        x_app = x_res;
        y_app = y_res;
    }
}

void add_as_head() {
    if (snake_length == 0) {
		struct snake_piece *new_head;
		new_head = (struct snake_piece *)malloc(sizeof(struct snake_piece));
		(*new_head).x = x;
		(*new_head).y = y;
		(*new_head).next = NULL;
        snake_head = new_head;
        snake_tail = new_head;
    } else {
        struct snake_piece * old_head = snake_head;
        struct snake_piece *new_head;
		new_head = (struct snake_piece *)malloc(sizeof(struct snake_piece));
		(*new_head).x = x;
		(*new_head).y = y;
		(*new_head).next = old_head;
        snake_head = new_head;
    }
	snake_length++;
}

int get_speed(int length, int time) {
	for (int i = 0; i < length - 1; i++) {
		time = time * 0.95;
	}
	return time;
}

void forming_list(int file_arr[][y_limit], int i, int j) {
	y = i;
	x = j;
	add_as_head();
	snake_length++;
	switch (file_arr[i][j]) {
		case 1:
			if (j < x_limit - 1) {
				if (file_arr[i][j + 1] == 0) {
					x_change = 1;
					y_change = 0;
					break;
				} else {
					forming_list(file_arr, i, j + 1);
					break;
				}
			} else {
				if (file_arr[i + 1][0] == 0) {
					x_change = 1;
					y_change = 0;
					break;
				} else {
					forming_list(file_arr, i + 1, 0);
					break;
				}
			}
		case 2:
			if (j != 0) {
				if (file_arr[i][j - 1] == 0) {
					x_change = -1;
					y_change = 0;
					break;
				} else {
					forming_list(file_arr, i, j - 1);
					break;
				}
			} else {
				if (file_arr[i - 1][x_limit - 1] == 0) {
					x_change = -1;
					y_change = 0;
					break;
				} else {
					forming_list(file_arr, i - 1, x_limit - 1);
					break;
				}
			}
		case 3:
			if (i == 0) {
				if (file_arr[y_limit - 1][j] == 0) {
					x_change = 0;
					y_change = -1;
					break;
				} else {
					forming_list(file_arr, y_limit - 1, j);
					break;
				}
			} else {
				if (file_arr[i - 1][j] == 0) {
					x_change = 0;
					y_change = -1;
					break;
				} else {
					forming_list(file_arr, i - 1, j);
					break;
				}
			}
		case 4:
			if (i == y_limit - 1) {
				if (file_arr[0][j] == 0) {
					x_change = 0;
					y_change = 1;
					break;
				} else {
					forming_list(file_arr, 0, j);
					break;
				}
			} else {
				if (file_arr[i + 1][j] == 0) {
					x_change = 0;
					y_change = 1;
					break;
				} else {
					forming_list(file_arr, i + 1, j);
					break;
				}
			}
		case 5:
			if (j < x_limit - 1) {
				if (file_arr[i][j + 1] == 0) {
					x_change = 1;
					y_change = 0;
					break;
				} else {
					forming_list(file_arr, i, j + 1);
					break;
				}
			} else {
				if (file_arr[i + 1][0] == 0) {
					x_change = 1;
					y_change = 0;
					break;
				} else {
					forming_list(file_arr, i + 1, 0);
					break;
				}
			}
		case 6:
			if (j != 0) {
				if (file_arr[i][j - 1] == 0) {
					x_change = -1;
					y_change = 0;
					break;
				} else {
					forming_list(file_arr, i, j - 1);
					break;
				}
			} else {
				if (file_arr[i - 1][x_limit - 1] == 0) {
					x_change = -1;
					y_change = 0;
					break;
				} else {
					forming_list(file_arr, i - 1, x_limit - 1);
					break;
				}
			} 
		case 7:
			if (i == 0) {
				if (file_arr[y_limit - 1][j] == 0) {
					x_change = 0;
					y_change = -1;
					break;
				} else {
					forming_list(file_arr, y_limit - 1, j);
					break;
				}
			} else {
				if (file_arr[i - 1][j] == 0) {
					x_change = 0;
					y_change = -1;
					break;
				} else {
					forming_list(file_arr, i - 1, j);
					break;
				}
			} 
		case 8:
			if (i == y_limit - 1) {
				if (file_arr[y_limit - 1][j] == 0) {
					x_change = 0;
					y_change = 1;
					break;
				} else {
					forming_list(file_arr, 0, j);
					break;
				}
			} else {
				if (file_arr[y_limit - 1][j] == 0) {
					x_change = 0;
					y_change = 1;
					break;
				} else {
					forming_list(file_arr, i + 1, j);
					break;
				}
			}
	}
}

void print_file(int file_arr[][y_limit]) {
	for(int i = 0; i < y_limit; i++) {
		for (int j = 0; j < x_limit; j++) {
			if ((file_arr[i][j] >= 5) && (file_arr[i][j] <= 12)) {
				mvprintw(i, j, "#");
			}
			else if ((file_arr[i][j] >= 1) && (file_arr[i][j] <= 4)) {
				mvprintw(i, j, "#");
				forming_list(file_arr, i, j);	
			}
			else if (file_arr[i][j] == 65) {
				mvprintw(i, j, "@");

			} else {
				mvprintw(i, j, " ");
			}
		}
	}
}

void cut_the_tail() {
	if (snake_length <= 1) {
		endwin();
        printf("Can't delete from a snake with less than 2 elements");
        exit(1);
	} else {
        struct snake_piece * next_thing = snake_head;
		while ((*(*next_thing).next).next != NULL) {
			next_thing = (*next_thing).next;
		}
		free((*next_thing).next);
		(*next_thing).next = NULL;
		snake_tail = next_thing;
	}
	snake_length--;
}

void getting_input(int a) {
    if (a == 9) {
		endwin();
		printf("Game over! 1\n");
		exit(0);
	} else if (a == KEY_RIGHT && x_change != -1) {
		x_change = 1;
		y_change = 0;
	} else if (a == KEY_LEFT && x_change != 1) {
		x_change = -1;
		y_change = 0;
	} else if (a == KEY_DOWN && y_change != -1) {
		x_change = 0;
		y_change = 1;
	} else if (a == KEY_UP && y_change != 1) {
		x_change = 0;
		y_change = -1;
	}
}

void moving_and_drawing() {
	x = x + x_change;
	if (x > x_limit) {
		x = 0;
	} else if (x < 0) {
		x = x_limit;
	}
	y = y + y_change;
	if (y > y_limit) {
		y = 0;
	} else if (y < 0) {
		y = y_limit;
	}
	add_as_head();
	mvprintw((*snake_head).y, (*snake_head).x, "#");
    struct snake_piece * current_part = (*snake_head).next;
	while (current_part != NULL) {
		if ((*snake_head).x == (*current_part).x && (*snake_head).y == (*current_part).y) {
			endwin();
            printf("Game over! 2\n");
            exit(0);
		}
		current_part = (*current_part).next;
	}
	if ((*snake_head).x == x_app && (*snake_head).y == y_app) {
		apple_create();
		timeout(get_speed(snake_length, 1000));
		mvprintw(y_app, x_app, "@");
	} else {
		mvprintw((*snake_tail).y, (*snake_tail).x, " ");
		cut_the_tail();
	}
	refresh();
}

char* file_to_string(char file_name[]) {
	FILE *fptr;
	fptr=fopen(file_name, "r");
	fseek(fptr, 0, SEEK_END);
	long fsize = ftell(fptr);
	fseek(fptr, 0, SEEK_SET);

	char *file_string = malloc(fsize + 1);
	fread(file_string, 1, fsize, fptr);
	fclose(fptr);
	file_string[fsize] = 0;
	return file_string;
}

void assigning_size(char string_line[]) {
	int x_lines = 0;
	int x_checker = 0;
	int y_lines = 0;
	//printf("%s", file_string);
	for (int i = 0; i < strlen(string_line); i++) {
		if (string_line[i] != ',' && string_line[i] != '\n') {
			x_lines++;
		} else if (string_line[i] == '\n') {
			if (x_checker != x_lines && y_lines != 0) {
				printf("EXCEPTION: non-consistent line length\n");
			} else {
				x_checker = x_lines;
				x_lines = 0;
				y_lines++;
			}
		}
	}
	x_limit = x_checker; 												
	y_limit = y_lines; 
}
/*
int** parsing_string(char string_line[], int resulting_string[][x_limit]) {
	int i_mark = 0;
	int j_mark = 0;
	for (int i = 0; i < strlen(string_line); i++) {
		if (string_line[i] != ',' && string_line[i] != '\n') {
			if (isdigit(string_line[i])) {
				resulting_string[i_mark][j_mark] = string_line[i] - '0';
			} else {
				switch (string_line[i]) {
					case 'r':
						resulting_string[i_mark][j_mark] = 1;
						break;
					case 'l':
						resulting_string[i_mark][j_mark] = 2;
						break;
					case 'u':
						resulting_string[i_mark][j_mark] = 3;
						break;
					case 'd':
						resulting_string[i_mark][j_mark] = 4;
						break;
					case 'R':
						resulting_string[i_mark][j_mark] = 5;
						break;
					case 'L':
						resulting_string[i_mark][j_mark] = 6;
						break;
					case 'U':
						resulting_string[i_mark][j_mark] = 7;
						break;
					case 'D':
						resulting_string[i_mark][j_mark] = 8;
						break;
					case '>':
						resulting_string[i_mark][j_mark] = 5;
						break;
					case '<':
						resulting_string[i_mark][j_mark] = 6;
						break;
					case '^':
						resulting_string[i_mark][j_mark] = 7;
						break;
					case 'v':
						resulting_string[i_mark][j_mark] = 8;
						break;
					case '@':
						y_app = i_mark;
						x_app = j_mark;
						resulting_string[i_mark][j_mark] = 65;
						break;
					default:
						printf("GOT AN ISSUE\n");
				}
			}
			j_mark++;
		} else if (string_line[i] == '\n') {
			i_mark++;
			j_mark = 0;
		}
	}
	return resulting_string;
}*/

int main(void) {
	snake_length = 0;
	/*
	FILE *fptr;
	fptr=fopen("snake_map.txt", "r");

	fseek(fptr, 0, SEEK_END);
	long fsize = ftell(fptr);
	fseek(fptr, 0, SEEK_SET);

	char *file_string = malloc(fsize + 1);
	fread(file_string, 1, fsize, fptr);
	fclose(fptr);
	file_string[fsize] = 0;
	*/

	char *file_string = file_to_string("snake_map.txt");

	assigning_size(file_string);
	
	int file_arr[y_limit][x_limit];
	int i_mark = 0;
	int j_mark = 0;
	for (int i = 0; i < strlen(file_string); i++) {
		if (file_string[i] != ',' && file_string[i] != '\n') {
			if (isdigit(file_string[i])) {
				file_arr[i_mark][j_mark] = file_string[i] - '0';
			} else {
				switch (file_string[i]) {
					case 'r':
						file_arr[i_mark][j_mark] = 1;
						break;
					case 'l':
						file_arr[i_mark][j_mark] = 2;
						break;
					case 'u':
						file_arr[i_mark][j_mark] = 3;
						break;
					case 'd':
						file_arr[i_mark][j_mark] = 4;
						break;
					case 'R':
						file_arr[i_mark][j_mark] = 5;
						break;
					case 'L':
						file_arr[i_mark][j_mark] = 6;
						break;
					case 'U':
						file_arr[i_mark][j_mark] = 7;
						break;
					case 'D':
						file_arr[i_mark][j_mark] = 8;
						break;
					case '>':
						file_arr[i_mark][j_mark] = 5;
						break;
					case '<':
						file_arr[i_mark][j_mark] = 6;
						break;
					case '^':
						file_arr[i_mark][j_mark] = 7;
						break;
					case 'v':
						file_arr[i_mark][j_mark] = 8;
						break;
					case '@':
						y_app = i_mark;
						x_app = j_mark;
						file_arr[i_mark][j_mark] = 65;
						break;
					default:
						printf("GOT AN ISSUE\n");
				}
			}
			j_mark++;
		} else if (file_string[i] == '\n') {
			i_mark++;
			j_mark = 0;
		}
	}

	time_t t;
    srand((unsigned) time(&t));
    initscr();                                                  //initializing the ncurses
    cbreak();                                                      //for not breaking program by cntrl+c
    noecho();                                                   //no echoing of the input on the screen
    curs_set(0);                                                //no cursor on the screen
	//int file_arr[10][10] = {0, 1, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 12, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	
	print_file(file_arr);																								
    timeout(get_speed(snake_length, 1000));
	keypad(stdscr, 1);
	//add_as_head();
	//apple_create();
	//mvprintw(y_app, x_app, "@");
	//mvprintw((*snake_head).y, (*snake_head).x, "#");
    while (1) {
        moving_and_drawing();
        int a = getch();
        //usleep(2);
        getting_input(a);
    }
    endwin();                                                   //deinitializng the ncurses
    return 0;
}