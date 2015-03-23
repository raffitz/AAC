.module teste
.pseg
main:
		; tests shifts
		; flags are S, C, Z, V
		; only S, C, Z should be updated by shifts
		loadlit r0, 1
		asr r0, r0	; C, Z (lowest bit was one and was dropped off)
		asr r0, r0	; Z
		lch r0, 128
		asr r0, r0	; none
		lsl r0, r0	; none
		lsl r0, r0	; S
		asr r0, r0	; S. r0 should now have 0xC000
		lsl r0, r0	; S, C (highest bit was one and was dropped off)
		lsl r1, r0	; C, Z

		loadlit r0, 2
		asr r0, r0	; none
		asr r0, r0	; C, Z (lowest bit was one and was dropped off)
		lsl r0, r0	; Z

		loadlit r0, -1
		asr r0, r0	; S, C. r0 should have -1
		lsl r0, r0	; S, C. r0 should have -2

END:	j END

.dseg
ARRAY:
.end
