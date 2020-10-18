#include <stdio.h>

/**
 * Function to take input in two dimensional array (matrix) 
 * from user.
 *
 * @matrix  2D array to store input.
 * @rows    Total rows in 2D matrix.
 * @cols    Total columns in 2D matrix.
 */

int COLS, ROWS;
void inputMatrix(int matrix[][COLS], int rows, int cols)
{
    int i, j;


    for(i = 0; i < rows; i++)
    {
        for(j = 0; j < cols; j++)
        {
            // (*(matrix + i) + j is equivalent to &matrix[i][j]
            scanf("%d", (*(matrix + i) + j));
        }
    }
}



/**
 * Function to display elements of two dimensional array (matrix)
 * on console.
 *
 * @matrix  2D array to display as output.
 * @rows    Total rows in 2D matrix.
 * @cols    Total columns in 2D matrix.
 */
void printMatrix(int (*matrix)[COLS], int rows, int cols)
{
    int i, j;


    for (i = 0; i < rows; i++)
    {
        for (j = 0; j < cols; j++)
        {
            // *(*(matrix + i) + j) is equivalent to matrix[i][j]
            *(*(matrix + i) + j) = 666;
            printf("%d ", *(*(matrix + i) + j));
        }

        printf("\n");
    }
}


int main()
{
    COLS = 3;
    ROWS = 3;
    int matrix[ROWS][COLS];
    int i, j;

    /* Input elements in matrix */
    printf("Enter elements in %dx%d matrix.\n", ROWS, COLS);
    inputMatrix(matrix, ROWS, COLS);


    /* Print elements in matrix */
    printf("Elements of %dx%d matrix.\n", ROWS, COLS);
    printMatrix(matrix, ROWS, COLS);


    return 0;
}