.Code
;;; Step 48 takes IP to the end of the BIOS
;;; 	set kernel_base and kernel_limit
	COPY *+kernel_limit %G0
	
;;; Sets up values in trap table (step 13 takes to end)
	COPY *+INVALID_ADDRESS +handler
	COPY *+INVALID_REGISTER +handler
	COPY *+BUS_ERROR +handler
	COPY *+CLOCK_ALARM +handler
	COPY *+DIVIDE_BY_ZERO +handler
	COPY *+OVERFLOW +handler
	COPY *+INVALID_INSTRUCTION +handler
	COPY *+PERMISSION_VIOLATION +handler
	COPY *+INVALID_SHIFT_AMOUNT +handler
	COPY *+SYSTEM_CALL +handler
	COPY *+INVALID_DEVICE_VALUE +handler
	COPY *+DEVICE_FAILURE +handler
;;; Sets trap table base
	SETTBR +TT_base
	SETIBR +IB_IP

;;; Find next ROM device
;;; Registers: G0 = address of next device in BC
;;; 	       G1 = device value, G2 = boolean 2 found at bus_index
;;; 	       G3 = two_count
	COPY %G0 *+bus_index
	COPY %G3 0
;;; Step 16 from top
findstart:
	COPY %G1 *%G0
	SUB  %G2 %G1 2
	ADD  %G0 %G0 0x0000000c
	BNEQ +findstart %G2 0
	ADD  %G3 1 %G3
	BNEQ  +findstart %G3 2
	SUB  %G0 %G0 0x00000008
;;; Step 37 (+21) from top
;;; G0 should now point to the kernel in Bus Controller
	COPY %G5 *%G0
	ADD  %G0 %G0 0x00000004
	COPY %G4 *%G0
;;; G5 = kernel base address (0x207000), G4 = kernel end address  (0x2073a4)
	COPY *+kernel_limit %G4
	COPY %G0 *+bus_index
	COPY %G3 0
findstart_process:
	COPY %G1 *%G0
	SUB  %G2 %G1 2
	ADD  %G0 %G0 0x0000000c
	BNEQ +findstart_process %G2 0
	ADD  %G3 1 %G3
	BNEQ  +findstart_process %G3 3
	SUB  %G0 %G0 0x00000008
;;; G0 should now point to the process in Bus Controller
	COPY %G5 *%G0
	ADD  %G0 %G0 0x00000004
	COPY %G4 *%G0
;;; G5 = process base address, G4 = process end address
	SUB  %G4 %G4 %G5
;;; G4 = length of process
	COPY %G0 *+bus_index
	ADD  %G0 %G0 0x00000008
	COPY %G1 *%G0
;;; G1 = Address pointing to the address of the end of the BC
	SUB  %G1 %G1 0x0000000c
;;; G1 = Address pointing to the first triplet of the last set in the BC
	ADD %G2 0x00001000 +kernel_limit
;;; G2 = Destination base
	COPY *%G1 %G5
	ADD  %G1 %G1 0x00000004
	COPY *%G1 %G2
	ADD  %G1 %G1 0x00000004
	COPY *%G1 %G4
	
	COPY %G0 2
	JUMPMD %G2 %G0
;;; Step 90 from top
	
;;; Handler function, should branch before this segment
handler:
	HALT

.Numeric
kernel_base:	0
kernel_limit:	0
process_base:	
IB_IP:	0
IB_MISC:	0
bus_index:	 0x00001000
TT_base:
INVALID_ADDRESS:	0
INVALID_REGISTER:	0
BUS_ERROR: 	0
CLOCK_ALARM:	0
DIVIDE_BY_ZERO:	0
OVERFLOW:	0
INVALID_INSTRUCTION:	0
PERMISSION_VIOLATION:	0
INVALID_SHIFT_AMOUNT:	0
SYSTEM_CALL:	0
INVALID_DEVICE_VALUE:	0
DEVICE_FAILURE:	0
	
	
	