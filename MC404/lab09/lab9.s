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
    # a2 = size (number of digits + newline) defined in main
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
    mv t3, a1
    li a0, 0 # Initialize number of digits to 0
    li t0, 0 # index

    loop:
        lb t1, 0(t3)    # load byte from input_number + index
        li t2, 10       # temp register to hold newline (ASCII 10)
        beq t1, t2, loop_end # if byte is newline (ASCII 10), end loop

        addi a0, a0, 1  # increment number of digits
        addi t3, t3, 1  # move to the next byte
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

    loop1:               
        beq t1, a3, loop_end1 # if index equals number of digits, exit loop
        lbu t3, 0(a1)        # load byte from input_address
        sub t3, t3, t4       # convert ASCII to integer
        mul t0, t0, t2       # multiply current value by base (10)
        add t0, t0, t3       # add the new digit
        addi a1, a1, 1       # move to the next character
        addi t1, t1, 1       # increment index
        j loop1               # repeat loop

    loop_end1:                # loop end
        mv a0, t0            # move result to a0
        ret

parse_list:
    la t0, head_node # load address of head_node
    li t1, 0         # index = 0

    parse_loop:
        lw t2, 0(t0)     # load first value of the node
        lw t3, 4(t0)     # load second value of the node
        lw t4, 8(t0)     # load pointer to next node

        add t5, t2, t3   # sum the two values

        beq t5, s2, found_match # if sum equals input number, found a match

        beqz t4, not_found       # if next node pointer is null (0), end of list reached

        mv t0, t4                # move to the next node
        addi t1, t1, 1           # increment index
        j parse_loop             # repeat loop
    found_match:
        mv a0, t1                # move index to a0 for return
        ret
    not_found:
        li a0, -1                 # no match found, return -1
        ret

int_to_str:
    li t0, -1
    
    beq a0, t0, store_negative # if a0 is -1, store "-1\n"

    la t0, int_unsigned 
    li t1, 10
    li t2, 0

    loop2:
        rem t3, a0, t1       # t3 = a0 % 10
        addi t3, t3, 48      # convert to ASCII
        sb t3, (t0)          # store digit in buffer
        div a0, a0, t1       # a0 = a0 / 10
        addi t2, t2, 1       # increment digit count
        addi t0, t0, 1       # move to next position in buffer
        bnez a0, loop2       # repeat until a0 is 0
    
    # Now t2 has the number of digits, and the digits are in reverse order in int_unsigned
    # Reversing the digits into output_buffer
    mv a2, t2                # a2 = number of digits
    addi a2, a2, 1           # a2 = number of digits + 1 (for newline)
    addi t2, t2, -1          # adjust for 0-based index
    la t0, int_unsigned
    la t1, output_buffer
    add t3, t0, t2           # point t3 to the last digit in int_unsigned

    reverse_loop:
        lb t4, (t3)
        sb t4, (t1)
        addi t1, t1, 1
        addi t3, t3, -1
        addi t2, t2, -1
        bgez t2, reverse_loop  # continue until all digits are reversed

    # Append newline
    li t2, 10
    sb t2, (t1)
    ret

    store_negative:
        la t0, output_buffer
        li t1, '-'           # ASCII '-'
        li t2, '1'           # ASCII '1'
        li t3, 10            # ASCII newline

        sb t1, 0(t0)         # store '-'
        sb t2, 1(t0)         # store '1'
        sb t3, 2(t0)         # store newline

        li a2, 3             # number of bytes to write
        ret


main:
    jal read_number # a0 = input_number
    mv s4, a1
    # Take the sign of the number and store it in a2 as -1 or 1 for multiplication later
    jal get_sign    # a0 = sign (1 for positive, -1 for negative)
    mv s3, a0       # move sign to a2

    # Take the number of digits
    jal get_number_of_digits # a0 = number of digits
    mv a3, a0       # move number of digits to a3

    # Convert the string to an integer
    jal str_to_int  # a0 = integer value of the number
    mv s1, a0       # move unsigned integer value to s1
    mul a0, a0, s3  # apply the sign to the integer value
    mv s2, a0       # move signed integer value to s1

    jal parse_list # find a match in the linked list, return index or -1 in a0
    
    # Convert index to string and store in output_buffer
    jal int_to_str  # a0 = index as string in output_buffer

    jal write_index # write the output_buffer to stdout

    jr s0          # return to caller (exit)

_start:
    jal s0, main
    call exit

.bss
input_number: .skip 7
output_buffer: .skip 5 # sign + 3 digits + newline

# Will be used when converting the unsigned integer to string
int_unsigned: .skip 3