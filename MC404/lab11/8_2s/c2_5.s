# Using the struct:
# typedef struct Node {
#   int a;
#   char b, c;
#   short d;
# } Node;

#Convert the following C function to assembly code, 
#using the program stack to store local variables:
# int node_creation(){
#     Node node;
#     node.a = 30;
#     node.b = 25;
#     node.c = 64;
#     node.d = -12;
#     return mystery_function(&node);
# };

.globl node_creation

node_creation:

    addi sp, sp, -12
    li t0, 30
    sw t0, 0(sp)          # node.a = 30
    li t0, 25
    sb t0, 4(sp)          # node.b = 25
    li t0, 64
    sb t0, 5(sp)          # node.c = 64
    li t0, -12
    sh t0, 6(sp)          # node.d = -12

    sw ra, 8(sp)          # Save return address

    mv a0, sp             # Pass address of node to mystery_function
    jal mystery_function   # Call mystery_function

    lw ra, 8(sp)          # Restore return address
    addi sp, sp, 12       # Deallocate local variable space
    
    ret                    # Return to caller