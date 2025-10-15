# Lab 9 but ABI compliant and with the following implemented functions:
# puts ( const char * str )
# gets ( char * str )
# atoi ( const char * str )
# itoa ( int value, char * str, int base )

.globl exit
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl linked_list_search

# Writes the string to the stdout and appends a newline character ('\n')
# Parameters:
# a0: pointer to the string
puts:
    # Get the length of the string
    mv t0, a0      # Move the pointer to t0
    mv t3, a0      # Copy pointer to t3 for later use
    li t1, 0       # Initialize length counter to 0

    # Loop until we find the null terminator
    write_loop:
        lb t2, 0(t0)    # Load byte at address t0
        beq t2, zero, write_newline # If byte is null terminator, exit loop
        addi t1, t1, 1  # Increment length counter
        addi t0, t0, 1  # Move to the next byte
        j write_loop            # Repeat the loop
    
    # Add newline character to the length and write to stdout
    write_newline: 
        mv a1, a0       # pointer to the string
        li a0, 1        # file descriptor = 1 (stdout)
        mv a2, t1       # size (length of string + newline)
        li a7, 64       # syscall write (64)
        ecall

        addi sp, sp, -4  # Allocate space on stack for newline character
        li t0, '\n'      # Load newline character into t0
        sb t0, 0(sp)     # Store newline character on stack
        # Write the newline character
        li a0, 1        # file descriptor = 1 (stdout)
        mv a1, sp       # pointer to the newline character
        li a2, 1        # size = 1
        li a7, 64       # syscall write (64)
        ecall

        addi sp, sp, 4   # Deallocate space on stack
        mv a0, t3       # Move original string pointer back to a0 for return
        ret

# Reads a line from stdin, until newline, and copies it into the buffer, null-terminating it
# Parameters:
# a0: pointer to the buffer
gets:
    mv t0, a0   # Move buffer pointer to t0
    mv t4, a0
    li t1, 0    # Initialize index to 0
    li t3, '\n' # Newline character

    # Read characters until newline
    read_loop:
        li a0, 0        # file descriptor = 0 (stdin)
        mv a1, t0       # move the address + offset to a1 to write the data
        li a2, 1        # Read one byte at a time
        li a7, 63       # syscall read (63)
        ecall

        lb t2, 0(t0)    # Load the byte read into t2
        beq t2, t3, read_end # If byte is newline, exit loop
        addi t0, t0, 1  # Move to the next byte in the buffer
        j read_loop     # Repeat the loop
    
    read_end:
        sb zero, 0(t0)  # Null-terminate the string
        mv a0, t4       # Move the original buffer pointer to a0 for return
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

# Almost same function as lab9, but now it is ABI compliant
# Parameters:
# a0: pointer to the head of the linked list
# a1: integer value to search for
# Returns:
# a0: pointer to the node containing the value, or -1 if not found
linked_list_search:
    mv t0, a0        # load address of head_node
    li t1, 0         # index = 0

    parse_loop:
        lw t2, 0(t0)     # load first value of the node
        lw t3, 4(t0)     # load second value of the node
        lw t4, 8(t0)     # load pointer to next node

        add t5, t2, t3   # sum the two values

        beq t5, a1, found_match # if sum equals input number, found a match

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

exit:
    li a0, 0  # exit code 0
    li a7, 93 # syscall exit (93)
    ecall