.syntax unified
.thumb
.balign 4
@offset = 09006300
@  string[0xE38] <- "An item appears before you..."

_dataScriptx19:
push {r0, lr}
bl funcCheckBuffer
cmp r0, #0x0
bne _abortScript
pop {r0}
bl _thunkDataScriptx19
pop {pc}

.hword 0x0

_thunkDataScriptx19:
ldr r4, [pc, #0x0]
bx r4
.word 0x08027065

_dataScriptx1F:
push {r0, lr}
bl funcCheckBuffer
cmp r0, #0x0
bne _abortScript
pop {r0}
bl _thunkDataScriptx1F
pop {pc}

_abortScript:
pop {r0, pc}

_thunkDataScriptx1F:
ldr r4, [pc, #0x0]
bx r4
.word 0x08027E21

funcCheckBuffer:
push {r5, lr}

ldr r1, ptrItemBuffer
ldrh r0, [r1, #0x0]
cmp r0, #0x0
bne tempSkip
b end // workaround, branch too long otherwise

tempSkip:
movs r5, r0
bl thunkStartCutscene
bl thunkGetPartyLeader
bl thunkSetNpcStateIdle

movs r0, #0xE
lsls r0, #0x8
adds r0, #0x38
movs r1, #0x0
bl thunkShowStatusBox

// djinn start
// check if djinn
movs r1, #0xB
movs r0, r5
lsrs r0, r0, #0x8
cmp r0, r1
bne notDjinn

// do djinn things
movs r0, #0xE // just always starts with that?
lsls r0, #0x8
adds r0, #0x30
movs r1, #0x0
bl thunkShowStatusBox

// TODO: doesn't trigger any cutscene/textbox itself...
// Djinn(element=<ElementType.Earth: 0>, index=0, name='Flint') == 0xB00
// Djinn(element=<ElementType.Water: 1>, index=12, name='Steam') == 0xB2C
// Djinn(element=<ElementType.Air: 3>, index=6, name='Luff') == 0xB66
//    # (number >> 5) & 0b11  # (or 0x3) for the element
//    # number & 0b11111  # (or 0x1F) for the index

// r5 is 0xB00

// element
movs r0, r5
lsrs r0, r0, #0x5
movs r2, #0x3
ands r0, r2
// r0 should be the proper element now

// djinndex
movs r1, r5
movs r2, #0x1F
ands r1, r2
bl thunkAddDjinn
cmp r0, #0x0
blt skip

// r0 is the returned value of add_djinn() now, which can be either -1 or 0-7 (either already obtained or char index)

// 2E = Venus, 2F = Merc, 30 = Mars, 31 = Jup
// order seems to be char, ele, index or ele, char, index
// movs r2, r1
// movs r1, r0
// movs r0, #0x4
// Felix, and correct djinns?
// nope, lol, Jupiter icon and text was "0 mercury"

// do r0 and r1 stay? doesnt seems like it

// DUMP, doc says 02000F80 probably unused
ldr r3, ptrDebugDump
str r0, [r3, #0x0]
str r1, [r3, #0x4]
str r2, [r3, #0x8]

// r0=00000004 r1=FFFFFFFF r2=00000000 -> 0xB00 (Felix and Isaac joined your party)
// r0=00000004 r1=00000004 r2=02000040 -> 0xB01 (Felix can now summon Faiff to he synttt tag!) lmao
// r0=00000004 r1=00000007 r2=02000040 -> 0xB02 (Jupiter icon and text was "0 mercury")

// gotta unpack again then :/ (but this time via r3, we need r2, also r0=r1, r1=r2, r0 has to be the return value)
// element
movs r1, r5
lsrs r1, r1, #0x5
movs r3, #0x3
ands r1, r3

// djinndex
movs r2, r5
movs r3, #0x1F
ands r2, r3

bl thunkShowDjinnStatusBox
b skip

// djinn end
notDjinn:
// check if mimic
movs r1, #0xA
movs r0, r5
lsrs r0, r0, #0x8
cmp r0, r1
bne notMimic // jumps to notMimic, which then jumps to notCoins

// mimic start
movs r0, r5
movs r1, #0xFF
ands r0, r1
movs r1, #0x28
lsls r1, r1, #0x4
adds r1, #0xA
.hword 0x4408 @ add r0, r1
ldr r1, ptrEncounter
strh r0, [r1, #0x0]
ldr r1, ptrReceivedItemCount
ldrh r0, [r1, #0x0]
adds r0, #0x1
strh r0, [r1, #0x0]
movs r0, #0x0
movs r0, #0x0
ldr r1, ptrItemBuffer
strh r0, [r1, #0x0]
movs r0, #0x2
ldr r1, ptrEncounterFlags
strb r0, [r1, #0x0]
bl thunkEndCutscene
movs r0, #0x1
b end
// mimic end

notMimic:
movs r1, #0x80
lsls r1, r1, #0x8
movs r0, r5
ands r0, r1
cmp r0, #0x0
beq notCoins

subs r5, r5, r1
movs r0, #0x53
bl thunkPlaySound
movs r0, r5
bl thunkAddCoins
movs r0, r5
movs r1, #0x5
bl thunkSetTextVariable
movs r0, #0xE1
lsls r0, r0, #0x4
movs r1, #0x0
bl thunkShowStatusBox
b skip

notCoins:
movs r0, r5
bl 0x09006000
cmp r0, #0x1
beq skip

movs r0, #0x53
bl thunkPlaySound
bl 0x09000206
cmp r0, #0x0
bge skip
movs r0, r5
bl thunkForceAddItem

skip:
ldr r1, ptrReceivedItemCount
ldrh r0, [r1, #0x0]
adds r0, #0x1
strh r0, [r1, #0x0]
movs r0, #0x0
movs r0, #0x0
ldr r1, ptrItemBuffer
strh r0, [r1, #0x0]
bl thunkEndCutscene
bl thunkGetPartyLeader
bl thunkSetNpcStateControlled
movs r0, #0x1

end:
pop {r5, pc}

.balign 4
thunkStartCutscene:
ldr r4, [pc, #0x0]
bx r4
.word 0x080D22A9

thunkEndCutscene:
ldr r4, [pc, #0x0]
bx r4
.word 0x080D2351

thunkPlaySound:
ldr r4, [pc, #0x0]
bx r4
.word 0x081C0CB1

thunkShowStatusBox:
ldr r4, [pc, #0x0]
bx r4
.word 0x08038041

thunkShowDjinnStatusBox:
ldr r4, [pc, #0x0]
bx r4
.word 0x08044A59


thunkForceAddItem:
ldr r4, [pc, #0x0]
bx r4
.word 0x080D260D

thunkGetPartyLeader:
ldr r4, [pc, #0x0]
bx r4
.word 0x080CB8E9

thunkSetNpcStateIdle:
ldr r4, [pc, #0x0]
bx r4
.word 0x080235F9

thunkSetNpcStateControlled:
ldr r4, [pc, #0x0]
bx r4
.word 0x08023525

thunkSetTextVariable:
ldr r4, [pc, #0x0]
bx r4
.word 0x0803CCD1

thunkAddCoins:
ldr r4, [pc, #0x0]
bx r4
.word 0x080AFEB1

// my plan:
// 080B0AB8 = add_djinni(element,djinni) Checks flags. - Returns pc added to
thunkAddDjinn:
ldr r4, [pc, #0x0]
bx r4
.word 0x080B0AB9  // 080B0AB8 + 1 bc of thunk

ptrItemBuffer:
.word 0x02000A96

ptrReceivedItemCount:
.word 0x02000A72

ptrEncounter:
.word 0x02030164

ptrEncounterFlags:
.word 0x0200048B

ptrDebugDump:
.word 0x02000F80
