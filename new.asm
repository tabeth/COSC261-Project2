.Code
	
	COPY %FP	0x4000
	COPY %SP	0x4000

_SYSC_FIND_DEVICE:
			;; caller prologue
			;; preserve frame pointer 
			SUBUS %SP %SP 12
			COPY *%SP %FP
			;; put in arguments
			SUBUS %FP %SP 4
			COPY *%FP 3
			SUBUS %FP %FP 4
			COPY *%FP 2
			;; stack pointer is at top of stack
			SUBUS %SP %SP 8
			;; add 12 to %FP
			ADDUS %G5 %FP 12
			;; call find device procedure 
			CALL +_procedure_find_device *%G5
			;; caller epilogue
			ADDUS %G5 %FP 8
			COPY %FP *%G5
			ADDUS %G5 %G5 8
			COPY %SP %G5
			COPY %G0 *%SP
	

			HALT

_procedure_find_device:

	;; Prologue: Preserve the registers used on the stack.
	SUBUS		%SP		%SP		4
	COPY		*%SP		%G0
	SUBUS		%SP		%SP		4
	COPY		*%SP		%G1
	SUBUS		%SP		%SP		4
	COPY		*%SP		%G2
	SUBUS		%SP		%SP		4
	COPY		*%SP		%G4
	
	;; Initialize the locals.
	COPY		%G0		*%FP
	ADDUS		%G1		%FP		4
	COPY		%G1		*%G1
	COPY		%G2		*+_static_device_table_base
	
find_device_loop_top:

	;; End the search with failure if we've reached the end of the table without finding the device.
	BEQ		+find_device_loop_failure	*%G2		*+_static_none_device_code

	;; If this entry matches the device type we seek, then decrement the instance count.  If the instance count hits zero, then
	;; the search ends successfully.
	BNEQ		+find_device_continue_loop	*%G2		%G0
	SUB		%G1				%G1		1
	BEQ		+find_device_loop_success	%G1		0
	
find_device_continue_loop:	

	;; Advance to the next entry.
	ADDUS		%G2			%G2		*+_static_dt_entry_size
	JUMP		+find_device_loop_top

find_device_loop_failure:

	;; Set the return value to a null pointer.
	ADDUS		%G4			%FP		16 	; %G4 = &rv
	COPY		*%G4			0			; rv = null
	JUMP		+find_device_return

find_device_loop_success:

	;; Set the return pointer into the device table that currently points to the given iteration of the given type.
	ADDUS		%G4			%FP		16 	; %G4 = &rv
	COPY		*%G4			%G2			; rv = &dt[<device>]
	;; Fall through...
	
find_device_return:

	;; Epilogue: Restore preserved registers, then return.
	COPY		%G4		*%SP
	ADDUS		%SP		%SP		4
	COPY		%G2		*%SP
	ADDUS		%SP		%SP		4
	COPY		%G1		*%SP
	ADDUS		%SP		%SP		4
	COPY		%G0		*%SP
	ADDUS		%SP		%SP		4
	ADDUS		%G5		%FP		12 	; %G5 = &ra
	JUMP		*%G5

.Numeric
	
_static_device_table_base:	0x00001000
_static_dt_entry_size:		12
_static_dt_base_offset:		4
_static_dt_limit_offset:	8
_static_none_device_code:	0
_static_controller_device_code:	1
_static_ROM_device_code:	2
_static_RAM_device_code:	3
_static_console_device_code:	4