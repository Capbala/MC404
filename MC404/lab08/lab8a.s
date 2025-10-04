# Read a pmg image and display it on the simulator's canvas
# pmg format as follows:
# Each PGM image consists of the following:
#    1. A "magic number" for identifying the file type. A pgm image's magic number is the two characters "P5".
#    2. Whitespace (blanks, TABs, CRs, LFs).
#    3. A width, formatted as ASCII characters in decimal.
#    4. Whitespace.
#    5. A height, again in ASCII decimal.
#    6. Whitespace.
#    7. The maximum gray value (Maxval), again in ASCII decimal. Must be less than 65536, and more than zero. In this case, it will always be 255
#    8. Newline or other single whitespace character.
#    9. A raster of Height rows, in order from top to bottom. Each row consists of Width gray values, 
#       in order from left to right. Each gray value is a number from 0 through Maxval, 
#       with 0 being black and Maxval being white. Each gray value is represented in pure binary
#       by either 1 or 2 bytes. If the Maxval is less than 256, it is 1 byte. Otherwise, it is 2 bytes. 
#       The most significant byte is first. 

.globl _start

open:
    la a0, input_file
    li a1, 0
    li a2, 0
    li a7, 1024
    ecall
    ret

close:
    li a0, 3             # file descriptor (fd) 3
    li a7, 57            # syscall close
    ecall
    ret

# a2 = number of bytes to read (from main before calling read)
read:
    la a1, input_address  # buffer to write the data to
    li a7, 63             # syscall read (63)
    ecall
    ret

set_pixel:
    # a0: x coordinate
    # a1: y coordinate
    # a2: concatenated pixel's colors: R|G|B|A
    #    a2[31..24]: Red
    #    a2[23..16]: Green
    #    a2[15.. 8]: Blue
    #    a2[7 .. 0]: Alpha
    # Example:
    # pixel = 255 = 11111111b
    # red   = 11111111000000000000000000000000
    # green = 00000000111111110000000000000000
    # blue  = 00000000000000001111111100000000
    # alpha = 00000000000000000000000011111111 # although 255 is the example, alpha will always be 255
    # a2 = red | green | blue | alpha
    li a7, 2200
    ecall
    ret

set_canvas_size:
    # a0: width  (value between 0 and 512)
    # a1: height (value between 0 and 512)
    li a7, 2201
    ecall
    ret

# Only for inspection and debug purposes
# Comment function when using the simulator
# set_scaling:
#     # a0: horizontal scaling
#     # a1: vertical scaling
#     li a7, 2202
#     ecall
#     ret

exit:
    li a0, 0
    li a7, 93
    ecall

# a1: input_address
# a3: number of digits to read
# return: a0: integer value
str_to_int:
    li t0, 0          # t0 will hold the integer value
    li t1, 0          # t1 is the index for the loop
    li t2, 10         # t2 is the base (10 for decimal)
    li t4, '0'        # t4 is the ASCII value of '0'
    loop:               
        beq t1, a3, loop_end # if index equals number of digits, exit loop
        lbu t3, 0(a1)        # load byte from input_address
        sub t3, t3, t4      # convert ASCII to integer
        mul t0, t0, t2       # multiply current value by base (10)
        add t0, t0, t3       # add the new digit
        addi a1, a1, 1       # move to the next character
        addi t1, t1, 1       # increment index
        j loop                 # repeat loop
    loop_end:                # loop end
        mv a0, t0            # move result to a0
        ret

# Read from input_address with and offset a1 . Return in a0 the number of digits to read 
# Parameters:
#   a1: input_address
#   a3: offset to start reading from input_address
# Return:
#   a0: number of digits read
get_number_of_digits:

    # image = [P,5, ,X,X,X, ,Y,Y,Y, ,2,5,5,\n,RASTER\n,]

    li t0, 0          # digit counter
    add t1, a1, a3    # t1 = input_address + offset
    li t2, ' '        # whitespace character
    li t3, '\n'       # newline character

    count_loop:
        #addi t0, t0, 1    # increment digit counter
        #addi t1, t1, 1    # move to next byte
        lbu t4, 0(t1)      # load byte from input_address + offset
        beq t4, t2, end_count # if byte is whitespace, end loop
        beq t4, t3, end_count # if byte is newline, end loop
        addi t0, t0, 1    # increment digit counter
        addi t1, t1, 1    # move to next byte
        j count_loop      # repeat loop
    end_count:
        mv a0, t0          # return number of digits read in a0
        ret


