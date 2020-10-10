@@@=============================================================================
@@@ SoftWare Interrupts (SWI)
@@@
.equ SWI_PrChr, 0x00    @ Write an ASCII char to Stdout
.equ SWI_RdChr, 0x01    @ Read an ASCII char 
.equ SWI_Exit,  0x11    @ Stop execution
.equ SWI_Open,  0x66    @ open a file
.equ SWI_Close, 0x68    @ close a file
.equ SWI_PrStr, 0x69    @ Write a null-ending string
.equ SWI_PrInt, 0x6b    @ Write an Integer
.equ SWI_RdInt, 0x6c    @ Read an Integer from a file
.equ Stdout,    1       @ Set output target to be Stdout


@@@=============================================================================
@@@ Echo input file to output file
@@@   input:   whatin.txt
@@@   output:  whatout.txt
@@@
.align   8
.global  read_write_echo_ARM
.type    read_write_echo_ARM, %function

read_write_echo_ARM:
   .fnstart
   
  start:
      @ open file for reading 
      ldr r0,=whatin_file_in      @ loads file name into register
      mov r1,#0               @ second arg, gives read permisions  
      swi SWI_Open            @ opens the file
      bcs error               @ Check Carry-Bit (C): if= 1 then ERROR
      ldr r1,=InputFileHandle @ loads address of file into r1
      str r0,[r1]             @ r0 is a "pointer" to the file, r1 is a c pointer to the handle. stores name at address 
      MOV r4, r0              @ r4= InFileHandle

      @ open out put file for writing 
      ldr r0,=whatout_file_out     @ loads file name into register
      mov r1,#1               @ second arg, gives write permisions  
      swi SWI_Open            @ opens the file
      bcs error               @ Check Carry-Bit (C): if= 1 then ERROR
      ldr r1,=OutFileHandle @ loads address of file into r1
      str r0,[r1]             @ r0 is a "pointer" to the file, r1 is a c pointer to the handle. stores name at address 
      MOV r5, r0              @ r5= outFileHandle


  @read the numbers
  loop:
      MOV r0, r4      @ passing in file handle 
      swi SWI_RdInt   @ read the integer into R0   @CHANGED
      bcs close       @ Check Carry-Bit (C): if= 1 then EOF reached
      stmdb sp!, {r0} @ push to the stack 
      MOV r1, r0      @ saves int
      MOV r0, r5      @ holds file handle 
      swi SWI_PrInt 
      MOV r0, r5      @ holds file handle 
      ldr r1,=SPACE 
      swi SWI_PrStr
      BAL loop

  close:
      ldr R0,=InFileHandle @ get address of file handle
      ldr R0, [R0] @ get value at address
      swi SWI_Close
      MOV r0, r5 
      swi SWI_Close @ close output file
      bal endoffile
    
  error:
    mov R0, #Stdout
    ldr R1, =FileOpenInpErrMsg
    swi SWI_PrStr
    bal endoffile
    
    endoffile:
      bx lr

   .fnend

@@@=============================================================================
@@@ Read two 4x4 matrix
@@@   input:   matin.txt
@@@      
@@@   If the input file have the following 3x3 matrix:
@@@
@@@      1 2 3 4 5 6 7 8 9
@@@
@@@   The stack will have the following pattern:
@@@      
@@@      +-+
@@@      |7| <-- SP
@@@      +-+      
@@@      |8|   
@@@      +-+
@@@      |9|
@@@      +-+
@@@      |4|
@@@      +-+
@@@      |5|
@@@      +-+
@@@      |6|
@@@      +-+
@@@      |1|
@@@      +-+
@@@      |2|
@@@      +-+
@@@      |3|
@@@      +-+
@@@


.align   8
.global  matrix_read_ARM
.type    matrix_read_ARM, %function

