.globl _start

.text
read_coords:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_coords #  buffer to write the data
    li a2, 12  # size (reads 12 byte)
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
    li a2, 12           # size
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

int_sign:
    add t0, a1, a3 # t0 = input_coords + offset. Uses t0 as coords to read the sign byte
    lb t1, 0(t0)   # load byte from input_coords + offset

    li t2, 45      # ASCII value for '-'
    beq t1, t2, int_sign_neg # if byte is '-', negate the result
    ret             # else, return the result as is

    int_sign_neg:
        neg a0, a0  # Negate the integer result
        ret

# Calculate the square root of the number stored in a0
# Uses the 10 iterations of the Babylonian method 
# t1 = approximation
# a0 = n (number to calculate the sqrt)
# t1 = a0/2
# t1 = (t1 + a0/t1)/2
sqrt:
    li t0, 21        # Number of iterations
    li t3, 2         # Initial guess divisor
    div t1, a0, t3   # t2 = n / k_0 initial guess for the sqrt

    sqrt_loop:
        beq t0, zero, sqrt_end # If 20 iterations are done, end loop

        div t2, a0, t1  # t2 = a0 / t1 
        add t2, t2, t1  # t2 = t2 + t1
        div t1, t2, t3  # t1 = t2 / 2 (new approximation)
        addi t0, t0, -1 # decrement iteration count
        j sqrt_loop
    sqrt_end:
        mv a0, t1       # Move the result to a0
        jalr zero, s11, 0
    

# dA = vA . tA = 300000000 x (tR - tA)
# dB = vB . tB = 300000000 x (tR - tB)
# dC = vC . tC = 300000000 x (tR - tC)
#
# y = (dA² + Yb² -dB²) / 2Yb
#
# x = + sqrt(dA² - y²) OR - sqrt(dA² - y²)

