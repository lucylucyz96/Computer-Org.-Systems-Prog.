//Ruyin Zhang & Shafeen Pittal
#include <stdio.h>
#include <stdlib.h>

#include "arraysort.h"

#define DOUBLE 2
/**
 * This function creates an empty list, with space allocated for an array of
 * maxElements ints (pointed to by int *sortedList) and returns a pointer to the
 * list.
 */
list* createlist(int maxElements)
{
	
	list *sort_list = (list *)malloc(sizeof(list));
	int *ptr_one = (int *)malloc(maxElements*sizeof(int));

	sort_list->sortedList = ptr_one;
	sort_list->size = 0;
	sort_list->maxSize = maxElements;

	return sort_list;

}

/**
 * This function takes a pointer to the list and an integer value as input. It
 * should insert the value 'val' into sortedList, update the number of elements
 * in the list and return the index where the element was inserted. If the list
 * is full before inserting the element, it should increase the size of the list
 * to double its previous size and then insert the element. If the result of the
 * insert was not successful it should return -1. Note that the resulting list
 * should be sorted and there should be no information loss. The function should
 * return -1 if no valid list was passed to it..
 */
int insert(list *ls, int val) {
	if (ls == NULL) {
		return -1;
	}
	
	/*printf("address of struct 0x%x\n", ls);
	printf("address of list   0x%x\n", ls->sortedList);
	printf("size of list      %d\n",   ls->size);*/

	// if its empty
	if (ls -> size == 0) {
		*ls->sortedList = val;
		ls->size = (ls->size) + 1;
		return 0;
	}

	// reallocate
	if (ls -> size == ls->maxSize) {
		ls->maxSize = (ls->maxSize) * DOUBLE;
		ls->sortedList = realloc(ls->sortedList, sizeof(int)*(ls->maxSize));
	}
	int i;
	for (i=0; i < ls->size; i++) {
		if (val <= ls->sortedList[i]) {
			for (int j= ls->size -1; j >= i; j--) {
				ls->sortedList[j + 1] = ls->sortedList[j];
			}
			ls->sortedList[i] = val;
			ls->size = ls->size + 1;
			return i;
		}
	}
	ls->sortedList[ls->size] = val;
	ls->size = ls->size + 1;
	return (ls->size);
}

/**
 * This function takes a pointer to the list and an integer value as input. It
 * should delete all instances of elements in the sortedList with value 'val',
 * update the number of elements remaining in the list and return the number of
 * elements that were deleted. Once again the resulting list should be sorted.
 */
int remove_val(list *ls, int val)
{
	int position = 0;
	int count = 0;

	
	int index;
	for(index = 0; index < ls->size; index++){
		if(*(ls->sortedList+position) < val){
			position++;
		}
		else if(*(ls->sortedList+position)== val){
			
			memcpy(ls->sortedList+position,ls->sortedList+position+1,sizeof(int)*(ls->size - position));
			count++;
		}
		else if(*(ls->sortedList+position) > val)
			break;
	}

	ls->size = ls->size - count;
	return count;
}

/**
 * This function takes a pointer to the the list as input and returns the
 * maximum value in the list OR -1 if the list is empty.
 */
int get_max_value(list *ls)
{	
	if(ls->size == 0)
		return -1;
	int compare = 0;
	int index;
	for(index = 0; index<ls->size; index++){
			compare = *(ls->sortedList+index);
	}
	return compare;
}

/**
 * This function takes a pointer to the list and returns the minimum value in
 * the list OR -1 if the list is empty.
 */
int get_min_value(list *ls){
	int compare = 0;

	if(ls->size == 0)
		return -1;

	compare = *(ls->sortedList);
	return compare;

}

/**
 * This function returns the index of the first occurrence of 'val' in the
 * list. It returns -1 if the value 'val' is not present in the list.
 */
int search(list *ls, int val){
	int index = 0;
	for(index = 0; index<ls->size; index++){
			if(*(ls->sortedList+index) == val)
				return index;
	}
	return -1;
}

/**
 * This function returns the minimum value from the list and removes it from the
 * list. It returns -1 if the list is empty.
 */
int pop_min(list *ls){
	if(ls->size == 0)
		return -1;
	int min_val=0;
	min_val = get_min_value(ls);
	ls->size--;
	memcpy(ls->sortedList,ls->sortedList+1,sizeof(int)*(ls->size));
	return min_val;

}

/**
 * This function print the contents of the sorted list on a single line as follows:
 * 1 4 6 7 8
 */
void print(list *ls){
	int index = 0;
	for(index = 0; index<ls->size; index++){
	printf("%d ",*((ls->sortedList)+index),stdout);		
	}
}

/**
 * Identical to get_min_value(), but implemented in ARM assembly
 * (use given file get_min_ARM.s)
 */
int get_min_ARM(list *ls);

/**
 * Identical to get_max_value(), but implemented in ARM assembly
 * (use given file get_max_ARM.s)
 */
int get_max_ARM(list *ls);

