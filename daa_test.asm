INCLUDE "gbhw.asm"

SECTION "rsts", HOME [$0]
rept 8
	rst $38
rept 7
	nop
endr
endr

SECTION "ints", HOME [$40]
; VBlank
	scf
	reti
rept 6
	nop
endr
rept 4
	reti
rept 7
	nop
endr
endr

SECTION "Init", HOME [$100]
	nop
	jp Start

SECTION "Test", HOME [$150]
Start::
; Clear the accessible memory
	di
	xor a
	ld [rIF], a
	ld [rIE], a
	ld [rRP], a
	ld [rSCX], a
	ld [rSCY], a
	ld [rSB], a
	ld [rSC], a
	ld [rWX], a
	ld [rWY], a
	ld [rBGP], a
	ld [rOBP0], a
	ld [rOBP1], a
	ld [rTMA], a
	ld [rTAC], a
	ld [$d000], a

	ld a, %100 ; Start timer at 4096Hz
	ld [rTAC], a

.wait
	ld a, [rLY]
	cp 145
	jr nz, .wait

	xor a
	ld [rLCDC], a

	ld hl, $8000
	ld bc, $6000
	xor a
	call FillValue
; Place the waiting message
	ld hl, $8800
	ld de, WaitingTextGFX
	ld bc, WaitingTextGFXEnd - WaitingTextGFX
	call Copy1bpp
	ld hl, $9800 + 8 * $20 + 4
	ld a, $80
	ld bc, $030b
	call FillGraphic

; Set up the palettes
	ld a, $e4
	ld [rBGP], a

	ld a, $80
	ld [rBGPI], a
	ld c, rBGPD % $100
	ld d, 6
	ld a, $ff
.whitebgLoop
	ld [$ff00+c], a
	xor $80
	dec d
	jr nz, .whitebgLoop
	xor a
	ld [$ff00+c], a
	ld [$ff00+c], a

	ld a, $8
	ld [rSTAT], a
	ld a, $90
	ld [rWY], a
	ld a, $7
	ld [rWX], a
	xor a
	ld [rJOYP], a

	ld a, %11100011
	; LCD on
	; Win tilemap 1
	; Win on
	; BG/Win tiledata 0
	; BG Tilemap 0
	; OBJ 8x8
	; OBJ on
	; BG on
	ld [rLCDC], a

	xor a
	ld [rIF], a
	ld a, 1 << VBLANK | 1 << SERIAL ; VBlank, LCDStat, Timer, Serial interrupts
	ld [rIE], a
	ei

	ld c, $3
	call DelayFrames

; Main routine
	di
	ld hl, $0000
	ld b, $10
	ld sp, $e000
.loop
rept 16
	push hl
	pop af
	daa
	push af
	ld a, l
	add b
	ld l, a
endr
	inc h
	jr nz, .loop
	ld hl, $a000
	ld bc, $0200
.loop2
rept 7
	pop de
	ld [hl], e
	inc l
	ld [hl], d
	inc l
endr
	pop de
	ld [hl], e
	inc l
	ld [hl], d
	inc hl
	dec c
	jr nz, .loop2
	dec b
	jr nz, .loop2
	ld sp, $fffe
	ei

; Finished! Print the text and hang
	call DisableLCD
	ld hl, $8000
	ld bc, $2000
	xor a
	call FillValue
	ld hl, $8800
	ld de, DoneTextGFX
	ld bc, DoneTextGFXEnd - DoneTextGFX
	call Copy1bpp
	ld hl, $9800 + 8 * $20 + 4
	ld a, $80
	ld bc, $030c
	call FillGraphic
	call EnableLCD
.wait_forever
	call DelayFrame
	jr .wait_forever

Copy1bpp:
; copy bc bytes from de to hl
	inc b
	inc c
	jr .handleLoop

.loop
	ld a, [de]
	ld [hli], a
	ld [hli], a
	inc de
.handleLoop
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

FillGraphic:
; Fill b-by-c box starting with vBGMap addr at hl with tiles starting at a and incrementing
.row
	push bc
	push hl
.col
	ld [hli], a
	inc a
	dec c
	jr nz, .col
	pop hl
	ld bc, $20
	add hl, bc
	pop bc
	dec b
	jr nz, .row
	ret

FillValue:
; fill bc bytes at hl with a
	inc b
	inc c
	jr .handleLoop

.loop
	ld [hli], a
.handleLoop
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

DelayFrame:
	and a
.loop
	halt ; compiler automatically inserts the nop
	jr nc, .loop
	ret

DelayFrames:
.loop
	call DelayFrame
	dec c
	jr nz, .loop
	ret

DisableLCD::
; Turn the LCD off

; Don't need to do anything if the LCD is already off
	ld a, [rLCDC]
	bit 7, a ; lcd enable
	ret z

	xor a
	ld [rIF], a
	ld a, [rIE]
	ld b, a

; Disable VBlank
	res 0, a ; vblank
	ld [rIE], a

.wait
; Wait until VBlank would normally happen
	ld a, [rLY]
	cp 145
	jr nz, .wait

	ld a, [rLCDC]
	and %01111111 ; lcd enable off
	ld [rLCDC], a

	xor a
	ld [rIF], a
	ld a, b
	ld [rIE], a
	ret

EnableLCD::
	ld a, [rLCDC]
	set 7, a ; lcd enable
	ld [rLCDC], a
	ret

WaitingTextGFX: INCBIN "gfx/please_wait.1bpp"
WaitingTextGFXEnd:
DoneTextGFX: INCBIN "gfx/test_complete.1bpp"
DoneTextGFXEnd:
