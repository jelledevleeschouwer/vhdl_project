;--------------------------------------------------------------------------------
;
; Title:    SPI driver for scanning touch inputs on the LCD screen used in the
;           game for the course on programmable logic
;
; Information:
;   The FPGA runs @ 125Mhz so this is a clock period of 8ns. The picoblaze needs
;   2 clockpulses/instruction, thus a clock period of 16ns.
;
;--------------------------------------------------------------------------------

; ===============================================================================
;   SPI pin assigment:
; ===============================================================================
;   bit |   Description     | DIR
; ------+-------------------+----------------------------------------------------
;   0   |   Chip Select     | OUT
;   1   |   DCLK            | OUT
;   2   |   MOSI            | OUT
;   3   |   BUSY            |  IN
;   4   |   MISO            |  IN
; ===============================================================================

; ===============================================================================
;   Port assignments
; ===============================================================================
spi_port    EQU 0x01
out_1       EQU 0x02
out_2       EQU 0x04

; ===============================================================================
;   Register assignments
; ===============================================================================
A           EQU s0          ; Work register
B           EQU s1          ; Passing register
data_in     EQU s2
xdata       EQU s3
ydata       EQU s4
xsum	    EQU s5
ysum        EQU s6
seq	        EQU s7
count       EQU sF

; ===============================================================================
;   SPI patterns
; ===============================================================================
SPI_OUT_CS  EQU 0x00	    ; Active low, Chip Select is on pin 0 => 0x00
SPI_OUT_H   EQU 0x04
SPI_CLK_H   EQU 0x06
SPI_OUT_L   EQU 0x00
SPI_CLK_L   EQU 0x02
SPI_OUT_DCS EQU 0x01
SPI_BUSY    EQU 0x08
SPI_IN_H    EQU 0x02
SPI_IN_L    EQU 0x00
SPI_IN_CLK  EQU 0x10

; ===============================================================================
;   Initialisation
; ===============================================================================
init:  	    DINT			; Disable interrupts
	        JUMP main		; Jump to the main routine

; ===============================================================================
;   Read/Write SPI port subroutines
; ===============================================================================

;
; Clocks out a '0' on the MOSI pin
;
out_0:      LOAD A, SPI_OUT_L           ; Make MOSI low while clock is low
            OUT A, spi_port
            CALL delay_us               ; Delay
            LOAD A, SPI_CLK_L           ; Make MOSI low while clock is low
            OUT A, spi_port
            CALL delay_us               ; Delay
            RET

;
; Clocks out a '1' on the MOSI pin
;
out_1:      LOAD A, SPI_OUT_H			; Make MOSI high while clock is low
            OUT A, spi_port
            CALL delay_us				; Delay
            LOAD A, SPI_CLK_H			; Make MOSI high while clock is high
            OUT A, spi_port
            CALL delay_us				; Delay
            RET

;
; Reads 8 bits from MISO pin and stores it in 'B' reg.
;
read_8:
            CALL in3                    ; Exec 4x, on ret, exec 4x again (8x total)
in3:                                    ; Fall-through, but also acts as instruction after return
            CALL in2                    ; Exec 2x, on ret, exec 2x again & ret to callee
in2:                                    ; Fall-through, but also acts as instruction after return
            CALL in                     ; Exec 1x, on ret, exec 1x again & ret to callee
in:                                     ; Fall-through, but also acts as instruction after return
            LOAD A, SPI_IN_H			; Make DCLK high
            OUT A, spi_port
            CALL delay_us
            LOAD A, SPI_IN_L			; Make DCLK low
            OUT A, spi_port
            CALL delay_us
            IN data_in, spi_port		; Read the data just before the new rising edge
            AND data_in, SPI_IN_CLK     ; To make sure only the MISO bit is checked
            COMP data_in, SPI_IN_CLK	; if one shift a one in B if zero,
            JUMP Z, in_1
in_0:       SL0 B						; shift a zero into B
            JUMP in_ret
in_1:       SL1 B						; shift a one into B
in_ret:     RET

; ===============================================================================
;   Main routine
; ===============================================================================
main:       LOAD xdata, 0				; Zero-initialise xdata
            LOAD ydata, 0				; Zero-initialise ydata
            LOAD xsum, 0		        ; Zero-initialise xsum
            LOAD ysum, 0	            ; Zero-initialise ysum
            LOAD seq, 4	                ; Zero-initialise seq
sequence:   CALL start					; Make CS low and set the start bit
            CALL y_channel				; Put "001" on the MOSI pin
            CALL mode					; Put "00" on MOSI pin: 12-bit, differential mode
            CALL power_on				; Put "00" Power-down between conversions
            CALL y_read					; Read in the data bits from the slave
            CALL stop					; Disable chip select
            CALL start					; Do the same thing for X
            CALL x_channel              ; Put "101" on the MOSI pin
            CALL mode
            CALL power_on
            CALL x_read
            CALL stop
			CALL update
            SUB seq, 1
			TEST seq, 0xFF				; Check if we did it 4 times
            JUMP NZ, sequence			; Not yet -> do it again
output:	    OUT xsum, out_1
            OUT ysum, out_2
            JUMP main                   ; Reinitialize and loop

; ===============================================================================
;   Start sequence
; ===============================================================================
start:      LOAD A, SPI_OUT_CS			; Make CS low
            OUT A, spi_port
            CALL delay_us               ; Delay
            CALL out_1                  ; Start bit '1'
            RET

; ===============================================================================
;   Stop sequence
; ===============================================================================
stop:       LOAD A, SPI_OUT_DCS
            OUT A, spi_port             ; Chip deselect
            CALL delay_us
            RET

; ===============================================================================
;   Y-channel address
; ===============================================================================
y_channel:  CALL out_0                  ; 0
            CALL out_0                  ; 0
            CALL out_1                  ; 1
            RET

; ===============================================================================
;   X-channel address
; ===============================================================================
x_channel:  CALL out_1                  ; 1
            CALL out_0                  ; 0
            CALL out_1                  ; 1
            RET

; ===============================================================================
;   Conversion mode
; ===============================================================================
mode:       CALL out_0                  ; 12-bit conversion
            CALL out_0                  ; Differential mode
            RET

; ===============================================================================
;   Power mode
; ===============================================================================
power_on:   CALL out_0
            CALL out_0                  ; Power down between conversions
            RET

; ===============================================================================
;   X read sequence
; ===============================================================================
x_read:     CALL busy_wait
            LOAD B, 0
            CALL read_8                 ; Read 8 bit from MISO
            LOAD xdata, B
            CALL read_8                 ; Read 8 bits from MISO, throw away
            RET                         ; We don't care about 4 MSBs and padding

; ===============================================================================
;   Y read sequence
; ===============================================================================
y_read:     CALL busy_wait
            LOAD B, 0
            CALL read_8                 ; Read 8 bits from MISO
            LOAD ydata, B
            CALL read_8                 ; Read 8 bits from MISO, throw away
            RET                         ; We don't care about 4 MSBs and padding

; ===============================================================================
;   Add values to the average registers
; ===============================================================================
update:     SR0 xdata			        ; /2
			SR0 xdata			        ; /4
			SR0 ydata			        ; /2
			SR0 ydata			        ; /4
			ADD xsum, xdata
			ADD ysum, ydata
			RET

; ===============================================================================
;   Wait until busy is high
; ===============================================================================
busy_wait:  LOAD A, SPI_OUT_L			; Everything output pin low
	        OUT A, spi_port
	        CALL delay_us
            IN data_in, spi_port
            COMP data_in, SPI_BUSY		; Zero flag is set if equal
            JUMP Z, busy_r              ; If 'busy' is 0, check again
            JUMP busy_wait              ; Else, return
busy_r:     RET

; ===============================================================================
;   X us delay
; ===============================================================================
LOOPS		EQU 192

delay_us:   LOAD count, LOOPS			; Put LOOPS in count
delay_us_l: SUB count, 1
            JUMP NZ, delay_us_l
            RET

; ===============================================================================
;   INTERRUPTS
; ===============================================================================
    	    ORG 0x3FF
    	    RETI DISABLE
