.equ GPS_TRIG, 0xFFFF0100
.equ GPS_X, 0xFFFF0110 
.equ GPS_Y, 0xFFFF0114 #useless in this lab
.equ GPS_Z, 0xFFFF0118
.equ STEER_DIR, 0xFFFF0120 # From -127 to 127
.equ ENGINE_PWR, 0xFFFF0121 # 1 = forward, 0 = off, -1 = backward
.equ HAND_BREAK, 0xFFFF0122 # 1 = on, 0 = off

.globl control_logic
.globl _start

.bss
    # ISR stack
    .align 4
    isr_stack:
    .skip 1024
    isr_stack_end:

    # User stack
    .align 4
    user_stack:
    .skip 1024
    user_stack_end:


.text
.align 4

int_handler:
  ###### Syscall and Interrupts handler ######

  csrrw sp, mscratch, sp # Change sp with mscratch
  addi sp, sp, -16
  sw t0, 0(sp)
  sw a0, 4(sp)
  sw a1, 8(sp)
  sw a7, 12(sp)

  # Handling
  li t0, 10
  beq a7, t0, set_steer_engine

  everything_else:
    # Unknown syscall/interrupt, just return
    j restore_and_return

  set_steer_engine:
    # Set steering direction
    li t0, STEER_DIR
    sb a1, (t0)

    # Set engine power
    li t0, ENGINE_PWR
    sb a0, (t0)

    j restore_and_return


  restore_and_return:
    csrr t0, mepc  # load return address (address of
                  # the instruction that invoked the syscall)
    addi t0, t0, 4 # adds 4 to the return address (to return after ecall)
    csrw mepc, t0  # stores the return address back on mepc
    
    # Restore registers
    lw t0, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a7, 12(sp)
    addi sp, sp, 16
    csrrw sp, mscratch, sp
    
    mret           # Recover remaining context (pc <- mepc)


.globl _start
_start:

  la t0, int_handler  # Load the address of the routine that will handle interrupts
  csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
                      # the interrupt array.

  la sp, user_stack_end  # Initialize user stack pointer

  la t0, isr_stack_end  # Initialize mscratch with ISR stack pointer
  csrw mscratch, t0

  la t0, int_handler  # Load the address of the interrupt handler
  csrw mtvec, t0      # Set mtvec to point to the interrupt handler

  # Change to user mode and jump to user_main
  csrr t1, mstatus # Read mstatus
  li t2, ~0x1800   # Clear MPP bits (bits 11 and 12)
  and t1, t1, t2   # 
  csrw mstatus, t1 # Write back to mstatus

  la t0, user_main  # Load address of user_main
  csrw mepc, t0     # Set mepc to user_main address

  mret

control_logic:
    # Horrible, terrible, cheesy and goddamn perfect logic.
    # lock the steering wheel -15 degrees to the left and voilá
    # perfect curve to the finishing line.
    li a0,1
    li a1,-15
    li a7,10
    ecall