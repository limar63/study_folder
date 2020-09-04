#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define x_size 2

#define y_size 2

int snake_body_x[x_size * y_size];

int snake_body_y[x_size * y_size];

const int snake_limit = x_size * y_size;

int head_mark, tail_mark, x_app, y_app, x, y, snake_size;                                               //snake length variable

//int x_change;                                                   //variable for turning the snake around after getting user input on x axis

//int y_change;                                                   //variable for turning the snake around after getting user input on y axis

//int naptime;                                                    //variable for speed purposes of the snake

bool apple_check(int xapp, int yapp) {
    if (head_mark < tail_mark) {
		int i;
		for (i; i <= head_mark; i++) {
        	if (snake_body_x[i] == xapp && snake_body_y[i] == yapp) {
            	return true;
        	}
		}
		i = tail_mark;
		for (i; i < snake_limit; i++) {
			if (snake_body_x[i] == xapp && snake_body_y[i] == yapp) {
				return true;
			}
		}
    } else {
		int i = tail_mark;
		for (i; i <= head_mark; i++) {
			if (snake_body_x[i] == xapp && snake_body_y[i] == yapp) {
				return true;
			}
		}
	}
    return false;
}

void apple_create() {
    time_t t;
    srand((unsigned) time(&t));
    int x_res = rand() % x_size;
    int y_res = rand() % y_size;
    if (apple_check(x_res, y_res) == true) {
        return apple_create();
    } else {
        x_app = x_res;
        y_app = y_res;
    }
}



void add_as_head() {                                                                //this function require first element to be added to an array
    head_mark++;                                                                     
    if (head_mark > snake_limit) {
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
		if (tail_mark > snake_limit) {
			tail_mark = 0;
		}
        snake_size--;
	}
}

void print_array_marked(int arr[]) {
    printf("Printing marked\n");
    if (head_mark < tail_mark) {
        int i;
        for (i; i <= head_mark; i++) {
            printf("%d, ", arr[i]);
        }
        i = tail_mark;
        for (i; i < snake_limit - 1; i++) {
            printf("%d, ", arr[i]);
        }
        printf("%d\n", arr[snake_limit - 1]);
    } else {
        int i = tail_mark;
        for (i; i < head_mark; i++) {
            printf("%d, ", arr[i]);
        }
        printf("%d\n", arr[head_mark]);
    }
}

void print_array_whole(int arr[]) {
    printf("Printing whole\n");
    int i = 0;
    for (i; i < snake_limit - 1; i++) {
        printf("%d, ", arr[i]);
    }
    printf("%d\n", arr[snake_limit - 1]);
}

int main(void) {
    snake_body_x[0] = 0;
    snake_body_y[0] = 0;
    snake_size = 1;
    print_array_marked(snake_body_x);
    print_array_whole(snake_body_x);
    x = 1;
    y = 1;
    add_as_head();
    print_array_marked(snake_body_x);
    print_array_whole(snake_body_x);
    printf("Tail is %d\n", tail_mark);
    printf("Head is %d\n", head_mark);
    printf("amount of elemnts is %d\n", snake_size);
    x = 2; 
    y = 2;
    add_as_head();
    print_array_marked(snake_body_x);
    print_array_whole(snake_body_x);
    printf("Tail is %d\n", tail_mark);
    printf("Head is %d\n", head_mark);
    printf("amount of elemnts is %d\n", snake_size);
    x = 3;
    y = 3; 
    add_as_head();
    print_array_marked(snake_body_x);
    print_array_whole(snake_body_x);
    printf("Tail is %d\n", tail_mark);
    printf("Head is %d\n", head_mark);
    printf("amount of elemnts is %d\n", snake_size);
    cut_the_tail();
    print_array_marked(snake_body_x);
    print_array_whole(snake_body_x);
    printf("Tail is %d\n", tail_mark);
    printf("Head is %d\n", head_mark);
    printf("amount of elemnts is %d\n", snake_size);
    /*printf("%d\n", head_mark);
    printf("%d\n", tail_mark);
    printf("%d\n", snake_limit);
    printf("%d\n", snake_body_x[0]);*/
    x = 4;
    y = 4;
    add_as_head();
    print_array_marked(snake_body_x);
    print_array_whole(snake_body_x);
    printf("Tail is %d\n", tail_mark);
    printf("Head is %d\n", head_mark);
    printf("amount of elemnts is %d\n", snake_size);
    x = 5;
    y = 5;
    add_as_head();
    print_array_marked(snake_body_x);
    print_array_whole(snake_body_x);
    printf("Tail is %d\n", tail_mark);
    printf("Head is %d\n", head_mark);
    printf("amount of elemnts is %d\n", snake_size);
    cut_the_tail();
    print_array_marked(snake_body_x);
    print_array_whole(snake_body_x);
    printf("Tail is %d\n", tail_mark);
    printf("Head is %d\n", head_mark);
    printf("amount of elemnts is %d\n", snake_size);
    return 0;
}