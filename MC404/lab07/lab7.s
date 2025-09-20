# Hamming (7,4) Code Encoder and Decoder
# Input: 4-bit binary number (as string): d1d2d3d4 (e.g., "1001")
# d's are data bits
# Output: 7-bit Hamming code (as string): p1p2d1p3d2d3d4 (e.g., "0011001")
# p's are parity bits

.globl _start

.text
read_bits:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_bits #  buffer to write the data
    li a2, 5  # size (reads 4 bytes + newline)
    li a7, 63 # syscall read (63)
    ecall
    ret

read_encoded:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_encoded #  buffer to write the data
    li a2, 8  # size (reads 7 bytes + newline)
    li a7, 63 # syscall read (63)
    ecall
    ret

write_encoded:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_encoded # buffer
    li a2, 8           # size
    li a7, 64           # syscall write (64)
    ecall
    ret

write_decoded:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_decoded       # buffer
    li a2, 5           # size
    li a7, 64           # syscall write (64)
    ecall
    ret

write_error:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, error_bit    # buffer
    li a2, 2           # size
    li a7, 64           # syscall write (64)
    ecall
    ret


exit:
    li a0, 0  # exit code 0
    li a7, 93 # syscall exit (93)
    ecall

main:
    # Read 4 bits from stdin in the format d1d2d3d4 and a newline
    # Example input: "1001\n" and store them in input_bits
    # Encoding will calculate parity bits and store the result in output_encoded
    # Example output: "0011001\n"
    jal read_bits

    # Load data bits from input_bits
    la t0, input_bits
    lb t1, 0(t0)  # d1
    lb t2, 1(t0)  # d2
    lb t3, 2(t0)  # d3
    lb t4, 3(t0)  # d4

    # Convert ASCII 48/'1' to binary 0/1
    li t6, 48
    sub t1, t1, t6
    sub t2, t2, t6
    sub t3, t3, t6
    sub t4, t4, t6

    # Calculate parity bits
    # p1 = d1 ^ d2 ^ d4
    xor t5, t1, t2
    xor a1, t5, t4

    # p2 = d1 ^ d3 ^ d4
    xor t5, t1, t3
    xor a2, t5, t4

    # p3 = d2 ^ d3 ^ d4
    xor t5, t2, t3
    xor a3, t5, t4

    # Store encoded bits in encoded_address as ASCII '0'/'1'
    la t0, output_encoded
    addi a1, a1, 48
    sb a1, 0(t0)   # p1
    addi a2, a2, 48
    sb a2, 1(t0)   # p2
    addi t1, t1, 48
    sb t1, 2(t0)   # d1
    addi a3, a3, 48
    sb a3, 3(t0)   # p3
    addi t2, t2, 48
    sb t2, 4(t0)   # d2
    addi t3, t3, 48
    sb t3, 5(t0)   # d3
    addi t4, t4, 48
    sb t4, 6(t0)   # d4

    li t1, '\n'
    sb t1, 7(t0)   # newline

    # Write encoded bits to stdout
    jal write_encoded

    # Clean the registers to reuse them
    li t1, 0
    li t2, 0
    li t3, 0
    li t4, 0
    li t5, 0
    li a1, 0
    li a2, 0
    li a3, 0

    # Read encoded bits from stdin
    # Read 7 bits in the format p1p2d1p3d2d3d4 and a newline
    # Example input: "1011001\n"
    # Decoding is basically taking only the data bits d1, d2, d3, d4
    # and ignoring the parity bits p1, p2, p3
    jal read_encoded

    la t0, input_encoded
    lb t1, 2(t0)  # d1
    lb t2, 4(t0)  # d2
    lb t3, 5(t0)  # d3
    lb t4, 6(t0)  # d4

    # Store decoded bits in output_decoded as ASCII '0'/'1'
    la t0, output_decoded
    sb t1, 0(t0)   # d1
    sb t2, 1(t0)   # d2
    sb t3, 2(t0)   # d3
    sb t4, 3(t0)   # d4

    li t1, '\n'
    sb t1, 4(t0)   # newline

    # Write decoded bits to stdout
    jal write_decoded

    # Detect if there is an error in the received encoded bits
    # Error detection is done by recalculating the parity bits
    # and comparing them with the received parity bits
    # We take the d1,d2,d3,d4 from input_encoded
    # and recalculate p1, p2, p3 doing the same process as in encoding
    # Then we compare the recalculated p1, p2, p3 with the received
    # p1, p2, p3 from input_encoded
    # If they are different, there is an error in the received bits
    # We will output '0' if no error, '1' if there is an error
    # Example input: "0011001\n" (no error) -> output "0\n"
    # Example input: "1111001\n" (error in p1) -> output "1\n"

    # load received bits from input_encoded
    # d1, d2, d3, d4 are already loaded in t1, t2, t3, t4
    # p1, p2, p3
    la t0, input_encoded
    lb a1, 0(t0)  # p1
    lb a2, 1(t0)  # p2
    lb a3, 3(t0)  # p3
    lb t1, 2(t0)  # d1
    lb t2, 4(t0)  # d2
    lb t3, 5(t0)  # d3
    lb t4, 6(t0)  # d4

    # Convert ASCII to binary 0/1
    sub a1, a1, t6
    sub a2, a2, t6
    sub a3, a3, t6
    sub t1, t1, t6
    sub t2, t2, t6
    sub t3, t3, t6
    sub t4, t4, t6

    # Recalculate parity bits
    # p1 = d1 ^ d2 ^ d4
    xor t5, t1, t2
    xor a4, t5, t4
    # p2 = d1 ^ d3 ^ d4
    xor t5, t1, t3
    xor a5, t5, t4
    # p3 = d2 ^ d3 ^ d4
    xor t5, t2, t3
    xor a6, t5, t4

    # Compare recalculated p1, p2, p3 with received p1, p2, p3
    xor t1, a1, a4  # a7 = 0 if p1 matches
    xor t2, a2, a5  # a8 = 0 if p2 matches
    xor t3, a3, a6  # a9 = 0 if p3 matches    

    # If any of t1, t2, t3 is 1, there is an error
    li t4, 0
    or t4, t1, t2
    or t4, t4, t3

    # Convert to ASCII '0'/'1'
    addi t4, t4, 48

    # Store error bit in error_bit
    la t0, error_bit
    #li t4, 'X'      # for debug purposes
    sb t4, 0(t0)   # error bit
    li t1, '\n'
    sb t1, 1(t0)   # newline

    # Write error bit to stdout
    jal write_error

    jalr zero, s0, 0

_start:
    jal s0, main
    call exit

.bss
input_bits: .space 5          # 4 bits + newline
input_encoded: .space 8          # 7 bits + newline
output_encoded: .space 8         # 7 bits + newline
output_decoded: .space 5         # 4 bits
error_bit: .space 2            # 1 bit + newline