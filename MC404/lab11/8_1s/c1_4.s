# Convert the following C function to assembly code. 
# Note: char and short values are extended to 32 bits when stored in the program stack.

# int operation(int a, int b, short c, short d, char e, char f, 
#               int g, int h, char i, char j, short k, short l, 
#               int m, int n){
#    return b + c - f + h + k - m;
#};

.globl operation

operation:

    #a1 = b
    #a2 = c
    #a5 = f
    #a7 = h
    #t2 = k (stack)
    #t4 = m (stack)

    lw t2, 8(sp)      # load k
    lw t4, 16(sp)     # load m

    add a0, a1, a2    # a0 = b + c
    sub a0, a0, a5    # a0 = a0 - f
    add a0, a0, a7    # a0 = a0 + h
    add a0, a0, t2    # a0 = a0 + k
    sub a0, a0, t4    # a0 = a0 - m

    ret