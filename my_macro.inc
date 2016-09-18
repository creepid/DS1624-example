;=============================================== 
.MACRO PUSHF
	PUSH	R16
	IN	R16,SREG
	PUSH	R16
.ENDM
 
;=============================================== 
.MACRO POPF
	POP	R16
	OUT	SREG,R16
	POP	R16
.ENDM
;===============================================
   	.macro    OUTI          	
      	LDI    R16,@1
   	.if @0 < 0x40
      	OUT    @0,R16       
   	.else
      	STS      @0,R16
   	.endif
   	.endm
;===============================================
   	.macro    UOUT        
   	.if	@0 < 0x40
      	OUT	@0,@1         
	.else
      	STS	@0,@1
   	.endif
   	.endm

