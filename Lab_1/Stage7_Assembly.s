
        .text
        .syntax   unified

        .align  4
        .global Stage7_Assembly
        .arm


Stage7_Assembly:
		push {r4, r5, r6, r7, r8, r9, r10, r11, lr}
		sub sp, sp, #20
		mov r9, r0
		mov r10, r1
		mov r4, #0
		add r7, r1, #8
		add r5, sp, #8
		add r6, r4, r10
		add r8, r7, r4
		ldr r3, [r8, #4]
		str r3, [sp]
		ldr r3, [r7, r4]
		mov r0, r5
		ldm r6, {r1,r2}
		bl add_cal_assembly
		add r3, r4, r9
		ldm r5, {r0, r1}
		stm r3, {r0, r1}
		add r11, r3, #8
		ldr r3, [r8, #4]
		str r3, [sp]
		ldr r3, [r7, r4]
		mov r0, r5
		ldm r6, {r1, r2}
		bl sub_cal_assembly
		ldm r5, {r0, r1}
		stm r11, {r0, r1}
		add r4, r4, #16 //r4가 16씩 증가하며 뒤에 cmp와 비교준비하며 iter수를 게산
		cmp r4, #1024	//64번 반복해야하므로 16씩 64번이면 1024번
		bne Stage7_Assembly+28
		add sp, sp, #20
		pop {r4, r5, r6, r7, r8, r9, r10, r11, pc}


add_cal_assembly:
		sub sp, sp, #8
		push {r4}
		sub sp, sp, #12
		add r4, sp, #8
		stmdb r4, {r1, r2}
		str r3, [sp, #20]
		ldr r2, [sp, #24]
		ldr r1, [sp, #4]
		add r2, r1, r2
		ldr r1, [sp]
		add r3, r1, r3
		str r3, [r0]
		str r2, [r0, #4]
		add sp, sp, #12
		ldmfd sp!, {r4}
		add sp, sp, #8
		bx lr

sub_cal_assembly:
		sub sp, sp, #8
		push {r4}
		sub sp, sp, #12
		add r4, sp, #8
		stmdb r4, {r1, r2}
		str r3, [sp, #20]
		ldr r2, [sp, #24]
		ldr r1, [sp, #4]
		rsb r2, r2, r1
		ldr r1, [sp]
		rsb r3, r3, r1
		str r3, [r0]
		str r2, [r0, #4]
		add sp, sp, #12
		ldmfd sp!, {r4}
		add sp, sp, #8
		bx lr
