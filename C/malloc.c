#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main()
{
    struct stock {
        char symbol[5];
        int quantity;
        float price;
    };
    struct stock *invest;
    /* Create structure in memory */
    invest=(struct stock *)malloc(sizeof(struct stock));
    if(invest==NULL) {
        puts("Some kind of malloc() error");
        exit(1);
    }
    /* Assign structure data */
    strcpy(invest->symbol,"GOOG");
    invest->quantity=100;
    invest->price=801.19;
    /* Display database */
    puts("Investment Portfolio");
    printf("SymboltSharestPricetValuen");
    printf("%-6st%5dt%.2ft%.2fn",
    invest->symbol,
    invest->quantity,
    invest->price,
    invest->quantity*invest->price);
    return(0);
}