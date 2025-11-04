# This lab is a communication with the Serial Port via MMIO.
# It will read from input and perform the operation requested:

    # Operation 1: read a string and write it back to Serial Port
    #     Input: 1\n{string with variable size}\n
    #     Output: {string with variable size}\n
    # Operation 2: read a string and write it back to Serial Port reversed
    #     Input: 2\n{string with variable size}\n
    #     Output: {string with variable size reversed}\n
    # Operation 3: read a number in decimal representation and write it back in hexadecimal representation.
    #     Input: 3\n{decimal number with variable size}\n
    #     Output: {number in hexadecimal}\n
    # Operation 4: read a string that represents an algebraic expression, compute the expression and write the result to Serial Port.
    #     Input: 4\n{number with variable size} {operator} {number with variable size}\n
    #     Output: {operation result in decimal representation}\n
    #     Operator can be + (add) , - (sub), * (mul) or / (div)


.globl _start

# Serial port adresses
.equ WRITE_TRIG, 0xFFFF0100 # Trigger write
.equ WRITE_BYTE, 0xFFFF0101 # Byte to write
.equ READ_TRIG, 0xFFFF0102  # Trigger read
.equ READ_BYTE, 0xFFFF0103  # Byte read

# Converts an integer to a string in the specified base
# In this case, we will only handle base 10 and 16
# Tests won't be case-sensitive
# Hexadecimals base are considered unsigned
# Parameters:
# a0: integer value
# a1: pointer to the buffer
# a2: base (10 or 16)
itoa:
    mv t0, a1       # Copies the address of the buffer to t0 for later use
    mv t6, a1       # Copy buffer pointer to t6 for restoring later
    bltz a0, handle_negative # If number is negative, handle it

    j loop_itoa

    handle_negative:
        li t1, '-'      # Load '-' character
        sb t1, 0(a1)    # Store '-' at the beginning of the buffer
        addi a1, a1, 1  # Move buffer pointer to the next position
        addi t0, t0, 1  # Move the start pointer forward
        neg a0, a0      # Make the number positive

    loop_itoa:
        rem t1, a0, a2  # Get remainder (next digit)
        li t2, 10
        blt t1, t2, decimal_loop # If digit < 10, it's a decimal digit
        
        hex_loop:
            addi t1, t1, 'a' # Convert to ASCII for hex (a-f)
            addi t1, t1, -10 # Adjust for hex offset
            sb t1, 0(a1)    # Store character in buffer
            addi a1, a1, 1  # Move buffer pointer forward
            div a0, a0, a2  # Divide number by base
            bnez a0, loop_itoa # Repeat until number is 0
            j reverse_string

        decimal_loop:
            addi t1, t1, '0' # Convert to ASCII
            sb t1, 0(a1)    # Store character in buffer
            addi a1, a1, 1  # Move buffer pointer forward
            div a0, a0, a2  # Divide number by 10
            bnez a0, loop_itoa # Repeat until number is 0
            j reverse_string
    
    reverse_string:
        # Now reverse the string in the buffer
        mv t2, a1       # t2 points to the end of the string
        addi t2, t2, -1 # Move back to last character (not null terminator)
        mv t3, t0       # t3 points to the start of the string
        blt t3, t2, reverse_loop # While start < end
        j null_terminate

        reverse_loop:
            lb t4, 0(t3)    # Load byte at start
            lb t5, 0(t2)    # Load byte at end
            sb t5, 0(t3)    # Store end byte at start
            sb t4, 0(t2)    # Store start byte at end
            addi t3, t3, 1  # Move start forward
            addi t2, t2, -1 # Move end backward
            blt t3, t2, reverse_loop # Repeat while start < end
            j null_terminate
            
        null_terminate:
            sb zero, 0(a1)  # Null-terminate the string
            mv a0, t6       # Move original buffer pointer to a0 for return
            ret

# Converts a string to an integer
atoi:
    li t0, 0    # Initialize result to 0
    li t1, 1    # Initialize sign to positive

    # Check for negative sign
    lb t2, 0(a0)    # Load first character
    li t3, '-'      # Load '-' character
    beq t2, t3, is_negative # If first character is '-', set sign to negative

    j convert_loop  # Otherwise, start conversion loop

    is_negative:
        li t1, -1       # Set sign to negative
        addi a0, a0, 1  # Move to the next character
    
    convert_loop:
        lb t2, 0(a0)    # Load current character
        li t3, 10       # Load newline (ASCII 10)
        beq t2, zero, convert_end # If character is null, end conversion

        li t4, '0'      # Load ASCII value of '0'
        sub t2, t2, t4  # Convert ASCII to integer (char - '0')
        mul t0, t0, t3  # Multiply current result by 10 (shift left)
        add t0, t0, t2  # Add the new digit

        addi a0, a0, 1  # Move to the next character
        j convert_loop   # Repeat the loop

    convert_end:
        mul t0, t0, t1  # Apply sign to the result
        mv a0, t0       # Move result to a0
        ret   

# Read the number {1,2,3,4} from serial port and return the value in a0
# Input will be as: {number}\n

read_operation:
    li t0, READ_TRIG
    li t1, 1
    sb t1, 0(t0)        # Trigger read
    
     

operation_1:
    #TO DO
    ret

operation_2:
    #TO DO
    ret

operation_3:
    #TO DO
    ret

operation_4:
    #TO DO
    ret

main:
    # save ra address in stack
    addi sp, sp, -4
    sw ra, 0(sp)

    #...

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

_start:
    jal main
    jal exit

exit:
    li a0, 0
    li a7, 93
    ecall

.bss
input_buffer: .skip 1000
output_buffer: .skip 1000