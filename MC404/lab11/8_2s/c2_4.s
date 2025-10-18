# Using the struct:
# typedef struct Node {
#   int a;
#   char b, c;
#   short d;
# } Node;

# Convert the following C function to assemble code
# int node_op(Node *node){
#     return node->a + node->b - node->c + node->d;
# };

.globl node_op

node_op:
    lw t0, 0(a0)        # Load node->a into t0
    lb t1, 4(a0)        # Load node->b into t1
    lb t2, 5(a0)        # Load node->c into t2
    lh t3, 6(a0)        # Load node->d into t3

    add t0, t0, t1      # t0 = node->a + node->b
    sub t0, t0, t2      # t0 = t0 - node->c
    add t0, t0, t3      # t0 = t0 + node->d

    mv a0, t0           # Move result to a0 for return
    
    ret