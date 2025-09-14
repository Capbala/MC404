.globl _start

.text
read_coords:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data
    li a2, 12  # size (reads 20 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

read_times:
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

    li a0, 0 # Initialize result to 0
    li t0, 0 # index
    add t0, a1, a3 # t0 = input_address + offset. Uses t0 as address to read the bytes
    li t2, 1000 # temp register to hold the decimal multiplier (1, 10, 100, 1000)

    str_to_int_loop:
        lb t1, 0(t0) # load byte from input_address + offset + index
        li t4, 10 # temp register to hold newline (ASCII 10)
        li t5, 32 # temp register to hold space (ASCII 32)
        beq t1, t4, str_to_int_end # if byte is newline (ASCII 10), end loop
        beq t1, t5, str_to_int_end # if byte is space (ASCII 32), end loop

        addi t1, t1, -48 # convert ASCII to integer (ASCII '0' = 48)

        mul t1, t1, t2 # multiply current result by the decimal multiplier(t2)
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

int_sign:
    add t0, a1, a3 # t0 = input_address + offset. Uses t0 as address to read the sign byte
    lb t1, 0(t0)   # load byte from input_address + offset

    li t2, 45      # ASCII value for '-'
    beq t1, t3, int_sign_neg # if byte is '-', negate the result
    ret             # else, return the result as is

    int_sign_neg:
        neg a0, a0  # Negate the integer result
        ret

main:
    call read_coords # read 12 bytes of coordinates,
                    # 1 signal + 4 digits + space + 1 signal + 4 digits + newline

    # Yb coordinate
    li a3, 1        # offset for reading the first coordinate after the signal + or -
    call str_to_int # convert the first coordinate to integer
    li a3, 0        # offset to read the signal of the first coordinate
    call int_sign   # apply the sign to the first coordinate
    mv s1, a0       # s1 = Yb, copies the Yb coordinate to s1

    # Xc coordinate
    li a3, 7        # offset for reading the second coordinate after the signal + or -
    call str_to_int # convert the second coordinate to integer
    li a3, 6        # offset to read the signal of the second coordinate
    call int_sign   # apply the sign to the second coordinate
    mv s2, a0       # s2 = Xc, copies the Xc coordinate to s2

    call read_times # read 20 bytes of times, 4 digit numbers separeted by spaces
                    # TTTT TTTT TTTT TTTT TTTT\n
    li a3, 0        # offset for reading the first time
    call str_to_int # convert the first time to integer
    mv s3, a0       # s3 = T1, copies the first satellite time to s3

    li a3, 5        # offset for reading the second time
    call str_to_int # convert the second time to integer
    mv s4, a0       # s4 = T2, copies the second satellite time to s4

    li a3, 10       # offset for reading the third time
    call str_to_int # convert the third time to integer
    mv s5, a0       # s5 = T3, copies the third satellite time to s5

    li a3, 15       # offset for reading the fourth time
    call str_to_int # convert the fourth time to integer
    mv s6, a0       # s6 = T4, copies the time stamp of wave receival to s6

    # Calculate the distances to each satellite
        



_start:
    jal s0, main
    jal exit

.bss
input_coords: .skip 12
input_times: .skip 20
output_coords: .skip 120