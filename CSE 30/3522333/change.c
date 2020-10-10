/****************************************************************************
Ruyin Zhang
****************************************************************************/
#include <stdio.h>

#define QUARTER 25
#define DIME 10
#define NICKELS 5

void printChange(int change)
{
	/*declare variables used to represent changes*/
	int quarter = 0;
	int dime = 0;
	int nickels = 0;
	int pennies = 0;

	printf("%d cents in change:\n",change); /*prints value to console*/

	quarter = change / QUARTER; /*calculates quarter amount*/
	printf("- %d quarters\n",quarter);
	change = change % QUARTER; /*defines change to be the remaining amount*/

	dime = change / DIME; /*calculates dime amount*/
	printf("- %d dimes\n",dime);
	change = change % DIME; /*defines change to be the remaining amount*/

	nickels = change / NICKELS; /*calculates nickels amount*/
	printf("- %d nickels\n",nickels);
	change = change % NICKELS; /*defines change to be the remaining amount*/

	pennies = change; /*defines pennies to be remaining amount*/
	printf("- %d pennies\n",pennies);
}