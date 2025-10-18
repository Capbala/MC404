# Convert the following C functions to assembly code, using the program stack to store local variables.
# int fill_array_int(){
#     int array[100];
#     for (int i = 0; i < 100; i++)
#         array[i] = i;
#     return mystery_function_int(array);
# };

# int fill_array_short(){
#     short array[100];
#     for (short i = 0; i < 100; i++)
#         array[i] = i;
#     return mystery_function_short(array);
# };

# int fill_array_char(){
#     char array[100];
#     for (char i = 0; i < 100; i++)
#         array[i] = i;
#     return mystery_function_char(array);
# };

.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

fill_array_int:
    addi sp, sp, -404    # Allocate space for 100 integers (4 bytes each) + 4 bytes for ra
    li t0, 0             # i = 0
    li t2, 100

    fill_array_int_loop:
        bge t0, t2, fill_array_int_done
        slli t1, t0, 2       # t1 = i * 4
        add t1, sp, t1       # t1 = &array[i]
        sw t0, 0(t1)         # array[i] = i
        addi t0, t0, 1       # i++
        j fill_array_int_loop
    
    fill_array_int_done:
        sw ra, 400(sp)  # Save return address
        mv a0, sp      # Pass array pointer
        jal mystery_function_int
        lw ra, 400(sp)  # Restore return address
        addi sp, sp, 404 # Deallocate space
        ret
    
fill_array_short:
    addi sp, sp, -204    # Allocate space for 100 short ints (2 bytes each) + 4 bytes for ra
    li t0, 0             # i = 0
    li t2, 100

    fill_array_short_loop:
        bge t0, t2, fill_array_short_done
        slli t1, t0, 1       # t1 = i * 2
        add t1, sp, t1       # t1 = &array[i]
        sh t0, 0(t1)         # array[i] = i
        addi t0, t0, 1       # i++
        j fill_array_short_loop
    
    fill_array_short_done:
        sw ra, 200(sp)  # Save return address
        mv a0, sp      # Pass array pointer
        jal mystery_function_short
        lw ra, 200(sp)  # Restore return address
        addi sp, sp, 204 # Deallocate space
        ret

fill_array_char:
    addi sp, sp, -104   # allocate space for 100 chars (1 byte each) + 4 bytes for ra
    li t0, 0            # i = 0
    li t2, 100

    fill_array_char_loop:
        bge t0, t2, fill_array_char_done
        add t1, sp, t0      # t1 = &array[i]
        sb t0, 0(t1)        # array[i] = i
        addi t0, t0, 1      # i++
        j fill_array_char_loop
    
    fill_array_char_done:
        sw ra, 100(sp)  # Save return address
        mv a0, sp      # Pass array pointer
        jal mystery_function_char
        lw ra, 100(sp)  # Restore return address
        addi sp, sp, 104 # Deallocate space
        ret