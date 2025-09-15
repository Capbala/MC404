.globl _start

.text
read_coords:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_coords #  buffer to write the data
    li a2, 12  # size (reads 20 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

read_times:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_times #  buffer to write the data
    li a2, 20  # size (reads 20 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_coords # buffer
    li a2, 20           # size
    li a7, 64           # syscall write (64)
    ecall
    ret

exit:
    li a0, 0  # exit code 0
    li a7, 93 # syscall exit (93)
    ecall

# Run through 4 bytes of input_coords and convert them to integers
# a0 = integer result
# a1 = input_coords
# a3 = offset (0, 5, 10, 15)
# t0 = index (0 to 4)
str_to_int:

    li a0, 0 # Initialize result to 0
    li t0, 0 # index
    add t0, a1, a3 # t0 = input_coords + offset. Uses t0 as coords to read the bytes
    li t2, 1000 # temp register to hold the decimal multiplier (1, 10, 100, 1000)

    str_to_int_loop:
        lb t1, 0(t0) # load byte from input_coords + offset + index
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
    add t0, a1, a3 # t0 = input_coords + offset. Uses t0 as coords to read the sign byte
    lb t1, 0(t0)   # load byte from input_coords + offset

    li t2, 45      # ASCII value for '-'
    beq t1, t3, int_sign_neg # if byte is '-', negate the result
    ret             # else, return the result as is

    int_sign_neg:
        neg a0, a0  # Negate the integer result
        ret

# dA = vA . tA = 300000000 x (tR - tA)
# dB = vB . tB = 300000000 x (tR - tB)
# dC = vC . tC = 300000000 x (tR - tC)
#
# y = (dA² + Yb² -dB²) / 2Yb
#
# x = + sqrt(dA² - y²) OR - sqrt(dA² - y²)

# (x - Xc)² + y² = dC² (see which value, + or -, of x gives the closest value to dC²(s9²))
calc_distances:
    # Calculate dA
    li t0, 300000000  # speed of light in m/s
    sub t1, s6, s3    # tR - tA
    mul s7, t0, t1    # dA = vA . tA = 300000000 x (tR - tA)
    # Calculate dB
    sub t1, s6, s4    # tR - tB
    mul s8, t0, t1    # dB = vB . tB = 300000000 x (tR - tB)
    # Calculate dC
    sub t1, s6, s5    # tR - tC
    mul s9, t0, t1    # dC = vC . tC = 300000000 x (tR - tC)

    # Calculate y
    mul t1, s7, s7    # dA²
    mul t2, s8, s8    # dB²
    neg t2, t2        # -dB²
    add t1, t1, t2    # dA² - dB²
    mul t2, s1, s1    # Yb²
    add t1, t1, t2    # (dA² - dB²) + Yb²
    slli t2, s1, 1    # 2Yb
    div s1, t1, t2    # y = (dA² + Yb² -dB²) / 2Yb

    # Calculate x
    mul t1, s1, s1    # y²
    mul t2, s7, s7    # dA²
    sub t2, t2, t1    # dA² - y²
    mv a0, t2         # move the value to a0 to calculate the sqrt
    call sqrt         # calculate sqrt(dA² - y²)
    mv t3, a0         # t3 = + sqrt(dA² - y²)
    neg t4, a0        # t4 = - sqrt(dA² - y²)

    # Check which x value is correct
    # For +x
    sub t1, t3, s2    # + sqrt(dA² - y²) - Xc
    mul t1, t1, t1    # (x - XC)²
    mul t2, s1, s1    # y²
    add t1, t1, t2    # t1 = (x - XC)² + y²
    mul t2, s9, s9    # dC²
    sub t1, t1, t2    # t1 = (x - XC)² + y² - dC²
    # For -x
    sub t5, t4, s2    # - sqrt(dA² - y²) - Xc
    mul t5, t5, t5    # (x - XC)²
    mul t6, s1, s1    # y²
    add t5, t5, t6    # t5 = (x - XC)² + y²
    sub t5, t5, t2    # t5 = (x - XC)² + y² - dC²

    # Compare which value, t1 or t5, is closer to 0
    # Get the absolute values of both t1 and t5
    li t6, 0          # zero
    blt t1, t6, calc_distances_abs_t1_neg
    blt t5, t6, calc_distances_abs_t5_neg
    j calc_distances_compare

    calc_distances_abs_t1_neg:
        neg t1, t1     # absolute value of t1
        j calc_distances_compare
    calc_distances_abs_t5_neg:
        neg t5, t5     # absolute value of t5
    calc_distances_compare:
        blt t1, t5, calc_distances_x_pos # if |t1| < |t5|, x = + sqrt(dA² - y²)
        mv s1, t4        # else, x = - sqrt(dA² - y²)
        ret
    calc_distances_x_pos:
        mv s1, t3        # x = + sqrt(dA² - y²)
        ret

