# This program reads a signed integer from standard input,
# converts it to an integer, and search a linked list that each node contains 2 values and a pointer 
# to the next node. It then calculates the sum of the two values in each node and compares it to the input integer.
# If a match is found, it outputs the index of that node (0-based) to standard output.
# If no match is found, it outputs -1.

.globl _start

read_number:
    li a0, 0    # file descriptor = 0 (stdin)
    la a1, input_number #  buffer to write the data
    li a2, 7    # size (reads up to 7 bytes) "sign + 5 digits + newline"
    li a7, 63   # syscall read (63)
    ecall
    ret

write_index:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_buffer # buffer
    li a2, 2            # size (index + newline)
    li a7, 64           # syscall write (64)
    ecall
    ret

exit:
    li a0, 0  # exit code 0
    li a7, 93 # syscall exit (93)
    ecall

get_sign:
    lb t0, 0(a1)         # load byte from input_number
    li t1, '-'           # temp register to hold '-'
    beq t0, t1, negative # if byte is '-', number is negative

    li a0, 1             # positive sign
    ret

    negative:
        li a0, -1        # negative sign
        addi a1, a1, 1   # move to the next byte, skipping the '-'
        ret

get_number_of_digits:
    li a0, 0 # Initialize number of digits to 0
    li t0, 0 # index

    loop:
        lb t1, 0(a1)    # load byte from input_number + index
        li t2, 10       # temp register to hold newline (ASCII 10)
        beq t1, t2, loop_end # if byte is newline (ASCII 10), end loop

        addi a0, a0, 1  # increment number of digits
        addi a1, a1, 1  # move to the next byte
        j loop

    loop_end:
        ret

# a1: input_address
# a3: number of digits to read
# return: a0: integer value
str_to_int:
    li t0, 0          # t0 will hold the integer value
    li t1, 0          # t1 is the index for the loop
    li t2, 10         # t2 is the base (10 for decimal)
    li t4, '0'        # t4 is the ASCII value of '0'

    loop:               
        beq t1, a3, loop_end # if index equals number of digits, exit loop
        lbu t3, 0(a1)        # load byte from input_address
        sub t3, t3, t4       # convert ASCII to integer
        mul t0, t0, t2       # multiply current value by base (10)
        add t0, t0, t3       # add the new digit
        addi a1, a1, 1       # move to the next character
        addi t1, t1, 1       # increment index
        j loop               # repeat loop

    loop_end:                # loop end
        mv a0, t0            # move result to a0
        ret

main:
    jal read_number # a0 = input_number
    mv a1, a0       # move input to a1 for processing

    # Take the sign of the number and store it in a2 as -1 or 1 for multiplication later
    jal get_sign    # a0 = sign (1 for positive, -1 for negative)
    mv a2, a0       # move sign to a2

    # Take the number of digits
    jal get_number_of_digits # a0 = number of digits
    mv a3, a0       # move number of digits to a3

    # Convert the string to an integer
    jal str_to_int  # a0 = integer value of the number
    mul a0, a0, a2  # apply the sign to the integer value
    mv s1, a0       # store the final signed integer value in s1



_start:
    jal s0, main
    call exit

.bss
input_number: .skip 8