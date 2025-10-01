# Read a pmg image and display it on the simulator's canvas
# pmg format as follows:
# Each PGM image consists of the following:
#    1. A "magic number" for identifying the file type. A pgm image's magic number is the two characters "P5".
#    2. Whitespace (blanks, TABs, CRs, LFs).
#    3. A width, formatted as ASCII characters in decimal.
#    4. Whitespace.
#    5. A height, again in ASCII decimal.
#    6. Whitespace.
#    7. The maximum gray value (Maxval), again in ASCII decimal. Must be less than 65536, and more than zero.
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
    li a0, 0
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

get_number_of_digits:

draw_image:

main:
    jal open


_start:
    jal s0, main
    jal exit

.bss
input_address: .skip 262159

.data
input_file: .asciz "image.pgm"