# s1: width
# s2: height
# s4: address of the first pixel
# s5: return address to main
# Draw on canvas using set_pixel with:
#  a0: x coordinate
#  a1: y coordinate
#  a2: concatenated pixel's colors: R|G|B|A
draw_canvas:
    li t0, 0 # y index
    li t1, 0 # x index
    li t2, 255 # maxval
    li a2, 0 # a2 will hold the concatenated pixel's colors: R|G|B|A
    mv a3, s4 # a3 will hold the current pixel address, starting at the first pixel address

    bge t0, s2, end_draw # if y >= height, end drawing
    
    loop_y:
        li t1, 0 # reset x index for new row
        bge t1, s1, next_row # if x >= width, go to next row

        loop_x:
            lbu t2, 0(a3) # load pixel value (grayscale)
            mv a0, t1 # set x coordinate
            mv a1, t0 # set y coordinate
            li a2, 0 # reset a2 for new pixel

            slli t3, t2, 24 # shift left to position Red
            add a2, a2, t3  # add Red to a2

            slli t3, t2, 16 # shift left to position Green
            add a2, a2, t3  # add Green to a2
            
            slli t3, t2, 8  # shift left to position Blue
            add a2, a2, t3  # add Blue to a2

            addi a2, a2, 255 # set Alpha to 255 (opaque)

            jal set_pixel    # call set_pixel

            addi a3, a3, 1   # move to next pixel address
            addi t1, t1, 1   # increment x index
            bltu t1, s1, loop_x  # if x < width, repeat inner loop

        next_row:
            addi t0, t0, 1   # increment y index
            bltu t0, s2, loop_y  # if y < height, repeat outer loop

    end_draw:
    jr s5 # return to main

main:
    jal open             # open .pgm file

    li a2, 262159        # number of bytes to read
    jal read             # read .pgm file into input_address (a1)
    mv s4, a1            # s4 <- input_address

    # --- Parse width ---
    li a3, 3             # offset to first width digit ("P5 ")
    jal get_number_of_digits
    mv t5, a0            # t5 = number of digits of width

    addi a1, s4, 3       # pointer to first width digit
    mv a3, t5            # a3 = number of width digits
    jal str_to_int       # returns width in a0
    mv s1, a0            # s1 = width

    # --- Parse height ---
    li a3, 3             # offset to first height digit = 3 + width_digits + 1 (space)
    add a3, a3, t5
    addi a3, a3, 1       # a3 = [P,5,' '] + width_digits + ' ' (space)
    mv a1, s4            # a1 = input_address
    jal get_number_of_digits
    mv t6, a0            # t6 = number of digits of height

    # convert height: pointer to first height digit
    addi a1, s4, 3
    add a1, a1, t5       # a1 = input_address + P5' ' + width_digits
    addi a1, a1, 1       # a1 = pointer to first height digit
    mv a3, t6            # a3 = number of height digits
    jal str_to_int
    mv s2, a0            # s2 = height

    # --- Total offset to first pixel ---
    li t0, 9             # t0 = 9 = (P5' ' + width + ' ' + height + ' ' + 255 + '\n')
    add t0, t0, t5       # t0 = 9 + width_digits
    add t0, t0, t6       # t0 = 9 + width_digits + height_digits
    add s4, s4, t0       # s4 = input_address + offset_to_first_pixel

    # set canvas size and draw
    mv a0, s1            # a0 = width
    mv a1, s2            # a1 = height
    jal set_canvas_size

    jal s5, draw_canvas  # set s5 as return addr and call draw_canvas

    jr s0                # exit to kernel (via _start)
    
_start:
    jal s0, main
    jal exit

.bss
input_address: .skip 262159

.data
input_file: .asciz "image.pgm"

# Example of how .pgm file is to read
# XXX is the width
# YYY is the height
# 255 is the pre-defined maxval
# after \n is the pixels value that the program read and later draws on the canvas
# image = [P,5, ,X,X,X, ,Y,Y,Y, ,2,5,5,\n,0, ,0, ,12, ,12, ,0, ,15,\n,]