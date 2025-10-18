# 8.1: Write a program with a global variable named my_var of type int (32 bits), 
# initialized with the value 10 and a function void increment_my_var() 
# that increments 1 to this global variable.

.data
my_var: .word 10

.globl increment_my_var
.globl my_var

increment_my_var:
    la t0, my_var   # Load address of my_var into t0
    lw t1, 0(t0)    # Load the value of my_var into t1
    addi t1, t1, 1  # Increment the value by 1
    sw t1, 0(t0)    # Store the updated value back
    ret