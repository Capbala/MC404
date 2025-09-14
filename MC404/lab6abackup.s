.globl _start

.text
read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data
    li a2, 20  # size (reads 20 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, string       # buffer
    li a2, 20           # size
    li a7, 64           # syscall write (64)
    ecall
    ret

exit:
    li a0, 0  # exit code 0
    li a7, 93 # syscall exit (93)
    ecall

# Run through 4 bytes of input_address and convert them to integers
# a0 = integer result
# a1 = input_address
# a3 = offset (0, 5, 10, 15)
# t0 = index (0 to 4)
str_to_int:

    li a0, 0 # 
    li t0, 0 # index
    add t0, a1, a3 # t0 = input_address + offset. Uses t0 as address to read the bytes

    str_to_int_loop:
        lb t1, 0(t0) # load byte from input_address + offset + index
        li t4, 10 # temp register to hold newline (ASCII 10)
        li t5, 32 # temp register to hold space (ASCII 32)
        beq t1, t4, str_to_int_end # if byte is newline (ASCII 10), end loop
        beq t1, t5, str_to_int_end # if byte is space (ASCII 32), end loop

        addi t1, t1, -48 # convert ASCII to integer (ASCII '0' = 48)

        li t2, 1000 # temp register to hold the decimal multiplier (1, 10, 100, 1000)
        mul a0, a0, t2 # multiply current result by the decimal multiplier(t2)
        add a0, a0, t1 # add the new digit

        li t3, 10 # temp register to hold the divisor (10)
        addi t0, t0, 1 # move to the next byte
        div t2, t2, t3 # divides t2 by a factor of 10 so it can calculate the 4 digits number correctly
                       # ( 1th digit * 1000 + 2th digit * 100 + 3th digit * 10 + 4th digit * 1)
        j str_to_int_loop
    str_to_int_end:
        ret

# Calculate the square root of the number stored in a0
# Uses the 10 iterations of the Babylonian method 
# t1 = approximation
# a0 = n (number to calculate the sqrt)
# t1 = a0/2
# t1 = (t1 + a0/t1)/2
sqrt:
    li t0, 10        # Number of iterations
    li t3, 2         # Initial guess divisor
    div t1, a0, t3   # t2 = n / k_0 initial guess for the sqrt

    sqrt_loop:
        beq t0, zero, sqrt_end # If 10 iterations are done, end loop

        div t2, a0, t1  # t2 = a0 / t1 
        add t2, t2, t1  # t2 = t2 + t1
        div t1, t2, t3  # t1 = t2 / 2 (new approximation)
        addi t0, t0, -1 # decrement iteration count
        j sqrt_loop
    sqrt_end:
        mv a0, t1       # Move the result to a0
        ret

# Store the integer in a0 as a string at output_address + offset
# a0 = integer to store
int_to_str:
    add t0, a2, a3    # t0 = output_address + offset
    li t1, 10         # divisor to get each digit
    li t2, 32         # space character ASCII
    li t3, 48         # ASCII '0'

    sb t2, 4(t0)      # store space at output_address + offset + 4

    rem t2, a0, t1    # t2 = a0 % 10 (get last digit)
    add t2, t2, t3    # convert to ASCII
    sb t2, 3(t0)      # stores first digit at output_address + offset + 3
    div a0, a0, t1    # a0 = a0 / 10 (remove last digit)

    rem t2, a0, t1    # t2 = a0 % 10 (get last digit)
    add t2, t2, t3    # convert to ASCII
    sb t2, 2(t0)      # stores second digit at output_address + offset + 2
    div a0, a0, t1    # a0 = a0 / 10 (remove last digit)

    rem t2, a0, t1    # t2 = a0 % 10 (get last digit)
    add t2, t2, t3    # convert to ASCII
    sb t2, 1(t0)      # stores third digit at output_address +
    div a0, a0, t1    # a0 = a0 / 10 (remove last digit)

    rem t2, a0, t1    # t2 = a0 % 10 (get last digit)
    add t2, t2, t3    # convert to ASCII
    sb t2, 0(t0)      # stores fourth and last digit at output_address + offset + 0

    ret

main:
    call read
    
    la a2, string          # a2 <- output_address
    li a3, 0               # a3 <- offset 0 for the first number
                           # offset will be incremented by 5 for each number (4 digits + space/newline)
    
    loop:                  # loop to treat all 4 numbers
        li t0, 20          # total size of input (4 numbers of 4 digits + spaces/newline)
        beq a3, t0, loop_end # if offset == 20, all 4 numbers processed, end loop
        call str_to_int    # a0 <- integer from input_address + offset
        call sqrt          # a0 <- sqrt(a0)
        call int_to_str    # store the result in string at output_address + offset
        addi a3, a3, 5     # increment offset by 5
        j loop
    loop_end:
        li t0, 10         # newline character ASCII
        sb t0, 19(a2)     # store newline at the end of the
        call write
        ret

_start:
    call main
    call exit

.bss
input_address: .skip 20
string: .skip 20