matrix_read_ARM:
   .fnstart

    matrix_read: 
      @ open file for reading 
      ldr r0,=matin_file_in       @ loads file name into register
      mov r1,#0               @ second arg, gives read permisions  
      swi SWI_Open            @ opens the file
      bcs error2               @ Check Carry-Bit (C): if= 1 then ERROR
      ldr r1,=InputFileHandle @ loads address of file into r1
      str r0,[r1]             @ r0 is a "pointer" to the file, r1 is a c pointer to the handle. stores name at address 
      MOV r4, r0              @ r4= InFileHandle
      @mov r5, #1              @ place holder /which row you are on

    readmatrix:
      mov r6, #0              @ r6 = count 
      SUB sp, #16            @ move stack pointer up
      BAL readrow

        readrow:
          MOV r0, r4      @ passing in file handle 
          swi SWI_RdInt   @ read the integer into R0   @CHANGED
          bcs closematrix       @ Check Carry-Bit (C): if= 1 then EOF reached
          str r0, [sp]       @ push to the stack 
          ADD sp, #4
          ADD r6, #1      @ increment counter 
          CMP r6, #4      @ at end of loop
          BLT readrow
          SUB sp, #16     @ make up loss from 
          BAL readmatrix

    closematrix:
      ADD sp, #16 
      MOV r0, r4      @ passing in file handle 
      swi SWI_Close
      bal end2
    
    error2:
      mov R0, #Stdout
      ldr R1, =FileOpenInpErrMsg
      swi SWI_PrStr
      bal end2

    end2:
      bx lr 


   .fnend

@@@=============================================================================
@@@ 4x4 matrix multiplication
@@@   input:   matin.txt
@@@   output:  matout.txt
@@@      
@@@   For example:
@@@
@@@ a =             b =
@@@   8   1   6       8   1   6
@@@   3   5   7       3   5   7
@@@   4   9   2       4   9   2
@@@
@@@ a * b = 
@@@       91    67    67
@@@       67    91    67
@@@       67    67    91
@@@


.align   8
.global  matrix_mult_ARM
.type    matrix_mult_ARM, %function

matrix_mult_ARM:
    .fnstart

    startmatrix:

      @open output file 
      ldr r0,=matout_file_out     @ loads file name into register
      mov r1,#1               @ second arg, gives write permisions  
      swi SWI_Open            @ opens the file
      bcs error               @ Check Carry-Bit (C): if= 1 then ERROR
      ldr r1,=OutFileHandle   @ loads address of file into r1
      str r0,[r1]             @ r0 is a "pointer" to the file, r1 is a c pointer to the handle. stores name at address 
      MOV r0, r0              @ r8= outFileHandle

      @ get stack pointer to right place
      ADD sp, #64 
      MOV r12, sp             @ save this value 
      MOV r2, #48             @ keeps track of which row you are on (a, b, c, d) (each is 16) 

    outerloop:
      @keeps track of which row you are in matrix 1, inside of this you have four columns
      @ each row is multiplied by 4 columns

      @ get the right row 
      MOV sp, r12
      ADD sp, r2 
      MOV r3, sp               @ a reference to the first value in the matrix 
      SUB sp, r2              @ move sp back to top of first matrix 
      SUB sp, #16             @ go to first column of second matrix
    
      MOV r10, sp             @ store sp 
      MOV r4, #0              @ a counter to keep track of which column you are in second matrix
      MOV r7, #4              @ the variable 4 to multiply
      SUB r2, #16             @next time you will be on next row (so move pointer less)

      loop2: 
        MOV sp, r10     
        @ multiply the row by each column in second matrix
        MOV r7, #4
        MUL r7, r4, r7      @how much to move the pointer down (are you on first column, second column)
        ADD sp, r7          @ move the sp there 
        MOV r7, #4 
        MOV r1, sp          @ save this value to go back to 
        MOV r5, #0          @ counter for iterations for each value in column
        MOV r6, #0          @ sum for the column 

        loop3:
          @ this loop multiplies each value of the row to each value in the colunn
          MOV sp, r1
          MOV r7, #16 
          MUL r7, r5, r7 
          SUB sp, r7        @ move the stack pointer to right row in column
          ldr r8, [sp]        @get value in second matrix
          MOV sp, r3        @ move matrix to the first matrix
          MOV r7, #4  
          MUL r9, r5, r7    @ move the sp to right value in matrix 1 
          ADD sp, r9
          ldr r9, [sp]      @ get the value in matrix 1

          @multiply add add to sum
          MUL r7, r9, r8 
          ADD r6, r6, r7      @ keep adding to the sum

          @ change the values
          ADD r5, r5, #1      @ increment counter 
          CMP r5, #4 
          BLT loop3         @ finish the row* column
          ADD r4, r4, #1      @ next column 

          @ write the value
          @ write the value to file 
            MOV r1, r6       @ saves int
            MOV r0, r0      @ holds file handle 
            swi SWI_PrInt 

            CMP r4, #3
            BGT nospace
            @ write the space 
            MOV r0, r0      @ holds file handle 
            ldr r1,=SPACE 
            swi SWI_PrStr

            CMP r4, #4 
            BLT loop2         @ start next column
             
            MOV r0, r0         @ holds file handle 
            ldr r1,=NL         @ print a new line  
            swi SWI_PrStr

            CMP r2, #0      
            BGE outerloop   @ next row in matrix 
            BAL closematrixmultiply

  nospace:
            CMP r4, #4 
            BLT loop2         @ start next column
             
            MOV r0, r0         @ holds file handle 
            ldr r1,=NL         @ print a new line  
            swi SWI_PrStr

            CMP r2, #0      
            BGE outerloop   @ next row in matrix 
            BAL closematrixmultiply

  closematrixmultiply:
      MOV r0, r0      @ passing in file handle 
      swi SWI_Close
      BAL end3

  end3:
    bx lr
  

    .fnend
    


