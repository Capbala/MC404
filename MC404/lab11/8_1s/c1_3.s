# Convert the following C function to assembly code. Note: char and short values are extended to 32 bits when stored in the program stack.
# int operation(){
#     int a = 1;
#     int b = -2;
#     short c = 3;
#     short d = -4;
#     char e = 5;
#     char f = -6;
#     int g = 7;
#     int h = -8;
#     char i = 9;
#     char j = -10;
#     short k = 11;
#     short l = -12;
#     int m = 13;
#     int n = -14;
#     return mystery_function(a, b, c, d, e, f, g, h, i, j, k, l, m, n);
# }

.globl operation

operation:
    li a0, 1          # a = 1
    li a1, -2         # b = -2
    li a2, 3          # c = 3
    li a3, -4         # d = -4
    li a4, 5          # e = 5
    li a5, -6         # f = -6
    li a6, 7          # g = 7
    li a7, -8         # h = -8

    # Next values need to be passed on the stack
    li t0, 9          # i = 9
    li t1, -10        # j = -10
    li t2, 11         # k = 11
    li t3, -12        # l = -12
    li t4, 13         # m = 13
    li t5, -14        # n = -14

    # Allocate space on stack for 6 arguments and ra
    addi sp, sp, -28
    sw t0, 0(sp)      # store i
    sw t1, 4(sp)      # store j
    sw t2, 8(sp)      # store k
    sw t3, 12(sp)     # store l
    sw t4, 16(sp)     # store m
    sw t5, 20(sp)     # store n
    sw ra, 24(sp)     # save return address
    
    jal mystery_function

    lw ra, 24(sp)     # restore return address
    addi sp, sp, 28    # deallocate stack space

    ret
