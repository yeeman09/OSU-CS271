TITLE Project 6     (Proj6_huanminy.asm)

; Author: Minyi Huang
; Last Modified: March 16th, 2023
; OSU email address: huanminy@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:       6          Due Date:	March 19th, 2023
; Description: This program will get 10 valid integers from the user 
;			   and display the integers, their sum, and their truncated average
;			   by using MACROs and Procedures.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Description: Turns the integer that the user has input into an ASCII string
;
; Receives:
; prompt			= prompt address
; userInputString	= the integer-turned-string address
; countInputString	= value, Size of the byte string
; byteCount			= value, count of string bytes in the userInputString
;
; returns: EDX = stringAddress
; ---------------------------------------------------------------------------------
mGetString		MACRO	prompt, userInputString, countInputString, byteCount
	; save registers 
	PUSH	EDX
	PUSH	ECX

	; print prompt
	MOV		EDX, prompt
	CALL	WriteString

	; get user input
	MOV		EDX, userInputString
	MOV		ECX, countInputString
	CALL	ReadString
	MOV		byteCount, EAX

	; restore registers
	POP		ECX
	POP		EDX

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Description: Display strinng
;
; Receives: string = Address of a string
; ---------------------------------------------------------------------------------
mDisplayString	MACRO	string
	PUSH	EDX
	MOV		EDX, string
	CALL	WriteString
	POP		EDX
ENDM

; Global constants
ZERO = 48
NINE = 57
PLUS = 43
MINUS = 45

.data
greeting1	BYTE	"Welcome to this program, my friend.",13,10,0
greeting2	BYTE	"My name is Minyi. Feel free to play this string-manipulation game, but remember to follow the instructions below :).",13,10,0
prompt1		BYTE	"In this program, you will be providing 10 signed decimal integers.",13,10,0
prompt2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",13,10,0
prompt3		BYTE	"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,0
numbershow	BYTE	"You entered these numbers: ",0
sumShow		BYTE	"The sum of these number is: ",0
averageS	BYTE	"The truncated average is: ",0
errorMsg	BYTE	"ERROR: You did not enter a signed integer or the one you entered was too big.",13,10,0
byeMsg		BYTE	"Glad this program works, and Thanks for playing it, my friend.",13,10,0

; userInput
inputMsg	BYTE	"Please enter a signed integer: ",0
stringIn	BYTE	50 DUP(?)
byteCount	DWORD	?	
numOut		SDWORD	?
numArray	SDWORD	10 DUP(?)
numSum		SDWORD	?


.code
main PROC

; introduction
mDisplayString	OFFSET greeting1
CALL			CrLf
mDisplayString	OFFSET greeting2
CALL			CrLf
mDisplayString	OFFSET prompt1
mDisplayString	OFFSET prompt2
mDisplayString	OFFSET prompt3
CALL			CrLf


; get user input
MOV				ECX, 10				;get input counter
MOV				EDX, 0				;numArray counter
_getInput:
	PUSH		OFFSET numOut		
	PUSH		OFFSET errorMsg     
	PUSH		OFFSET byteCount    
	PUSH		SIZEOF stringIn     
	PUSH		OFFSET stringIn     
	PUSH		OFFSET inputMsg    
	CALL		readVal

	MOV			EAX, numOut
	MOV			EDI, OFFSET numArray
	MOV			[EDI + EDX*4], EAX
	INC			EDX
	LOOP		_getInput

CALL			CrLf

; display user input
PUSH			OFFSET numArray
PUSH			OFFSET numberShow
CALL			displayInput
CALL			CrLf

; display the sum of these integers
PUSH			OFFSET numSum
PUSH			OFFSET numArray
PUSH			OFFSET sumShow
CALL			displaySum
CALL			CrLf

; display the truncated average
mDisplayString	OFFSET averageS
MOV				EAX, numSum
MOV				EBX, 10
CDQ
IDIV			EBX
	
PUSH			EAX
CALL			writeVal
CALL			CrLf


; goodbyte
CALL			CrLf
mDisplayString	OFFSET byeMsg
CALL			CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: readVal
;
; Description: User enters an integer, the input will be stored in the form of 
;              a string of digits, convert the string of ASCII digits to the 
;			   numeric value representation, store the value in a variable
;
; Receives:
;	[EBP+8]		= reference to the prompt
;	[EBP+12]	= reference to the inputString
;	[EBP+16]	= size of the inputString
;	[EBP+20]	= reference to the number of bytes read by the mGetString Macro
;	[EBP+24]	= reference to the error message
;	[EBP+28]	= reference to the integer output
; ---------------------------------------------------------------------------------
readVal		PROC            
    PUSH    EBP
    MOV     EBP, ESP
	PUSH	ECX				; save the 10-input-loop counter
	PUSH	EDX				; save the numArray counter

_getString:
    mGetString  [EBP+8],[EBP+12],[EBP+16],[EBP+20]

	CLD
    MOV     ECX, [EBP+20]   
    MOV     ESI, [EBP+12]   
	MOV		EDI, [EBP+28]
	MOV		EAX, 0
	MOV		EBX, 0