# Store the integer in a0 as a string at output_coords + offset
# a0 = integer to store
int_to_str:
    add t0, a2, a3    # t0 = output_coords + offset
    li t1, 10         # divisor to get each digit
    li t2, 32         # space character ASCII
    li t3, 48         # ASCII '0'

    sb t2, 5(t0)      # store space at output_coords + offset + 5

    rem t2, a0, t1    # t2 = a0 % 10 (get last digit)
    add t2, t2, t3    # convert to ASCII
    sb t2, 4(t0)      # stores first digit at output_coords + offset + 4
    div a0, a0, t1    # a0 = a0 / 10 (remove last digit)

    rem t2, a0, t1    # t2 = a0 % 10 (get last digit)
    add t2, t2, t3    # convert to ASCII
    sb t2, 3(t0)      # stores second digit at output_coords + offset + 3
    div a0, a0, t1    # a0 = a0 / 10 (remove last digit)

    rem t2, a0, t1    # t2 = a0 % 10 (get last digit)
    add t2, t2, t3    # convert to ASCII
    sb t2, 2(t0)      # stores third digit at output_coords + offset + 2
    div a0, a0, t1    # a0 = a0 / 10 (remove last digit)

    rem t2, a0, t1    # t2 = a0 % 10 (get last digit)
    add t2, t2, t3    # convert to ASCII
    sb t2, 1(t0)      # stores fourth and last digit at output_coords + offset + 1

    # place sign at output_coords + offset + 0
    blt s1, zero, int_to_str_neg_sign
    li t2, 43         # ASCII '+'
    sb t2, 0(t0)      # store '+' at output_coords + offset + 0
    ret
    int_to_str_neg_sign:
        li t2, 45     # ASCII '-'
        sb t2, 0(t0)  # store '-' at output_coords + offset + 0
        ret

main:
    call read_coords # read 12 bytes of coordinates,
                     # 1 signal + 4 digits + space + 1 signal + 4 digits + newline

    # Yb coordinate
    li a3, 1        # offset for reading the first coordinate after the signal + or -
    jal str_to_int # convert the first coordinate to integer
    li a3, 0        # offset to read the signal of the first coordinate
    jal int_sign   # apply the sign to the first coordinate
    mv s1, a0       # s1 = Yb, copies the Yb coordinate to s1

    # Xc coordinate
    li a3, 7        # offset for reading the second coordinate after the signal + or -
    jal str_to_int # convert the second coordinate to integer
    li a3, 6        # offset to read the signal of the second coordinate
    jal int_sign   # apply the sign to the second coordinate
    mv s2, a0       # s2 = Xc, copies the Xc coordinate to s2

    jal read_times # read 20 bytes of times, 4 digit numbers separeted by spaces
                    # TTTT TTTT TTTT TTTT TTTT\n
    li a3, 0        # offset for reading the first time
    jal str_to_int # convert the first time to integer
    mv s3, a0       # s3 = T1, copies the first satellite time to s3

    li a3, 5        # offset for reading the second time
    jal str_to_int # convert the second time to integer
    mv s4, a0       # s4 = T2, copies the second satellite time to s4

    li a3, 10       # offset for reading the third time
    jal str_to_int # convert the third time to integer
    mv s5, a0       # s5 = T3, copies the third satellite time to s5

    li a3, 15       # offset for reading the fourth time
    jal str_to_int # convert the fourth time to integer
    mv s6, a0       # s6 = T4, copies the time stamp of wave receival to s6

    # Calculate the distances to each satellite
    #s7 = dA , s8 = dB , s9 = dC
    jal calc_distances

    # Store the result in output_coords
    la a2, output_coords # a2 = output_coords
    li a3, 0            # offset for the X coordinate (1 signal + 4 digits + space)
    mv a0, s2          # Move Xc coordinate to a0 for conversion
    jal int_to_str     # Convert X coordinate to string and store it

    li a3, 6            # offset for the Y coordinate (1 signal + 4 digits + space + 1 signal)
    mv a0, s1          # Move Yb coordinate to a0 for conversion
    jal int_to_str     # Convert Y coordinate to string and store it

    li t0, '\n'             # t0 <- 10 ('\n')
    sb t0, 11(a2)           # store newline at the end of the string

    jal write               # write the result
    jalr zero, s0, 0        # return to caller (exit)

_start:
    jal s0, main # save return address in s0 and call main
    jal exit

.bss
input_coords: .skip 12
input_times: .skip 20
output_coords: .skip 12