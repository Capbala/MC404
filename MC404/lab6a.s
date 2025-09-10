.globl __start


read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data
    li a2, 1  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, string       # buffer
    li a2, 19           # size
    li a7, 64           # syscall write (64)
    ecall

exit:
    mv a0, 0  # exit code 0
    li a7, 93 # syscall exit (93)
    ecall

str_to_int:

    li t0, 0 # holds the current value
    

sqrt:

store:


main:
    jal read
    
    la a2, output_address # a2 <- output_address

    li a3, 0  # a3 <- 0 uses the offset of 0 to take the first number of the str
    jal str_to_int
    jal sqrt
    jal store



__start:
    jal s0, main
    jal exit

.bss:
    input_address: .skip 20
    string: .skip 20