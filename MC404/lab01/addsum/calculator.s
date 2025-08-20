	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0"
	.file	"calculator.c"
	.globl	exit                            # -- Begin function exit
	.p2align	2
	.type	exit,@function
exit:                                   # @exit
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a1, -12(s0)
	#APP
	mv	a0, a1	# return code
	li	a7, 93	# syscall exit (93) 
	ecall
	#NO_APP
.Lfunc_end0:
	.size	exit, .Lfunc_end0-exit
                                        # -- End function
	.globl	read                            # -- Begin function read
	.p2align	2
	.type	read,@function
read:                                   # @read
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a3, -12(s0)
	lw	a4, -16(s0)
	lw	a5, -20(s0)
	#APP
	mv	a0, a3	# file descriptor
	mv	a1, a4	# buffer 
	mv	a2, a5	# size 
	li	a7, 63	# syscall read code (63) 
	ecall	# invoke syscall 
	mv	a3, a0	# move return value to ret_val

	#NO_APP
	sw	a3, -28(s0)                     # 4-byte Folded Spill
	lw	a0, -28(s0)                     # 4-byte Folded Reload
	sw	a0, -24(s0)
	lw	a0, -24(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end1:
	.size	read, .Lfunc_end1-read
                                        # -- End function
	.globl	write                           # -- Begin function write
	.p2align	2
	.type	write,@function
write:                                  # @write
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a3, -12(s0)
	lw	a4, -16(s0)
	lw	a5, -20(s0)
	#APP
	mv	a0, a3	# file descriptor
	mv	a1, a4	# buffer 
	mv	a2, a5	# size 
	li	a7, 64	# syscall write (64) 
	ecall
	#NO_APP
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end2:
	.size	write, .Lfunc_end2-write
                                        # -- End function
	.globl	calculate                       # -- Begin function calculate
	.p2align	2
	.type	calculate,@function
calculate:                              # @calculate
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	lui	a1, %hi(buffer_in)
	addi	a0, a1, %lo(buffer_in)
	lbu	a1, %lo(buffer_in)(a1)
	addi	a1, a1, -48
	sw	a1, -12(s0)
	lbu	a1, 4(a0)
	addi	a1, a1, -48
	sw	a1, -16(s0)
	lbu	a0, 2(a0)
	sw	a0, -24(s0)                     # 4-byte Folded Spill
	li	a1, 42
	beq	a0, a1, .LBB3_5
	j	.LBB3_1
.LBB3_1:
	lw	a0, -24(s0)                     # 4-byte Folded Reload
	li	a1, 43
	beq	a0, a1, .LBB3_3
	j	.LBB3_2
.LBB3_2:
	lw	a0, -24(s0)                     # 4-byte Folded Reload
	li	a1, 45
	beq	a0, a1, .LBB3_4
	j	.LBB3_6
.LBB3_3:
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	add	a0, a0, a1
	sw	a0, -20(s0)
	j	.LBB3_6
.LBB3_4:
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	sub	a0, a0, a1
	sw	a0, -20(s0)
	j	.LBB3_6
.LBB3_5:
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	mul	a0, a0, a1
	sw	a0, -20(s0)
	j	.LBB3_6
.LBB3_6:
	lw	a0, -20(s0)
	addi	a1, a0, 48
	lui	a0, %hi(buffer_out)
	sb	a1, %lo(buffer_out)(a0)
	addi	a1, a0, %lo(buffer_out)
	li	a0, 10
	sb	a0, 1(a1)
	li	a0, 0
	sb	a0, 2(a1)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end3:
	.size	calculate, .Lfunc_end3-calculate
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	li	a0, 0
	sw	a0, -20(s0)                     # 4-byte Folded Spill
	sw	a0, -12(s0)
	lui	a1, %hi(buffer_in)
	addi	a1, a1, %lo(buffer_in)
	li	a2, 5
	call	read
	sw	a0, -16(s0)
	call	calculate
	lw	a2, -16(s0)
	lui	a1, %hi(buffer_out)
	addi	a1, a1, %lo(buffer_out)
	li	a0, 1
	call	write
	lw	a0, -20(s0)                     # 4-byte Folded Reload
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
                                        # -- End function
	.globl	_start                          # -- Begin function _start
	.p2align	2
	.type	_start,@function
_start:                                 # @_start
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	call	main
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	call	exit
.Lfunc_end5:
	.size	_start, .Lfunc_end5-_start
                                        # -- End function
	.type	buffer_in,@object               # @buffer_in
	.section	.sbss,"aw",@nobits
	.globl	buffer_in
buffer_in:
	.zero	5
	.size	buffer_in, 5

	.type	buffer_out,@object              # @buffer_out
	.globl	buffer_out
buffer_out:
	.zero	2
	.size	buffer_out, 2

	.ident	"clang version 19.1.4 (Fedora 19.1.4-1.fc41)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym exit
	.addrsig_sym read
	.addrsig_sym write
	.addrsig_sym calculate
	.addrsig_sym main
	.addrsig_sym buffer_in
	.addrsig_sym buffer_out
