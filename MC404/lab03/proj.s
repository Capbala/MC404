	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0_zmmul1p0"
	.file	"proj.c"
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
.Lfunc_end0:
	.size	read, .Lfunc_end0-read
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
.Lfunc_end1:
	.size	write, .Lfunc_end1-write
                                        # -- End function
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
.Lfunc_end2:
	.size	exit, .Lfunc_end2-exit
                                        # -- End function
	.globl	decimal_to_binary               # -- Begin function decimal_to_binary
	.p2align	2
	.type	decimal_to_binary,@function
decimal_to_binary:                      # @decimal_to_binary
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	li	a0, 0
	sw	a0, -20(s0)
	sw	a0, -24(s0)
	j	.LBB3_1
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -12(s0)
	lw	a1, -24(s0)
	add	a0, a0, a1
	lbu	a0, 0(a0)
	li	a1, 0
	sw	a1, -28(s0)                     # 4-byte Folded Spill
	beqz	a0, .LBB3_3
	j	.LBB3_2
.LBB3_2:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -24(s0)
	add	a0, a0, a1
	lbu	a0, 0(a0)
	addi	a0, a0, -10
	snez	a0, a0
	sw	a0, -28(s0)                     # 4-byte Folded Spill
	j	.LBB3_3
.LBB3_3:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -28(s0)                     # 4-byte Folded Reload
	andi	a0, a0, 1
	beqz	a0, .LBB3_5
	j	.LBB3_4
.LBB3_4:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -20(s0)
	li	a1, 10
	mul	a1, a0, a1
	lw	a0, -12(s0)
	lw	a2, -24(s0)
	add	a0, a0, a2
	lbu	a0, 0(a0)
	add	a0, a0, a1
	addi	a0, a0, -48
	sw	a0, -20(s0)
	lw	a0, -24(s0)
	addi	a0, a0, 1
	sw	a0, -24(s0)
	j	.LBB3_1
.LBB3_5:
	li	a0, 31
	sw	a0, -24(s0)
	j	.LBB3_6
.LBB3_6:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -24(s0)
	bltz	a0, .LBB3_9
	j	.LBB3_7
.LBB3_7:                                #   in Loop: Header=BB3_6 Depth=1
	lw	a0, -20(s0)
	srli	a1, a0, 31
	add	a1, a0, a1
	andi	a1, a1, -2
	sub	a0, a0, a1
	lw	a1, -16(s0)
	lw	a2, -24(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sw	a0, 0(a1)
	lw	a0, -20(s0)
	srli	a1, a0, 31
	add	a0, a0, a1
	srai	a0, a0, 1
	sw	a0, -20(s0)
	j	.LBB3_8
.LBB3_8:                                #   in Loop: Header=BB3_6 Depth=1
	lw	a0, -24(s0)
	addi	a0, a0, -1
	sw	a0, -24(s0)
	j	.LBB3_6
.LBB3_9:
	li	a0, 0
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end3:
	.size	decimal_to_binary, .Lfunc_end3-decimal_to_binary
                                        # -- End function
	.globl	binary_to_string                # -- Begin function binary_to_string
	.p2align	2
	.type	binary_to_string,@function
binary_to_string:                       # @binary_to_string
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	lw	a1, -16(s0)
	li	a0, 48
	sb	a0, 0(a1)
	lw	a1, -16(s0)
	li	a0, 98
	sb	a0, 1(a1)
	li	a0, 0
	sw	a0, -20(s0)
	j	.LBB4_1
.LBB4_1:                                # =>This Inner Loop Header: Depth=1
	lw	a1, -20(s0)
	li	a0, 31
	blt	a0, a1, .LBB4_4
	j	.LBB4_2
.LBB4_2:                                #   in Loop: Header=BB4_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -20(s0)
	slli	a2, a1, 2
	add	a0, a0, a2
	lw	a0, 0(a0)
	addi	a0, a0, 48
	lw	a2, -16(s0)
	add	a1, a1, a2
	sb	a0, 2(a1)
	j	.LBB4_3
.LBB4_3:                                #   in Loop: Header=BB4_1 Depth=1
	lw	a0, -20(s0)
	addi	a0, a0, 1
	sw	a0, -20(s0)
	j	.LBB4_1
.LBB4_4:
	lw	a1, -16(s0)
	li	a0, 10
	sb	a0, 35(a1)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end4:
	.size	binary_to_string, .Lfunc_end4-binary_to_string
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -224
	sw	ra, 220(sp)                     # 4-byte Folded Spill
	sw	s0, 216(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 224
	li	a0, 0
	sw	a0, -12(s0)
	addi	a1, s0, -32
	li	a2, 20
	call	read
	sw	a0, -36(s0)
	lbu	a0, -32(s0)
	sw	a0, -204(s0)                    # 4-byte Folded Spill
	li	a1, 45
	beq	a0, a1, .LBB5_3
	j	.LBB5_1
.LBB5_1:
	lw	a0, -204(s0)                    # 4-byte Folded Reload
	li	a1, 48
	bne	a0, a1, .LBB5_4
	j	.LBB5_2
.LBB5_2:
	j	.LBB5_5
.LBB5_3:
	j	.LBB5_5
.LBB5_4:
	addi	a0, s0, -32
	addi	a1, s0, -164
	sw	a1, -212(s0)                    # 4-byte Folded Spill
	call	decimal_to_binary
                                        # kill: def $x11 killed $x10
	lw	a0, -212(s0)                    # 4-byte Folded Reload
	addi	a1, s0, -199
	sw	a1, -208(s0)                    # 4-byte Folded Spill
	call	binary_to_string
	lw	a1, -208(s0)                    # 4-byte Folded Reload
	li	a0, 1
	li	a2, 35
	call	write
	j	.LBB5_5
.LBB5_5:
	li	a0, 0
	lw	ra, 220(sp)                     # 4-byte Folded Reload
	lw	s0, 216(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 224
	ret
.Lfunc_end5:
	.size	main, .Lfunc_end5-main
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
.Lfunc_end6:
	.size	_start, .Lfunc_end6-_start
                                        # -- End function
	.ident	"clang version 19.1.4 (Fedora 19.1.4-1.fc41)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym read
	.addrsig_sym write
	.addrsig_sym exit
	.addrsig_sym decimal_to_binary
	.addrsig_sym binary_to_string
	.addrsig_sym main
