#include <stdlib.h>
#include <curses.h>

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

int naptime;                                                    //variable for speed purposes of the snake

void apple_create() {
    int x_res = rand() % x_limit;
    int y_res = rand() % y_limit;
    struct snake_piece * current_piece = snake_head;
	int check = 0;
    while ((*current_piece).next != NULL) {
        if ((*current_piece).x == x_res && (*current_piece).y == y_res) {
            check = 1;
        }
        current_piece = (*current_piece).next;
    }
    if (check == 1) {
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
		printf("Game over!\n");
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
            printf("Game over!\n");
            exit(0);
		}
		current_part = (*current_part).next;
	}
	if ((*snake_head).x == x_app && (*snake_head).y == y_app) {
		apple_create();
		naptime = naptime * 0.95;
		timeout(naptime);
		mvprintw(y_app, x_app, "@");
	} else {
		mvprintw((*snake_tail).y, (*snake_tail).x, " ");
		cut_the_tail();
	}
	refresh();
}

int main(void) {
	time_t t;
    srand((unsigned) time(&t));
    initscr();                                                  //initializing the ncurses
    cbreak();                                                      //for not breaking program by cntrl+c
    noecho();                                                   //no echoing of the input on the screen
    curs_set(0);                                                //no cursor on the screen
	snake_length = 0;
    x_limit = 10; 												
	y_limit = 10; 												
	x = 0; 																								
	y = 0; 																								
	x_change = 0;
	y_change = 1;
    naptime = 1000;
	timeout(naptime);
	keypad(stdscr, 1);
	add_as_head();
	apple_create();
	mvprintw(y_app, x_app, "@");
	mvprintw((*snake_head).y, (*snake_head).x, "#");
    while (1) {
        moving_and_drawing();
        int a = getch();
        //usleep(2);
        getting_input(a);
    }
    endwin();                                                   //deinitializng the ncurses
    return 0;
}