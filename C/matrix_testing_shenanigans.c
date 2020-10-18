#include <stdio.h>
#include <stdlib.h> 
#include <string.h>

#define x_size 4
#define y_size 4


char* add_as_first(char *given_arr, char given_char) {
	int strLen = 0;
	while (given_arr[strLen] != '\0') {
		strLen++;
	}
	char *newString;
	newString = (char*)malloc((strLen + 1 + 1) * sizeof(char));
	
	newString[0] = given_char;
	int i = 0;

	for (; i < strLen; i++) {
		newString[i + 1] = given_arr[i]; 
	}
	newString[i + 1] = '\0';
	return newString;
}

char* add_as_last(char *given_arr, char given_char) {
	int strLen = 0; // string length of valid chars that are not null
	while (given_arr[strLen] != '\0') {
		strLen++;
	}
	char* newString = (char*)malloc((strLen + 1 + 1) * sizeof(char));		//first plus is for additional symbol and second plus is for \0
	int i = 0;

	for(; i < strLen; i++) {
		newString[i] = given_arr[i];
			
	}

	newString[i] = given_char;
	newString[i + 1] = '\0';
	return newString;
}

char* forming_list(int file_arr[][y_size], int i, int j, char body[]) {
	//we are making a list from the end to the beginning, so we need to add elements ot the beginning of the string
	char thing = '0';
	thing = j + '0';														//changing type from int to char
	body = add_as_first(body, thing);
	body = add_as_first(body, ',');
	thing = i + '0';														//changing type from int to char
	body = add_as_first(body, thing);
	body = add_as_first(body, ' ');
	if ((file_arr[i][j] == 1) || (file_arr[i][j] == 5)) {					//if its tail or body part, for moving right
		if (j < x_size - 1) {
			body = forming_list(file_arr, i, j + 1, body);
		} else {
			body = forming_list(file_arr, i + 1, 0, body);
		}
	} else if ((file_arr[i][j] == 2) || (file_arr[i][j] == 6)) {			//if its tail or body part, for moving left
		if (j != 0) {
			body = forming_list(file_arr, i, j - 1, body);
		} else {
			body = forming_list(file_arr, i - 1, x_size - 1, body);
		} 
	} else if ((file_arr[i][j] == 3) || (file_arr[i][j] == 7)) {			//if its tail or body part, for moving up
		if (i == 0) {
			body = forming_list(file_arr, y_size - 1, j, body);
		} else {
			body = forming_list(file_arr, i - 1, j, body);
		} 
	} else if ((file_arr[i][j] == 4) || (file_arr[i][j] == 8)) {			//if its tail or body part, for moving down
		if (i == y_size - 1) {
			body = forming_list(file_arr, 0, j, body);
		} else {
			body = forming_list(file_arr, i + 1, j, body);
		} 
	}
	return body; 
}

char* print_file(int file_arr[][y_size], char *res) {
	for(int i = 0; i < y_size; i++) {
		for (int j = 0; j < x_size; j++) {
			if ((file_arr[i][j] >= 5) && (file_arr[i][j] <= 9)) {
				res = add_as_last(res, '#');
			} 
			else if ((file_arr[i][j] >= 1) && (file_arr[i][j] <= 4)) {
				res = add_as_last(res, '#');
			} else {
				res = add_as_last(res, 'x');
			}
		}
		res = add_as_last(res, '\n');
	}
	return res;
}

char* print_file_x(int file_arr[][y_size], char *body) {
	for(int i = 0; i < y_size; i++) {
		for (int j = 0; j < x_size; j++) {
			if ((file_arr[i][j] >= 1) && (file_arr[i][j] <= 4)) {
				body = forming_list(file_arr, i, j, body);	
				j = x_size;
				i = y_size;
			} 
		}
	}
	return body;
}

int main()
{

    int disp[4][4] = {
		0, 1, 8, 0, 
		0, 0, 8, 0,
		0, 9, 6, 0, 
		0, 0, 0, 0
	};
	char *res;
	char *body;
	res = (char*)malloc((1) * sizeof(char));
	body = (char*)malloc((1) * sizeof(char));

	res[0] = '\0';
	body[0] = '\0';
	res = print_file(disp, res);
	body = print_file_x(disp, body);
	printf("%s\n", res);
	printf("%s\n", body);
    return 0;
}

