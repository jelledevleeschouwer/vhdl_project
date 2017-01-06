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
xsum        EQU s5
ysum        EQU s6
seq         EQU sD
count_i     EQU sE
count_o	    EQU sF

; ===============================================================================
;   SPI patterns
; ===============================================================================
SPI_OUT_CS  EQU 0x00
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
init:  	    DINT
	        JUMP main

; ===============================================================================
;   Read/Write SPI port subroutines
; ===============================================================================

;
; Clocks out a '1' on the MOSI pin
;
out_0:      LOAD A, SPI_OUT_L
            OUT A, spi_port
            CALL delay_us
            LOAD A, SPI_CLK_L
            OUT A, spi_port
            CALL delay_us
            RET

;
; Clocks out a '0' on the MOSI pin
;
out_1:      LOAD A, SPI_OUT_H
            OUT A, spi_port
            CALL delay_us
            LOAD A, SPI_CLK_H
            OUT A, spi_port
            CALL delay_us
            RET

;
; Reads 8 bits from MISO pin and stores it in 'B' reg.
;
read_8:
;            CALL in3                    ; Exec 4x, on ret, exec 4x again (8x total)
;in3:                                    ; Fall-through, but also acts as instruction after return
;            CALL in2                    ; Exec 2x, on ret, exec 2x again & ret to callee
;in2:                                    ; Fall-through, but also acts as instruction after return
;            CALL in                     ; Exec 1x, on ret, exec 1x again & ret to callee
;in:                                     ; Fall-through, but also acts as instruction after return
            LOAD A, SPI_IN_H
            OUT A, spi_port
            CALL delay_us
            LOAD A, SPI_IN_L
            OUT A, spi_port
            CALL delay_us
            IN data_in, spi_port
            AND data_in, SPI_IN_CLK
            COMP data_in, SPI_IN_CLK
            JUMP Z, in_1
in_0:       SL0 B
            JUMP in_ret
in_1:       SL1 B
in_ret:     RET

; ===============================================================================
;   Main routine
; ===============================================================================
main:    	LOAD seq, 4
            LOAD xdata, 0
            LOAD ydata, 0
            LOAD xsum, 0
            LOAD ysum, 0
scan_l:     TEST seq, 0xFF
            JUMP Z, scan_out
    	    SUB seq, 1
            CALL start
            CALL y_channel
            CALL mode
            CALL power_on
            CALL y_read
            CALL stop
            CALL start
            CALL x_channel
            CALL mode
            CALL power_on
            CALL x_read
            CALL stop
            JUMP scan_l                 ; Loop
scan_out:   CALL update                 ; Put data on output
            JUMP main                   ; Reinitialize and loop

; ===============================================================================
;   Start sequence
; ===============================================================================
start:      LOAD A, SPI_OUT_CS
            OUT A, spi_port             ; Chip Select
            CALL delay_us
            CALL out_1                  ; Start bit
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
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            LOAD xdata, B
;            SL0 xdata
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO, throw away
            RET                         ; We don't care about 4 MSBs and padding

; ===============================================================================
;   Y read sequence
; ===============================================================================
y_read:     CALL busy_wait
            LOAD B, 0
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            LOAD ydata, B
;            SL0 ydata
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO
            CALL read_8                 ; Read 8 bits from MISO, throw away
            RET                         ; We don't care about 4 MSBs and padding

; ===============================================================================
;   Compute new averages
; ===============================================================================

;
; Divide value in 'b' by the number of samples taken
;
divide:     SRA B                       ; Shift 1x (B / 2) => /2
            SRA B                       ; Shift 1x (B / 2) => /4
;           SRA B                       ; Shift 1x (B / 2) => /8
            RET

;
; Add next value to average sum of X
;
x_average:  LOAD B, xdata
            CALL divide
            ADD xsum, B                 ; xsum = xsum + (xdata / 4)
            RET

;
; Add next value to average sum of Y
;
y_average:  LOAD B, ydata
            CALL divide
            ADD ysum, B                 ; ysum = ysum + (ydata / 4)
            RET

; ===============================================================================
;   Put coordinates on output
; ===============================================================================
update:     OUT xdata, out_1
            OUT ydata, out_2
            RET

; ===============================================================================
;   Wait until busy is high
; ===============================================================================
busy_wait:  OUT SPI_OUT_L, spi_port
            IN data_in, spi_port
            COMP data_in, SPI_BUSY
            JUMP Z, busy_r              ; If 'busy' is 0, check again
            JUMP busy_wait              ; else, return
busy_r:     RET

; ===============================================================================
;   1us delay
; ===============================================================================
LOOPS_O     EQU 255
LOOPS_I     EQU 1

delay_us:   LOAD count_o, LOOPS_O
            LOAD count_i, LOOPS_I
delay_us_l: SUB count_o, 1              ; Substract 1 of outer loop
            SUBC count_i, 0             ; If outer loop overflows, substract carry from inner loop
            TEST count_i, 0xFF
            JUMP NZ, delay_us_l
            RET

; ===============================================================================
;   INTERRUPTS
; ===============================================================================
    	    ORG 0x3FF
    	    RETI DISABLE