TITLE Project 5     (Proj5_huanminy.asm)

; Author: Minyi Huang
; Last Modified: March 2nd, 2023
; OSU email address: huanminy@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:       5          Due Date: March 5th, 2023
; Description: This program generates, sorts, and count random integers.

INCLUDE Irvine32.inc

ARRAYSIZE = 200
LO = 15
HI = 50

.data

greeting		BYTE	"Welcome to this Random Integer Program, programmed by Minyi Huang.",13,10,0
intro1			BYTE	"This program generates 200 random integers between 15 and 50, inclusive.",13,10,0 
intro2			BYTE	"Displays: the original list, the sorted list, the median value of the list,",13,10,0 
intro3			BYTE	"and finally displays the number of instances of each generated value, starting with the number of lowest.",13,10,0
goodbye			BYTE	"See you again!",13,10,0

listTitle1		BYTE	"The Unsorted Random Integer List: ",13,10,0
listTitle2		BYTE	"The Sorted Random Integer List: ",13,10,0
listTitle3		BYTE	"Your list of instances of each generated number, starting with the smallest value: ",13,10,0
medianTitle		BYTE	"The median value of the array: ",0

randArray		DWORD	ARRAYSIZE DUP(?)
counts			DWORD	(HI - LO + 1) DUP(?)

.code
main PROC
CALL	Randomize

; introduction
PUSH	OFFSET intro3
PUSH	OFFSET intro2
PUSH	OFFSET intro1
PUSH	OFFSET greeting
CALL	introduction

; create an array containing randomly generated integers
PUSH	OFFSET randArray
CALL	fillArray

; print the original unsorted list
PUSH	OFFSET listTitle1
PUSH	OFFSET randArray	
PUSH	LENGTHOF randArray
CALL	displayList
CALL	CrLf

; sorts the original list
PUSH	OFFSET randArray
CALL	sortList

; print the sorted list
PUSH	OFFSET listTitle2
PUSH	OFFSET randArray	
PUSH	LENGTHOF randArray
CALL	displayList
CALL	CrLf

; find and print the median value of the list
PUSH	OFFSET medianTitle
PUSH	OFFSET randArray
CALL	displayMedian
CALL	CrLf

; count the number of instance of each randomly generated number
PUSH	OFFSET randArray
PUSH	OFFSET counts
CALL	countList

; print the counts array
PUSH	OFFSET listTitle3
PUSH	OFFSET counts	
PUSH	LENGTHOF counts
CALL	displayList
CALL	CrLf

; farewell to the user
PUSH	OFFSET goodbye
CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; -------------------------------Introduction-------------------------------------------------------------
; Procedure Description: This procedure introducts the program and the programmer
; Preconditions: greeting and intro 1-3 on the stack, the return address of introduction proc on the stack
; Post-conditions: None
introduction	PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	MOV		EDX, [EBP + 16]
	CALL	WriteString
	MOV		EDX, [EBP + 20]
	CALL	WriteString
	CALL	CrLf

	POP		EBP
	RET		16

introduction	ENDP


; -------------------------------Fill Array---------------------------------
; Procedure Description: This procedure puts random integers into the array
; Preconditions: address of the array is put on stack
; Post-conditions: None
; Return: an unsorted array containing randomly generated integers
fillArray	PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDI, [EBP + 8]
	MOV		ECX, ARRAYSIZE

_fillLoop:
	MOV		EAX, HI
	SUB		EAX, LO
	INC		EAX
	CALL	RandomRange
	ADD		EAX, LO
	MOV		[EDI], EAX
	ADD		EDI, 4
	LOOP	_fillLoop

	POP		EBP
	RET		4	

fillArray	ENDP


; ---------------------------------------Display List-------------------------------------------------
; Procedure Description: This procedure displays the array
; Preconditions: address of the array, length of the array, the title of the array are put on stack
; Post-conditions: None
; Return: an array containing randomly generated integers, either sorted or unsorted, or a count array
displayList		PROC
	MOV		EAX, 0						; row position count
	PUSH	EAX
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP + 20]				; print the title of the list
	CALL	WriteString
	MOV		ESI, [EBP + 16]				; ESI = the array
	MOV		ECX, [EBP + 12]				; ECX = the length of the array

_showElement:
	MOV		EAX, [ESI]
	CALL	WriteDec
	MOV		AL, 20H
	CALL	WriteChar
	ADD		ESI, 4

	MOV		EAX, [EBP + 4]
	INC		EAX
	MOV		[EBP + 4], EAX
	CMP		EAX, 20
	JGE		_newRow
	JMP		_continueRow

_newRow:
	CALL	CrLf
	MOV		EAX, [EBP + 4]
	MOV		EAX, 0
	MOV		[EBP + 4], EAX

