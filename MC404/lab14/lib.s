.globl _system_time
.globl _start

.equ GPT_TRIG, 0xFFFF0100
.equ GPT_TIME, 0xFFFF0104
.equ GPT_STOP, 0xFFFF0108

.equ MIDI_CHNL, 0xFFFF0300
.equ MIDI_ID,   0xFFFF0302
.equ MIDI_NOTE, 0xFFFF0304
.equ MIDI_VEL,  0xFFFF0305
.equ MIDI_DUR,  0xFFFF0306

.bss
    .align 4
    isr_stack:
    .skip 1024
    isr_stack_end:

.text
.align 2

gpt_set:
    # Saving context
    csrrw sp, mscratch, sp
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t1, 4(sp)


    li t0, GPT_TRIG
    li t1, 1
    sw t1, (t0)

    # Waiting for GPT to clear the trigger to signal reading completion
    gpt_busy_wait:
        lb t1, (t0)
        bnez t1, gpt_busy_wait

    # Reading time
    li t0, GPT_TIME
    lw t1, (t0)

    la t0, _system_time
    sw t1, (t0)

    li t0, GPT_STOP
    li t1, 100
    sw t1, (t0)

    # Restoring context
    lw t0, 0(sp)
    lw t1, 4(sp)
    addi sp, sp, 8
    csrrw sp, mscratch, sp

    mret

# Function prototype:
# void play_note(int ch, int inst, int note, int vel, int dur);
#                  a0       a1        a2       a3       a4
play_note:
    li t0, MIDI_CHNL
    sw a0, (t0)

    li t0, MIDI_ID
    sw a1, (t0)

    li t0, MIDI_NOTE
    sw a2, (t0)

    li t0, MIDI_VEL
    sw a3, (t0)

    li t0, MIDI_DUR
    sw a4, (t0)

    ret

_start:
    



    jal main
