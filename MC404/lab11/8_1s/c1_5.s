# Convert the following C function to assembly code.

# int operation(int a, int b, short c, short d, char e, char f, 
#               int g, int h, char i, char j, short k, short l, 
#               int m, int n){
#    return mystery_function(n, m, l, k, j, i, h, g, f, e, d, c, b, a);
#};

.globl operation

operation:

#   a0 = a
#   a1 = b
#   a2 = c
#   a3 = d
#   a4 = e
#   a5 = f
#   a6 = g
#   a7 = h
#   t0 = i (stack)
#   t1 = j (stack)
#   t2 = k (stack)
#   t3 = l (stack)
#   t4 = m (stack)
#   t5 = n (stack)

    lw t0, 0(sp)      # load i
    lw t1, 4(sp)      # load j
    lw t2, 8(sp)      # load k
    lw t3, 12(sp)     # load l
    lw t4, 16(sp)     # load m
    lw t5, 20(sp)     # load n

    # Stack everything (including ra) again to rearrange parameters
    addi sp, sp, -60  # make space on stack

    sw a0, 0(sp)      # store a
    sw a1, 4(sp)      # store b
    sw a2, 8(sp)      # store c
    sw a3, 12(sp)     # store d
    sw a4, 16(sp)     # store e
    sw a5, 20(sp)     # store f
    sw a6, 24(sp)     # store g
    sw a7, 28(sp)     # store h
    sw t0, 32(sp)     # store i
    sw t1, 36(sp)     # store j
    sw t2, 40(sp)     # store k
    sw t3, 44(sp)     # store l
    sw t4, 48(sp)     # store m
    sw t5, 52(sp)     # store n
    sw ra, 56(sp)     # store return address

    # Load parameters in reverse order
    lw a0, 52(sp)     # load n
    lw a1, 48(sp)     # load m
    lw a2, 44(sp)     # load l
    lw a3, 40(sp)     # load k
    lw a4, 36(sp)     # load j
    lw a5, 32(sp)     # load i
    lw a6, 28(sp)     # load h
    lw a7, 24(sp)     # load g
    lw t0, 20(sp)     # load f
    lw t1, 16(sp)     # load e
    lw t2, 12(sp)     # load d
    lw t3, 8(sp)      # load c
    lw t4, 4(sp)      # load b
    lw t5, 0(sp)      # load a

    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)
    sw t5, 20(sp)

    jal mystery_function

    lw ra, 56(sp)     # restore return address
    addi sp, sp, 60   # restore stack pointer
    
    ret