_continueRow:
	LOOP	_showElement

	POP		EBP
	POP		EAX
	CALL	CrLf
	RET		12

displayList		ENDP

; ---------------------------------------Sort List-------------------------------------------------
; Procedure Description: This procedure sorts the array
; Preconditions: address of the array
; Post-conditions: Array sorted
; Return: a sorted array
sortList	PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		ESI, [EBP + 8]			; ESI = the array
	MOV		ECX, ARRAYSIZE			; ECX = arraysize
	DEC		ECX

_sortOuterLoop:
	MOV		EDX, 0
	CMP		ECX, 0
	JGE		_sortInnerLoop
	JL		_endOuter

_sortInnerLoop:
	MOV		EAX, [ESI]
	CMP		EAX, [ESI + 4]
	JG		_exchangeElement
	JLE		_continueInnerLoop

_continueInnerLoop:
	ADD		ESI, 4
	INC		EDX
	CMP		EDX, ECX
	JL		_sortInnerLoop
	JGE		_endInner

_exchangeElement:
	PUSH	[ESI]
	PUSH	[ESI + 4]
	CALL	exchangeElements
	POP		[ESI + 4]
	POP		[ESI]

	ADD		ESI, 4
	INC		EDX
	CMP		EDX, ECX
	JL		_sortInnerLoop
	JGE		_endInner

_endInner:
	DEC		ECX
	MOV		ESI, [EBP + 8]
	JMP		_sortOuterLoop

_endOuter:
	POP		EBP
	RET		4
sortList	ENDP


; ----------------------------------------Exchange Elements-------------------------------------------------
; Procedure Description: This procedure is the subprocedure of Sort List; it exchanges elements in the array
; Preconditions: the address of randArray[i], randArray[i+1] are on the stack
; Post-conditions: Elements exchanged
exchangeElements	PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EAX, [EBP + 12]
	MOV		EBX, [EBP + 8]

	MOV		[EBP + 12],EBX
	MOV		[EBP + 8], EAX

	POP		EBP
	RET		
exchangeElements	ENDP


; ---------------------------------------Display Median-------------------------------------------------
; Procedure Description: This procedure displays the median value of the array
; Preconditions: address of the median display string & the address of the array are on stack
; Post-conditions: None
; Return: the median value of the array

displayMedian	PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP + 12]
	CALL	WriteString

	MOV		ESI, [EBP + 8]
	MOV		EAX, ARRAYSIZE
	MOV		EDX, 0
	MOV		EBX, 2

	DIV		EBX
	CMP		EDX, 0
	JE		_evenArray
	JNE		_oddArray

_evenArray:
	; get the middle two values
	MOV		ECX, [ESI + EAX * 4]
	DEC		EAX
	MOV		EDX, [ESI + EAX * 4]
	ADD		ECX, EDX

	MOV		EAX, ECX
	MOV		EDX, 0
	MOV		EBX, 2
	DIV		EBX

	CMP		EDX, 0
	JE		_printMedian
	ADD		EAX, 1
	JMP		_printMedian

_oddArray:
	; get the middle value
	MOV		EAX, [ESI + EAX * 4]
	JMP		_printMedian

_printMedian:
	CALL	WriteDec
	CALL	CrLf


	POP		EBP
	RET		8
displayMedian	ENDP

; ---------------------------------------Count Instance-------------------------------------------------
; Procedure Description: This procedure counts the instances of each number
; Preconditions: the address of the sorted  array and the address of the count array are on stack
; Post-conditions: EDI changed
; Return: a count array
countList	PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		ESI, [EBP + 12]
	MOV		EDI, [EBP + 8]		; EDI = counts array

	MOV		EBX, LO
	MOV		ECX, HI
	SUB		ECX, EBX			; ECX = 50 - 15
	ADD		ECX, 1

	MOV		EDX, 0				; initialize the counter

_compareAB:
	; compare the value and the next value
	MOV		EAX, [ESI]
	CMP		EAX, EBX
	JE		_countIncrease
	JNE		_storeCount

_countIncrease:
	INC		EDX
	ADD		ESI, 4
	JMP		_compareAB		


_storeCount:
	; Store the count into the counts array
	MOV		[EDI], EDX
	ADD		EDI, 4
	MOV		EDX, 0

	INC		EBX
	CMP		EBX, HI
	JG		_endCount
	LOOP	_compareAB

	
_endCount:
	POP		EBP
	RET		8
countList	ENDP


; ---------------------------------------Goodbye message-----------------------------------------
; Procedure Description: This procedure says goodbye to the user
; Preconditions: the address of goodbye message is on stack
; Post-conditions: NONE
farewell	PROC
	PUSH	EBP
	MOV		EBP, ESP
	MOV		EDX, [EBP + 8]
	CALL	WriteString

	POP		EBP
	RET		4
farewell	ENDP

END main
