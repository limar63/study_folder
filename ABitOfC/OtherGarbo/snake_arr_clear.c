#include <stdio.h>
#include <stdlib.h>
#include <curses.h>
#include <stdbool.h>
#include <string.h>

#define x_size 10

#define y_size 10

int snake_body_x[x_size * y_size];

int snake_body_y[x_size * y_size];

const int snake_limit = x_size * y_size;

int head_mark, tail_mark, x_app, y_app, x_change, y_change, x, y, snake_size, naptime;

int apple_check(int xapp, int yapp) {
    if (head_mark < tail_mark) {
		int i;
		for (i; i <= head_mark; i++) {
        	if (snake_body_x[i] == xapp && snake_body_y[i] == yapp) {
            	return 1;
        	}
		}
		i = tail_mark;
		for (i; i < snake_limit; i++) {
			if (snake_body_x[i] == xapp && snake_body_y[i] == yapp) {
				return 1;
			}
		}
    } else {
		int i = tail_mark;
		for (i; i <= head_mark; i++) {
			if (snake_body_x[i] == xapp && snake_body_y[i] == yapp) {
				return 1;
			}
		}
	}
    return 0;
}

void apple_create() {
    int x_res = rand() % x_size;
    int y_res = rand() % y_size;
    if (apple_check(x_res, y_res) == 1) {
		mvprintw(14, 14, "GOT THE SAME! %d, %d", x_res, y_res);
		refresh();
        return apple_create();
    } else {
        x_app = x_res;
        y_app = y_res;
    }
}

void add_as_head() {                                                                //this function require first element to be added to an array
    head_mark++;                                                                     
    if (head_mark >= snake_limit) {
		head_mark = 0;
	}
    snake_body_x[head_mark] = x;
	snake_body_y[head_mark] = y;  
    snake_size++;
}

void cut_the_tail() {
	if (snake_size < 2) {
		endwin();
        printf("Can't delete from a snake with less than 2 elements\n");
        exit(1);
	} else {
		tail_mark++;
		if (tail_mark >= snake_limit) {
			tail_mark = 0;
		}
        snake_size--;
	}
}

void getting_input(int a) {
    if (a == 9) {
		endwin();
		printf("Game over!1\n");
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
	if (x > x_size) {
		x = 0;
	} else if (x < 0) {
		x = x_size;
	}
	y = y + y_change;
	if (y > y_size) {
		y = 0;
	} else if (y < 0) {
		y = y_size;
	}
	add_as_head();
	mvprintw(snake_body_y[head_mark], snake_body_x[head_mark], "#");
	if (head_mark < tail_mark) {
		if (snake_body_x[head_mark] == x_app && snake_body_y[head_mark]== y_app) {
			apple_create();
			mvprintw(y_app, x_app, "@");
		} else {
			mvprintw(snake_body_y[tail_mark], snake_body_x[tail_mark], " ");
			cut_the_tail();
		}
    } else {
		if (snake_body_x[head_mark] == x_app && snake_body_y[head_mark]== y_app) {
			apple_create();
			mvprintw(y_app, x_app, "@");
		} else {
			mvprintw(snake_body_y[tail_mark], snake_body_x[tail_mark], " ");
			cut_the_tail();
		}
	}
	refresh();
}

int main(void) {
	time_t t;
    srand((unsigned) time(&t));
    initscr();                                                  //initializing the ncurses
    cbreak();                                                   //for not breaking program by cntrl+c
    noecho();                                                   //no echoing of the input on the screen
    curs_set(0);                                                //no cursor on the screen											
	x = 0; 																								
	y = 0;																							
	x_change = 0;
	y_change = 1;
	naptime = 1000;
	keypad(stdscr, 1);
	nodelay(stdscr, 1);
	timeout(naptime);
	snake_body_x[0] = x;
    snake_body_y[0] = y;
    snake_size = 1; 	
	apple_create();
	mvprintw(y_app, x_app, "@");
	mvprintw(snake_body_y[0], snake_body_x[0], "#");
    while (1) {
        moving_and_drawing();
        int a = getch();
		mvprintw(11, 11, "%d", a);
        getting_input(a);
		
		//char thingy;
		//sprintf(thingy, "%d", a);
		
    }
    endwin();                                                   //deinitializng the ncurses
    return 0;
}