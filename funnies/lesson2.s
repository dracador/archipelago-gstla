.syntax unified
.thumb

push {r0, r1, lr}
cmp r0, #0x0
pop {r0, pc}

push {r5, lr}

pop {r4, r5, pc} // testing
