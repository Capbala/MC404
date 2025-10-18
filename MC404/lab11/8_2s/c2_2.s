#Convert the following C functions to assembly code.
# int middle_value_int(int *array, int n){
#     int middle = n / 2;
#     return array[middle];
# };

# short middle_value_short(short *array, int n){
#     int middle = n / 2;
#     return array[middle];
# };

# char middle_value_char(char *array, int n){
#     int middle = n / 2;
#     return array[middle];
# };

# int value_matrix(int matrix[12][42], int r, int c){
#     return matrix[r][c];
# };

.globl middle_value_int
.globl middle_value_short
.globl middle_value_char
.globl value_matrix

middle_value_int:
    srli t0, a1, 1          # middle = n / 2
    slli t0, t0, 2          # middle * 4 (size of int)
    add t0, a0, t0          # address of array[middle]
    lw a0, 0(t0)            # load array[middle]
    ret

middle_value_short:
    srli t0, a1, 1          # middle = n / 2
    slli t0, t0, 1          # middle * 2 (size of short)
    add t0, a0, t0          # address of array[middle]
    lh a0, 0(t0)            # load array[middle]
    ret

middle_value_char:
    srli t0, a1, 1          # middle = n / 2
    add t0, a0, t0          # address of array[middle]
    lb a0, 0(t0)            # load array[middle]
    ret

value_matrix:
    li t0, 42                # number of columns
    mul t1, a1, t0          # r * 42
    slli t1, t1, 2          # (r * 42) * 4 (size of int)
    slli t2, a2, 2          # c * 4 (size of int)
    add t1, t1, t2          # offset = (r * 42 + c) * 4
    add t1, a0, t1          # address of matrix[r][c]
    lw a0, 0(t1)            # load matrix[r][c]
    ret

