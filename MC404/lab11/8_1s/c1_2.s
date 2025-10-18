.globl my_function

my_function:
    # Computes the sum of the first two values: SUM 1
    add t0, a0, a1

    # Calls a function called mystery_function passing SUM 1 and the first value as parameters in this order: CALL 1
    add sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    mv a1, a0
    mv a0, t0

    jal mystery_function

    mv t0, a0

    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    add sp, sp, 16

    # Computes the difference between the second value and the returned value of the mystery_function (CALL 1): DIFF 1
    sub t1, a1, t0

    # Sums the third value to the difference (DIFF 1): SUM 2
    add t2, t1, a2

    # Calls mystery_function again passing the sum above (SUM 2) and the second value as parameters in this order: CALL 2
    add sp, sp, -20
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw t2, 16(sp)
    mv a0, t2
    mv a1, a1

    jal mystery_function

    mv t3, a0

    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw t2, 16(sp)
    add sp, sp, 20

    # Computes the difference between the third value and the returned value of the mystery_function above (CALL 2): DIFF 2
    sub t3, a2, t3

    # Sums the difference above (DIFF 2) with SUM 2: SUM 3
    add a0, t2, t3

    # Return SUM 3
    ret