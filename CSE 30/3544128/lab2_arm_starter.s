@Ruyin Zhang & Shafeen Pittal
@@@ PRINT STRINGS, CHARACTERS, INTEGERS TO STDOUT
.equ Stdout,      0x01  @ Set output mode to be Output View
.equ SWI_PrStr,   0x69  @ Write a null-ending string
.equ SWI_PrInt,   0x6b  @ Write a null-ending string
.equ SWI_Exit,    0x11  @ Stop execution

.text

.align 8
.global get_max_ARM
.type get_max_ARM, %function

get_max_ARM:
    @ YOUR CODE GOES HERE (list *ls is in r0)
    @-----------------------
    @  create counter variable 

    MOV r5, #0 @ r5 = counter = 0; 

    @ get the size
    LDR r6, [r0] @ r6 = ls->sortedList
    LDR r7, [r0, #4] @ r7 = ls->size
    CMP r7, #0 
    BEQ isempty
    MOV r8, r7 
    SUB r8, #1 @ r8 = size - 1
    LDR r3,[r6, r8, LSL #2] @ go to the last element
    BAL end5

    isempty:
        MOV r3, #-1 
        BAL end5

    @ put your return value in r0 here:    

    @-----------------------
    end5:
        MOV r0,r3
    @ ARM equivalent of return
    BX lr

.align 8
.global get_min_ARM
.type get_min_ARM, %function

get_min_ARM:

    @ YOUR CODE GOES HERE (list *ls is in r0)

    LDR r6, [r0] @ r6 = ls->sortedList
    LDR r9, [r6] @ r9 = 1st element in sorted list
    LDR r4, [r0, #4] @ r4 = ls->size
    CMP r4, #0
    BEQ empty3 @ branch to empty for empty list 
    BAL end4 @ search list for value to remove
    empty3:
        MOV r9,#-1
        BAL end4
    @ put your return value in r0 here:    
    end4:
        MOV r0, r9

        @ ARM equivalent of return
        BX lr

.align 8
.global pop_min_ARM
.type pop_min_ARM, %function

pop_min_ARM:

    @ get the size
    LDR r3, [r0] @ r3 = ls->sortedList
    LDR r4, [r0, #4] @ r4 = ls->size
    @ create variable for size -1 
    MOV r10, r4 
    SUB r10, #1 

    @index variable
    MOV r2, #0 @ index = 0; 

    @ compare size to 0
    CMP r4, #0
    BEQ empty2 @ branch to empty for empty list 
    LDR r5,[r3] @ element to pop
    BAL pop @ search list for value to remove

    pop: 
        ADD r6, r2, #1 @ r6= [i+1]
        LDR r9,[r3, r6, LSL #2] @store array [i+1]
        SUB r6, r6, #1 @ r8 = i
        STR r9, [r3, r6, LSL #2] @array[i] = array[i+1]
        ADD r2, #1 @increment index
        CMP r2, r10 @ check if everything is already moved down
        BLT pop
        SUB r4, #1 @ decrement size 
        STR r4, [r0, #4] 
        BAL end3 

    empty2:
        MOV r5, #-1   @ no elements to remove 
        BAL end3
    
    @ put your return value in r0 here:
    
    end3:
        MOV r0, r5 @return the amount of times you removed 

    @ ARM equivalent of return
    BX lr

@.align 8
.global remove_val_ARM
.type remove_val_ARM, %function

remove_val_ARM:
    @ YOUR CODE GOES HERE (list *ls is in r0, int val is in r1)
    
    @  create index variable 

    MOV r2, #0 @ index = 0; 

    @create counter variable
    MOV r11, #0

    @ get the size
    LDR r3, [r0] @ r3 = ls->sortedList
    LDR r4, [r0, #4] @ r4 = ls->size

    @ create variable for size -1 
    MOV r10, r4 
    SUB r10, #1 

    @ compare size to 0
    CMP r4, #0
    BEQ notremoved @ branch to empty for empty list 
    BAL search @ search list for value to remove

    search: @ find remove value 
        LDR r5,[r3, r2, LSL #2] @ store the element at the first index        
        CMP r5, r1   @ compare the element with the value you want to insert
        BEQ remove   @ if the array value equals the remove value  
        ADD r2, #1 @ increment index
        CMP r2, r4 @compare the index with the size (to make sure you arent at end of list)
        BLT search @ keep iterating
        BAL notremoved

    remove: 
        ADD r6, r2, #1 @ r6= [i+1]
        LDR r9,[r3, r6, LSL #2] @store array [i+1]
        SUB r6, r6, #1 @ r8 = i
        STR r9, [r3, r6, LSL #2] @array[i] = array[i+1]
        ADD r2, #1 @increment index
        CMP r2, r10 @ check if everything is already moved down
        BLT remove
        SUB r4, #1 @ decrement size 
        STR r4, [r0, #4] 
        ADD r11, #1 @increment counter
        MOV r2, #0 @ set back to 0
        BAL search @ check for more to remove 

    notremoved:
        MOV r2, #-1   @ no elements to remove 
        BAL end2
    
    @ put your return value in r0 here:
    
    end2:
        MOV r0, r11 @return the amount of times you removed 

    @ ARM equivalent of return
    BX lr

.align 8
.global search_ARM
.type search_ARM, %function

search_ARM:
    @ YOUR CODE GOES HERE (list *ls is in r0, int val is in r1)
    @-----------------------

    @ (your code)
    @  create counter variable 

    MOV r5, #0 @ index = 0; 

    @ get the size
    LDR r6, [r0] @ r6 = ls->sortedList
    LDR r7, [r0, #4] @ r7 = ls->size
    CMP r7, #0  @ compare size to 0
    BEQ not_found 
    BAL loop4

    loop4:
        LDR r3,[r6, r5, LSL #2] @load element from array      
        CMP r3, r1  
        BGT not_found
        BEQ end1
        ADD r5, #1 @ increment index
        CMP r5, r7 
        BLT loop4
        BAL not_found
    
    not_found:
        MOV r5, #-1
        BAL end1
    @ put your return value in r0 here:
    end1:
        MOV r0, r5

    @ ARM equivalent of return
        BX lr

.align 8
.global insert_ARM
.type insert_ARM, %function

insert_ARM:
    @ YOUR CODE GOES HERE (list *ls is in r0, int val in r1)
   
    @  create index variable 

    MOV r5, #0 @ counter = 0; 

    @ get the size
    LDR r6, [r0] @ r6 = ls->sortedList
    LDR r7, [r0, #4] @ r7 = ls->size
    LDR r12, [r0, #8] @ ls -> maxsize
    
    @ compare size to 0
    CMP r7, #0
    BEQ empty @ branch to empty for first element
    CMP r7, r12 @ compare max size with size 
    BLT loop2 @ find index to insert at 
    MOV r5, #-1
    BAL end

    loop2: @ finding index 
        LDR r3,[r6, r5, LSL #2] @ store the element at the first index        
        CMP r3, r1   @ compare the element with the value you want to insert
        BGE insert   @ if the array value is greater than new value go to insert 
        ADD r5, #1 @ increment index
        CMP r5, r7 @compare the index with the size (to make sure you arent at end of list)
        BLT loop2 @ keep iterating
        STR r1, [r6, r5, LSL #2] @ new element goes at the end (it is the largest value)
        ADD r7, #1 @ increment size
        STR r7, [r0, #4] @store back the size
        BAL end

    insert: 
        MOV r8, r7 
        SUB r8, #1 @ variable for (Size -1)
        
        move: @moving elements down
            LDR r9,[r6, r8, LSL #2] @store the last element array[i]
            ADD r11, r8, #1 @find new index (i + 1)
            STR r9, [r6, r11, LSL #2] @array[i+1] = array[i]
            CMP r8, r5  @compare the size-1 with the index (youre already where you want to insert)
            BEQ insertElement @ index matches size-1
            SUB r8, #1  @ move up array
            BAL move   @ keep moving down
        
        insertElement: @inserting element 
        STR r1, [r6, r5, LSL #2]  @insert the element to the index
        ADD r7, #1 @ increment the size
        STR r7, [r0, #4] @store back the size
        BAL end @ return the value

    empty:
        STR r1, [r6] @store first element into 0 index
        ADD r7, #1    @ increment size
        STR r7, [r0, #4] 
        BAL end
    
    @ put your return value in r0 here:

    end:
        MOV r0, r5 @return the index you inserted at 

    @ ARM equivalent of return
        BX lr

.align 8
.global print_ARM

.type print_ARM, %function

print_ARM:
    @ Save caller's registers on the stack
    @push {r4-r11, ip, lr}

    @ YOUR CODE GOES HERE (list *ls is in r0)
    @-----------------------
    MOV r4, r0 @ r4 = ls
    LDR r6, [r4] @ r6 = ls->sortedList
    LDR r7, [r4, #4] @ r7 = ls->size
    MOV r5, #-1 @ r5 = -1 (i)
    
loop:
    ADD r5, r5, #1
    CMP r5, r7
    BGE continued 
    MOV r0, #Stdout         @ mode is Stdout
    LDR r1,[r6, r5, LSL #2]
    SWI SWI_PrInt
    MOV r0, #Stdout         @ mode is Stdout
    LDR r1, =space          @ space
    SWI SWI_PrStr
    B loop

continued:
    MOV r0, #Stdout         @ mode is Stdout
    LDR r1, =nl          @ new line
    SWI SWI_PrStr


    @ put your return value in r0 here:

    @-----------------------

    @ restore caller's registers
    @pop {r4-r11, ip, lr}

    @ ARM equivalent of return
    BX lr


.align 8
.global _start
.type _start, %function

_start:
    LDR R0, =sorted_list
    LDR R2, =sorted_array
    STR R2, [R0]

    LDR R0, =sorted_list
    MOV R1, #20
    BL insert_ARM

    LDR R0, =sorted_list
    MOV R1, #0
    BL insert_ARM

    LDR R0, =sorted_list
    MOV R1, #8
    BL insert_ARM

    LDR R0, =sorted_list
    MOV R1, #12
    BL insert_ARM

    LDR R0, =sorted_list
    MOV R1, #5
    BL insert_ARM

    LDR R0, =sorted_list
    BL get_max_ARM

    LDR R0, =sorted_list
    MOV R1, #20
    BL search_ARM

    LDR R0, =sorted_list
    BL pop_min_ARM

    LDR R0, =sorted_list
    BL print_ARM

    bx lr


.data
nl: .asciz "\n"
.align 4
sorted_list: .word 0
size: .word 0
maxSize: .word 100
sorted_array: .skip 400
.align 4
space: .asciz " "
.end