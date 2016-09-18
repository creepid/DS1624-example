.include "m8def.inc"
.include "LCD4_macro.inc"  
.include "my_macro.inc"

.DSEG

firb:	.byte		1
secb:	.byte		1

.def OSRG = R17
.def temp = R18
.def temp1 = R19

.CSEG 
; Interrupts ==============================================
			.ORG 	0x0000
				rjmp RESET

			.ORG	INT0addr		; External Interrupt Request 0
			RETI
			.ORG	INT1addr		; External Interrupt Request 1
			RETI
			.ORG	OC2addr			; Timer/Counter2 Compare Match
			RETI
			.ORG	OVF2addr		; Timer/Counter2 Overflow
			RETI
			.ORG	ICP1addr		; Timer/Counter1 Capture Event
			RETI
			.ORG	OC1Aaddr		; Timer/Counter1 Compare Match A
			RETI
			.ORG	OC1Baddr		; Timer/Counter1 Compare Match B
			RETI
			.ORG	OVF1addr		; Timer/Counter1 Overflow
				rjmp TIM1

			.ORG	OVF0addr		; Timer/Counter0 Overflow
			RETI
			.ORG	SPIaddr			; Serial Transfer Complete
			RETI

			.ORG	URXCaddr		; USART, Rx Complete
			RETI

			.ORG	UDREaddr		; USART Data Register Empty
			RETI
			.ORG	UTXCaddr		; USART, Tx Complete
			RETI
			.ORG	ADCCaddr		; ADC Conversion Complete
			RETI
			.ORG	ERDYaddr		; EEPROM Ready
			RETI
			.ORG	ACIaddr			; Analog Comparator
			RETI
			.ORG	TWIaddr			; 2-wire Serial Interface
			RETI
			.ORG	SPMRaddr		; Store Program Memory Ready
			RETI
; End Interrupts ==========================================

.org INT_VECTORS_SIZE
;=============================================================================
TIM1:
	LCDCLR

	LDI temp, $54
	WR_DATA temp
	LDI temp, $65
	WR_DATA temp
	LDI temp, $BC
	WR_DATA temp
	LDI temp, $BE
	WR_DATA temp
	LDI temp, $3A
	WR_DATA temp
	LDI temp, $20
	WR_DATA temp

	
	rcall read_temp

	LDS		R16,firb			
	RCALL	firb_to_ASCII			; Из двоично десятичного формата сделали ASCII 
										; код.
	;LDI		R16,','				; Выдали разделитель
	;RCALL	uart_snt
	LDI temp, $2C
	WR_DATA temp

	LDS		R16,secb			
	RCALL	secb_to_ASCII			; Из двоично десятичного формата сделали ASCII 

	;LDI		R16,13				; Пару переводов каретки для красоты
	;RCALL	uart_snt

	LDI temp, $27
	WR_DATA temp
	LDI temp, $43

	WR_DATA temp


ldi temp, high(62500)
out TCNT1H,temp
ldi temp, low(62500)
out TCNT1L,temp

reti

;=============================================================================

firb_to_ASCII:; Преобразование из BCD в симовол  ASCII		
			push temp
			push temp1
			ldi temp, 0
			ldi temp1, 0
			
			SBRS r16, 7
			rjmp l0
			COM r16; инвертируем r16
			push r16
			;ldi r16, '-'
			;RCALL	uart_snt
				LDI temp, $2D
				WR_DATA temp
			pop r16

			l0:

			CPI R16, 100
			BRGE minus1
			rjmp l1
			minus1:
				SUBI R16,100
				inc temp1
				rjmp l0
		    l1:

			cpi temp1,0
			breq l11
			push r16
			;mov r16, temp1
			;RCALL	uart_snt
				mov temp, temp1
				WR_DATA temp
			pop r16
			
			l11:								
			CPI R16, 10
			BRGE minus2
			rjmp l2
			minus2:
				SUBI R16,10
				inc temp
				rjmp l11
			l2:
				push r16
				SUBI temp, -48
				;MOV r16, temp
				;RCALL	uart_snt
				WR_DATA temp
				
				pop r16
				SUBI r16, -48
				;RCALL	uart_snt
				mov temp, r16
				WR_DATA temp
				pop temp1
				pop temp	
			RET

