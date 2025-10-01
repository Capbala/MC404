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

    #pixel = 3 = 11111111b
    #red   = 11111111000000000000000000000000
    #green = 000000001111111100000000000000000
    #blue  = 0000000000000000111111110000000000
    #alpha = 00000000000000000000000011111111
    #a2 = red | green | blue | alpha
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
set_scaling:
    # a0: horizontal scaling
    # a1: vertical scaling
    li a7, 2202
    ecall
    ret

exit:
    li a0, 0
    li a7, 93
    ecall

str_to_int:


# Read from input_address with and offset a1 . Return in a2 the number of digits to read 
# Parameters:
#   a1: input_address
#   a3: offset to start reading from input_address
# Return:
#   a2: number of digits read
get_number_of_digits:

    li t0, 0          # digit counter
    add t1, a1, a3    # t1 = input_address + offset
    li t2, ' '        # whitespace character
    li t3, '\n'       # newline character

    count_loop:
        addi t0, t0, 1    # increment digit counter
        addi t1, t1, 1    # move to next byte
        lbu t4, 0(t1)      # load byte from input_address + offset
        beq t4, t2, end_count # if byte is whitespace, end loop
        beq t4, t3, end_count # if byte is newline, end loop
        j count_loop      # repeat loop
    end_count:
        mv a0, t0          # return number of digits read in a2
        ret

main:
    jal open # open .pgm file

    li a2, 262159 # number of bytes to read
    jal read # read .pgm file and saves it in a1
             # a1 <- input_address

    li a3, 3 # offset of 3 to get width: P5 |X| Y Maxval Raster
    jal get_number_of_digits # get the amount of digits to read because X goes from 1 to 512 (1 to 3 digits)
    mv s1, a2 # s1 = number of digits of width
    


    jr s0 # -> jalr x0, s0, 0

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
# image = [P,5, ,X, ,Y,Y,Y, ,2,5,5,\n,0, ,0, ,12, ,12, ,0, ,15,\n,]