@@@============================================================================
@@@ compute the input count, median, sum, mean
@@@   input:   seq_in.txt
@@@
@@@  The solution will need to be push onto the stack as such:
@@@
@@@         +--------+        
@@@         | count  | <-- SP
@@@         +--------+
@@@         | median |
@@@         +--------+
@@@         | total  |
@@@         +--------+
@@@         | mean   |
@@@         +--------+
@@@


.align   8
.global  seq_ARM
.type    seq_ARM, %function

seq_ARM:
    .fnstart

    ADD sp, #96

    int_read: 
      @ open file for reading 
      ldr r0,=seq_file_in      @ loads file name into register
      mov r1,#0               @ second arg, gives read permisions  
      swi SWI_Open            @ opens the file
      bcs error3               @ Check Carry-Bit (C): if= 1 then ERROR
      ldr r1,=InputFileHandle @ loads address of file into r1
      str r0,[r1]             @ r0 is a "pointer" to the file, r1 is a c pointer to the handle. stores name at address 
      MOV r4, r0              @ r4= InFileHandle
      mov r5, #0             @ the sum tracker
      mov r7, #0             @the count tracker 

    seq_read:
      MOV r0, r4      @ passing in file handle 
      swi SWI_RdInt   @ read the integer into R0 
      mov r6, r0 
      MOV r0, r4      @ passing in file handle 
      bcs close_file      @ Check Carry-Bit (C): if= 1 then EOF reached
      str r6, [sp]    @push the value to the stack 
      ADD sp, #4
      add r5, r5, r6      @add r5 to r0, update sum 
      add r7, #1      @increase count by 1
      BAL seq_read

    close_file:
      MOV r0, r4      @ passing in file handle 
      swi SWI_Close
      bal bubble_sort 

    bubble_sort:
      sub sp, #4 @the last value position
      sub r6, r7, #1   @the number of times
      cmp r6, #0
      mov r9, sp
      beq one_median
      loop4: 
        ldr r2, [sp] @r2 = big value 
        sub sp, #4
        ldr r3, [sp] @r3 = small value 
        sub r6, r6, #1 @ decrements count 
        cmp r2,r3 @comparing 
        blt swap 
        cmp r6, #0
        bgt loop4
        bal even_odd
      swap:
        str r2, [sp]
        add sp, #4
        str r3, [sp]
        sub sp, #4
        mov sp, r9
        sub r6, r7, #1   @the number of times
        bal loop4


    even_odd:  
      mov sp, r9
      mov r8,r7       @manipulate with the count value in r8, see if odd/even
      cmp r8, #1      @ r8 ?= 1
      beq one_median @the case where there is only 1 number
      and r8, r8, #1 @ r8 = r8 LSB
      cmp r8, #0      @ r8 ?= 0 
      bne odd_median_and_store @if the count is odd
      bal even_median 

    even_median: 
      mov r3, r7
      sub r3, r3, #1
      mov r6, #4
      mul r3, r3, r6
      sub sp, r3
      mov r8, #0 @counter to loop to the correct value 
      mov r2, r7, ASR #1 @the median position : r2 = count/2 
        
        loop5:
          ldr r3, [sp] @load smaller value to r3
          add sp, #4 @add stack pointer to next value
          ldr r4, [sp] @load bigger value to r4 
          add r8, #1 @add counter by 1 
          cmp r8, r2 @compare if at correct position 
          beq calc_median_and_store @calculate the median 
          bal loop5
          
        calc_median_and_store:
          add r3, r3, r4
          mov r3, r3, ASR #1 @ r3 = r3/2 
          mov r6, #4
          mul r6, r6, r2
          sub sp, r6
          str r7, [sp] @store count 
          add sp, #4
          str r3, [sp] @store median 
          add sp, #4
          str r5, [sp] @store total 
          add sp, #4
          bal calc_mean 
    odd_median_and_store:
       mov r3, r7
       sub r3, r3, #1
       mov r6, #4
       mul r3, r3, r6
       sub sp, r3
       mov r9, r7, ASR #1 @ in case odd, r9 = r7/2, the "count" number of median 
       mov r8, #4
       mul r9, r9, r8
       add sp, r9
       ldr r2,[sp] @da median 
       add sp, r9
       str r7,[sp] @store count 
       add sp, #4
       str r2,[sp] @store median 
       add sp, #4
       str r5,[sp] @store total 
       add sp, #4
       bal calc_mean 

    one_median:
      ldr r6,[sp] @da only number 
      str r7,[sp] @store count 
      add sp, #4
      str r6,[sp] @store median
      add sp, #4
      str r5,[sp] @store total
      add sp, #4
      str r6,[sp] @store mean = median = da only value
      bal end4

    calc_mean:
      MOV R1, r5 @ the total 
      MOV R2, r7 @ the count 
      MOV R0,#0 @clear R0 to accumulate result
      MOV R3,#1 @set bit 0 in R3, which will be shifted left then right
        start1:
          CMP R2,R1
          MOVLS R2,R2,LSL#1
          MOVLS R3,R3,LSL#1
          BLS start1
          @shift R2 left until it is about to
          @be bigger than R1
          @shift R3 left in parallel in order
          @to flag how far we have to go
        next:
        CMP R1,R2 @carry set if R1&gt@R2 (don't ask why)
        SUBCS R1,R1,R2 @subtract R2 from R1 if this would
                        @give a positive answer
        ADDCS R0,R0,R3 @and add the current bit in R3 to
                      @the accumulating answer in R0
        MOVS R3,R3,LSR#1 @Shift R3 right into carry flag
        MOVCC R2,R2,LSR#1 @and if bit 0 of R3 was zero, also
                          @shift R2 right
        BCC next @If carry not clear, R3 has shifted
                @back to where it started, and we
                @can end
        end_and_store:
          str r0,[sp] @store the mean val into the stack 
          bal end4
    error3:
      mov R0, #Stdout
      ldr R1, =FileOpenInpErrMsg
      swi SWI_PrStr
      bal end4

    end4:
      bx lr 
    .fnend



@@@============================================================================
.align   8
.global  _start
.type    _start, %function

_start:
   .fnstart
   

   BL read_write_echo_ARM

   BL matrix_read_ARM

   BL matrix_mult_ARM

   BL seq_ARM
   SWI SWI_Exit

   .fnend


.data
.align
whatin_file_in:      .asciz "whatin.txt"
whatout_file_out:    .asciz "whatout.txt"
matin_file_in:        .asciz "matin.txt"
matout_file_out:     .asciz "matout.txt"
seq_file_in:     .asciz "seq_in.txt"
.align 4
InputFileHandle: .skip 4  @added
InFileHandle: .skip 4
OutFileHandle: .skip 4
InFileName: .asciz "whatin.txt"
OutFileName: .asciz "whatout.txt"
FileOpenInpErrMsg: .asciz "Failed to open input file \n"
EndOfFileMsg: .asciz "End of file reached\n"
ColonSpace: .asciz ":"
NL: .asciz " \n " @ new line
SPACE: .asciz " "
@4SPACE: .asciz "    "
@6SPACE: .asciz "      "
.end