secb_to_ASCII:; Преобразование из BCD в симовол  ASCII		
			push temp
			ldi temp, 0
			
			SBRC r16, 4
			SUBI temp, -6
			
			SBRC r16, 5
			SUBI temp, -13

			SBRC r16, 6
			SUBI temp, -25

			SBRC r16, 7
			SUBI temp, -50

			MOV r16, temp
			ldi temp, 0

			s_l1:
			CPI R16, 10
			BRGE s_minus
			rjmp s_l2
			s_minus:
				SUBI R16,10
				inc temp
				rjmp s_l1
			s_l2:
				push r16
				SUBI temp, -48
				;MOV r16, temp
				;RCALL	uart_snt
				WR_DATA temp
				
				pop r16
				SUBI r16, -48
				;RCALL	uart_snt
				mov temp, r16
				WR_DATA temp

				pop temp	
			RET		

;=============================================================================

RESET:
		LDI R16,Low(RAMEND)		; Инициализация стека
	  	OUT SPL,R16			; Обязательно!!!
 
	  	LDI R16,High(RAMEND)
	  	OUT SPH,R16
RAM_Flush:	
LDI	ZL,Low(SRAM_START)	
LDI	ZH,High(SRAM_START)
CLR	R16			
Flush:		
ST 	Z+,R16			
CPI	ZH,High(RAMEND+1)	
BRNE	Flush			
 
CPI	ZL,Low(RAMEND+1)	
BRNE	Flush
 
CLR	ZL			
CLR	ZH

LDI	ZL, 30		
CLR	ZH		
DEC	ZL		
ST	Z, ZH		
BRNE	PC-2
;------------------------------------------------------

OUTI	DDRB, 0b00000000
OUTI	PORTB,0b00000000 

OUTI	DDRC, 0b00000000
OUTI	PORTC,0b00000000

OUTI	DDRD, 0b00000000
OUTI	PORTD,0b00000000

;rcall uart_init
RCALL 	IIC_INIT

INIT_LCD
LCDCLR

;LDI R16, 'O'
;RCALL	uart_snt
;LDI R16, 'k'
;RCALL	uart_snt

;LDI		R16,13				; Пару переводов каретки для красоты
;RCALL	uart_snt

ldi temp, $43
WR_DATA temp
ldi temp, $BF
WR_DATA temp
ldi temp, $61
WR_DATA temp
ldi temp, $70
WR_DATA temp
ldi temp, $BF
WR_DATA temp
ldi temp, $2E
WR_DATA temp
WR_DATA temp
WR_DATA temp

rcall temp_ready_to_read

ldi temp, high(62500)
out TCNT1H,temp
ldi temp, low(62500)
out TCNT1L,temp

ldi temp, 0b00001101
out TCCR1B, temp

ldi temp, (1<<TOIE1)
out TIMSK, temp

SEI;РАЗРЕШАЕМ ПРЕРЫВАНЯ!
Loop:
RJMP Loop
;=============================================================================

reg_conf:
	RCALL	IIC_START

	LDI	OSRG,0b10010000
	RCALL	IIC_BYTE

	LDI	OSRG, $AC
	RCALL	IIC_BYTE

	LDI	OSRG, $00
	RCALL	IIC_BYTE

	RCALL	IIC_STOP
ret

start_convert:
	RCALL	IIC_START

	LDI	OSRG, 0b10010000
	RCALL	IIC_BYTE

	LDI	OSRG, $EE
	RCALL	IIC_BYTE

	RCALL	IIC_STOP
ret

temp_ready_to_read:
 	rcall reg_conf
 	rcall delay_big
 	rcall start_convert
 	rcall delay_very_big
ret

read_temp:
	RCALL	IIC_START

	LDI	OSRG,0b10010000
	RCALL	IIC_BYTE

	LDI	OSRG,$AA
	RCALL	IIC_BYTE

	RCALL	IIC_START

	LDI	OSRG,0b10010001
	RCALL	IIC_BYTE
	
	RCALL	IIC_RCV
	IN	OSRG,TWDR
	STS	firb,OSRG

	RCALL	IIC_RCV2
	IN	OSRG,TWDR
	STS	secb,OSRG
	
	RCALL	IIC_STOP
ret


;-----------------------------------------------------------------------------

.include "LCD4.asm"
.include "delays.asm"
.include "USART.asm"
.include "i2c.asm"