# with the value of x and y, use the equation (x - Xc)² + y² = dC² to see which value, +x or -x, gives the closest value to dC²(s9²))
# by calculating the difference between the two values and dC², the smallest difference will give the correct value of x
calc_distances:
    li t0, 3        # multiplier (3)
    li t5, 10       # divisor (10)

    # Calculate dA = (3 * (tR - tA)) / 10  ------------- handle sign for integer division
    mv a0, s6
    sub a0, a0, s3     # a0 = tR - tA (ns)
    mul s7, a0, t0     # s7 = 3 * delta_ns
    blt s7, zero, calc_da_neg
    div s7, s7, t5
    j calc_da_done
    calc_da_neg:
        neg s7, s7
        div s7, s7, t5
        neg s7, s7
    calc_da_done:

    # Calculate dB = (3 * (tR - tB)) / 10
    mv a0, s6
    sub a0, a0, s4
    mul s8, a0, t0
    blt s8, zero, calc_db_neg
    div s8, s8, t5
    j calc_db_done
    calc_db_neg:
        neg s8, s8
        div s8, s8, t5
        neg s8, s8
    calc_db_done:

    # Calculate dC = (3 * (tR - tC)) / 10
    mv a0, s6
    sub a0, a0, s5
    mul s9, a0, t0
    blt s9, zero, calc_dc_neg
    div s9, s9, t5
    j calc_dc_done
    calc_dc_neg:
        neg s9, s9
        div s9, s9, t5
        neg s9, s9
    calc_dc_done:

    # Calculate y
    mv a0, s7          # a0 = dA
    mul a0, a0, s7     # a0 = dA²
    mv t1, s1          # t1 = Yb
    mul t1, t1, t1     # t1 = Yb²
    add a0, a0, t1     # a0 = dA² + Yb²
    mv t2, s8          # t2 = dB
    mul t2, t2, s8     # t2 = dB²
    sub a0, a0, t2     # a0 = dA² + Yb² - dB²

    mv t1, s1          # t1 = Yb
    slli t1, t1, 1     # t1 = 2Yb
    div a0, a0, t1     # a0 = y

    mv s10, a0         # s10 = y

    # Calculate x
    mv a0, s7          # a0 = dA
    mul a0, a0, s7     # a0 = dA²
    mv t1, s10         # t1 = y
    mul t1, t1, t1     # t1 = y²
    sub a0, a0, t1     # a0 = dA² - y²
    jal s11, sqrt      # gives a0 = + sqrt(dA² - y²), - sqrt(dA² - y²) in t3, t4

    # Check which value of x gives the closest value to dC²
    # (x - Xc)² + y² = dC² (x - Xc)² + y² -dC² = 0
    mv t3, a0          # t3 = + sqrt(dA² - y²)
    neg t4, a0         # t4 = - sqrt(dA² - y²)
    mul t5, s9, s9     # t5 = dC²

    # Recycling t1 and t2 for calculations
    li t1, 0
    li t2, 0

    # Check for +x
    sub t6, t3, s2     # t6 = x - Xc
    mul t6, t6, t6     # t6 = (x - Xc)²
    mv t1, s10         # t1 = y
    mul t1, t1, t1     # t1 = y²
    add t6, t6, t1     # t6 = (x - Xc)² + y²
    sub t6, t6, t5     # t6 = (x - Xc)² + y² - dC²

    # Check for -x
    sub t2, t4, s2     # t2 = -x - Xc
    mul t2, t2, t2     # t2 = (-x - Xc)²
    add t2, t2, t1     # t2 = (-x - Xc)² + y²
    sub t2, t2, t5     # t2 = (-x - Xc)² + y² - dC²

    # Take the absolute values of t6 and t2 by checking if they are negative, and if they are, negate them
    blt t6, zero, calc_distances_abs_t6_neg
    blt t2, zero, calc_distances_abs_t2_neg
    j calc_distances_compare
    calc_distances_abs_t6_neg:
        neg t6, t6
        blt t2, zero, calc_distances_abs_t2_neg
        j calc_distances_compare
    calc_distances_abs_t2_neg:
        neg t2, t2
    calc_distances_compare:
        blt t6, t2, calc_distances_choose_pos_x
        mv a0, t4          # a0 = - sqrt(dA² - y²)
        j calc_distances_end
    calc_distances_choose_pos_x:
        mv a0, t3          # a0 = + sqrt(dA² - y²)
    calc_distances_end:
        mv s1, a0       # s0 = x
        ret

# Store the integer in a0 as a string at output_coords + offset
# a0 = integer to store
int_to_str:
    add t0, a2, a3    # t0 = output_coords + offset  
    li t1, 10         # divisor to get each digit
    li t2, 32         # space character ASCII
    li t3, 48         # ASCII '0'

    # place sign at output_coords + offset + 0
    blt a0, zero, int_to_str_neg_sign
    li t4, 43         # ASCII '+'
    sb t4, 0(t0)      # store '+' at output_coords + offset + 0
    j int_to_str_pos_sign

    int_to_str_neg_sign:
        li t4, 45     # ASCII '-'
        sb t4, 0(t0)  # store '-' at output_coords + offset + 0
        neg a0, a0    # make a0 positive for digit extraction
        j int_to_str_pos_sign

    int_to_str_pos_sign:
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
    ret

main:
    jal read_coords # read 12 bytes of coordinates,
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
    #s0 = x , s10 = y
    jal calc_distances

    # Store the result in output_coords
    # Format: +XXXX +YYYY\n
    la a2, output_coords   # a2 <- output_address

    li a3, 0        # offset for storing the Yb coordinate
    mv a0, s1       # a0 = y coordinate
    jal int_to_str  # convert the result back to string

    li a3, 6        # offset for storing the Xc coordinate
    mv a0, s10       # a0 = x coordinate
    jal int_to_str  # convert the result back to string

    li t0, '\n'     # t0 <- 10 ('\n')
    sb t0, 11(a2)   # store newline at output_coords + offset 12

    jal write               # write the result
    jalr zero, s0, 0        # return to caller (exit)

_start:
    jal s0, main # save return address in s0 and call main
    jal exit

.bss
input_coords: .skip 12
input_times: .skip 20
output_coords: .skip 12