_read:
	LODSB	

	CMP		ECX, [EBP+20]
	JE		_readFirstSign		; see if the integer input comes with a sign or not			
	JNE		_readAll

	_readFirstSign:
		CMP		AL, PLUS
		JE		_readPositive		
		CMP		AL, MINUS
		JE		_readNegative		
		JNE		_readAll		; if the first value is not a sign, jump directly to read the whole string

	_readPositive:
		SUB		ECX, 1
		LODSB					; ignore the plus sign

	_readAll:
		CMP		AL, ZERO
		JL		_error
		CMP		AL, NINE
		JG		_error
		SUB		AL, 48

		XCHG	EAX, EBX		
		IMUL	EAX, 10
		JO		_error
		ADD		EAX, EBX		
		JO		_error
		XCHG	EAX, EBX	
		LOOP	_read

		XCHG	EAX, EBX
		JO		_error
		JMP		_end

	_readNegative:
		SUB		ECX, 1

	_readNext:
		LODSB
		CMP		AL, ZERO
		JL		_error
		CMP		AL, NINE
		JG		_error
		SUB		AL, 48

		XCHG	EAX, EBX		
		IMUL	EAX, 10
		JO		_error

		CMP		ECX, 1			; handle Overflow 
		JE		_lastDigit

		ADD		EAX, EBX		
		JO		_error
		XCHG	EAX, EBX		
		LOOP	_readNext


	_lastDigit:
		NEG		EAX
		SUB		EAX, EBX
		JO		_error

	_end:			
		STOSD						; the integer value will be stored in EDI (the address of numOut)
		POP		EDX					; restore the numArray counter
		POP		ECX					; restore the 10-input-loop counter
		POP     EBP
		RET     24

	_error:
		MOV				EDX, [EBP+24]
		mDisplayString	EDX
		CALL			CrLf
		JMP				_getString

readVal		ENDP


; ---------------------------------------------------------------------------------
; Name: writeVal
;
; Description: Converts a numeric SDWORD value to a string of ASCII digits
;
; Receives:
;	[EBP+8]		= reference to the prompt
;	[EBP+12]	= reference to the inputString
; ---------------------------------------------------------------------------------
writeVal	PROC
	LOCAL	string1[22]:BYTE, string2[22]:BYTE

	PUSH	ECX
	PUSH	EDX

	; restore string 1
	CLD					
	LEA		EDI, string1
	MOV		ECX, 22
	MOV		AL, 0
	REP		STOSB			

	; restore string 2
	CLD					
	LEA		EDI, string2
	MOV		ECX, 22
	MOV		AL, 0
	REP		STOSB			

	MOV		ECX, 0
	MOV		EAX, [EBP+8]
	MOV		EBX, 10

	LEA		EDI, string1

	CMP		EAX, 0
	JS		_negativeValue

	_positiveValue:
		CDQ
		IDIV	EBX

		CMP		EAX, 0
		JE		_endDivide

		ADD		DL, 48
		XCHG	AL, DL
		STOSB
		XCHG	AL, DL
		CDQ
		INC		ECX
		JMP		_positiveValue

		_endDivide:
			ADD		DL, 48
			XCHG	AL, DL
			STOSB						;the ASCII digits will be stored in string 1, backward 
			INC		ECX
			JMP		_end

	_negativeValue:
		CDQ
		IDIV	EBX

		CMP		EAX, 0
		JE		_endNegativeDivide

		NEG		DL
		ADD		DL, 48
		XCHG	AL, DL
		STOSB
		XCHG	AL, DL
		CDQ
		INC		ECX
		JMP		_negativeValue

		_endNegativeDivide:
			NEG		DL
			ADD		DL, 48
			XCHG	AL, DL
			STOSB						;the ASCII digits will be stored in string 1, backward
			INC		ECX

			MOV		AL, 45
			STOSB
			INC		ECX

	_end:
		LEA		ESI, string1
		ADD		ESI, ECX
		DEC		ESI
		LEA		EDI, string2

	_revRead:
		STD
		LODSB
		CLD
		STOSB
		LOOP	_revRead			;read string1 reversely and store the string byte in string2

		LEA		EDX, string2

		mDisplayString	EDX

	POP		EDX
	POP		ECX

	RET		4
writeVal	ENDP


; ---------------------------------------------------------------------------------
; Name: displayInput
;
; Description: display the integers the user has entered
;
; Receives:
;	[EBP+8]		= Address of the "show number" message
;	[EBP+12]	= Address of the number array
; ---------------------------------------------------------------------------------
displayInput	PROC
	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString	[EBP+8]

	MOV		ECX, 10
	MOV		EDX, 0

	_writeInput:
		MOV		ESI, [EBP+12]		; numArray
		MOV		EAX, [ESI + EDX*4]	
		PUSH	EAX
		CALL	writeVal
		MOV		AL, 32
		CALL	WriteChar
		MOV		AL, 32
		CALL	WriteChar
		MOV		AL, 32
		CALL	WriteChar

		INC		EDX
		LOOP	_writeInput

	POP		EBP
	RET		8
displayInput	ENDP

; ---------------------------------------------------------------------------------
; Name: displaySum
;
; Description: display the sum of the integers the user has entered
;
; Receives:
;	[EBP+8]		= Address of the "show sum" message
;	[EBP+12]	= Address of the number array
;	[EBP+16]	= Address of the sum
; ---------------------------------------------------------------------------------
displaySum		PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		ECX, 9
	MOV		EDX, 0
	MOV		EDI, [EBP+16]
	MOV		ESI, [EBP + 12]
	MOV		EAX, [ESI + EDX*4]
	INC		EDX

	mDisplayString	[EBP+8]

	_sumLoop:
		MOV			EBX, [ESI + EDX*4]
		ADD			EAX, EBX
		INC			EDX
		LOOP		_sumLoop

		MOV			[EDI], EAX

	_writeSum:
		PUSH		EAX
		CALL		writeVal

	POP		EBP
	RET		12
displaySum		ENDP

END main
