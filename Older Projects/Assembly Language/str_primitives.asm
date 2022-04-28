TITLE Project 6: String Primitives and Macros     (str_primitives.asm)

; Author: Mitchell Brown
; Last Modified: 12/1/2020
; OSU email address: brownmit@oregonstate.edu
; Code originally written for Computer Architecture and Assembly Language (OSU CS 271)
; Description: Use string primitives and macros to retrieve and print numerical values

INCLUDE Irvine32.inc

; -------------------------------------------------------------------------
; Name: mGetString
;
; Gets a string representing an integer from the user
;
; Preconditions: Values must fit in a 32-bit register
;
; Receives:
; promptAddress    = The address of the printed prompt
; bufferAddress    = The address of the input buffer
; bufferSize       = The size of the input buffer
;
; returns: EAX     = The user entered string 
;          EDX     = The length of the entered string
; -------------------------------------------------------------------------
mGetString MACRO promptAddress, bufferAddress, bufferSize
  ; Read the string
  MOV	EDX, promptAddress
  CALL	WriteString
  MOV	EDX, bufferAddress
  MOV	ECX, bufferSize
  CALL	ReadString
  PUSH	EAX
  PUSH	EDX

ENDM

; -------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints a string representing an integer
;
; Preconditions: Values must fit in a 32-bit register
;
; Receives:
; strAddress       = The address of the string to be printed
;
; returns: None.
; -------------------------------------------------------------------------
mDisplayString MACRO strAddress
  MOV	EDX, strAddress
  CALL	WriteString
ENDM
  

INLENGTH = 12

.data

  intro1		BYTE	"Programming Assignment 6: Designing Low-level I/O Procedures, written byte Mitchell Brown",0
  intro2		BYTE	"Enter 10 Signed integers which fit in aaa 32-bit register. After all 10 are entered, the integers will be displayed along with their sum and average.",0
  input			BYTE	"Please enter a signed number: ",0
  inputErr		BYTE	"ERROR: Not a valid number, try again",0
  inputBuffer	DWORD	INLENGTH DUP(?)
  strLen		DWORD	10 DUP(?)
  sumAvgLen		DWORD	?
  outVal		SDWORD	10 DUP(?)
  negSymbol		BYTE	"-",0
  printArr		DWORD	INLENGTH DUP(?)
  printSep		BYTE	", ",0
  arrSum		SDWORD	?
  results		BYTE	"The numbers you entered are:",0
  sumPrint		BYTE	"The sum of the values is: ",0
  avgPrint		BYTE	"The rounded average is: ",0
  goodbye		BYTE	"Thanks for using this program!",0

.code
main PROC
; Intro
  MOV	EDX, OFFSET intro1
  CALL	WriteString
  CALL	CrLf

  MOV	EDX, OFFSET intro2
  CALL	WriteString
  CALL	CrLf

; User input
  MOV	ECX, 10
  MOV	EDI, OFFSET outVal
  MOV	EAX, OFFSET strLen

_inputLoop:
  ; Preserve certain registers
  PUSH	ECX
  PUSH	EDI
  PUSH	EAX

  ; Get user Input
  PUSH	EDI
  PUSH	OFFSET inputErr
  PUSH	TYPE inputBuffer
  PUSH	OFFSET input
  PUSH	OFFSET inputBuffer
  PUSH	INLENGTH
  PUSH	EAX
  CALL	ReadVal

  ; Increment the array addresses for value and strLen storage
  POP	EAX	
  POP	EDI
  MOV	EBX, TYPE outVal
  ADD	EAX, EBX
  ADD	EDI, EBX

  POP	ECX
  LOOP	_inputLoop


; Print the user input
  MOV	ECX, 10
  MOV	ESI, OFFSET outVal
  MOV	EAX, OFFSET	strLen

_printLoop:
  ; Preserve certain registers
  PUSH	ECX
  PUSH	ESI
  PUSH	EAX

  ; Print the current pointed value
  PUSH	OFFSET negSymbol
  PUSH	OFFSET printArr
  PUSH	[EAX]
  PUSH	[ESI]
  CALL	WriteVal

  ; Increment locations in the strLen and value arrays
  POP	EAX	
  POP	ESI
  MOV	EBX, TYPE outVal
  ADD	EAX, EBX
  ADD	ESI, EBX

  ; Skip printing a comma if it is the last value
  POP	ECX
  CMP	ECX, 1
  JE	_skipComma

  MOV	EDX, OFFSET printSep
  CALL	WriteString
_skipComma:
  LOOP	_printLoop
  
  CALL	CrLf

; Print sum and Average
  MOV	ESI, OFFSET outVal
  MOV	EBX, TYPE outVal
  MOV	ECX, 10
  MOV	EAX, 0
  
  ; Sum up all the values
_sumLoop:
  MOV	EDX, [ESI]
  ADD	EAX, EDX
  ADD	ESI, EBX
  LOOP	_sumLoop
  PUSH	EAX

  ; Find the length of the string version of the current value
  PUSH	OFFSET sumAvgLen
  PUSH	EAX
  CALL	findStrLen	

  MOV	EDX, OFFSET sumPrint
  CALL	WriteString

  ; Print the sum
  PUSH	OFFSET negSymbol
  PUSH	OFFSET printArr
  PUSH	sumAvgLen
  PUSH	EAX
  CALL	WriteVal
  
  CALL	CrLf

; Print the rounded average
  POP	EAX ; Grab the preserved sum value
  MOV	EBX, 10
  CDQ
  DIV	EBX

  ; Find the length of the string version of the average
  PUSH	OFFSET sumAvgLen
  PUSH	EAX
  CALL	findStrLen	

  MOV	EDX, OFFSET avgPrint
  CALL	WriteString

  ; Print the average
  PUSH	OFFSET negSymbol
  PUSH	OFFSET printArr
  PUSH	sumAvgLen
  PUSH	EAX
  CALL	WriteVal

  CALL	CrLf

; Say Goodbye
	MOV	EDX, OFFSET goodbye
  CALL	WriteString
  CALL	CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; -------------------------------------------------------------------------
; Name: ReadVal
;
; Reads in string bytes, then converts them to an SDWORD integer
;
; Preconditions: The value fits in a 32-bit register, with an optional "-" or "+" leading character
;
; Postconditions: A location to store the returned value
;
; Receives:
;     [EBP+32]    = outVal Address
;     [EBP+28]    = Input Error string
;     [EBP+24]    = TYPE of input string
;     [EBP+20]    = Prompt Address
;     [EBP+16]    = Buffer Address
;     [EBP+12]    = Buffer Size 
;     [EBP+8]     = strLen
;
; Returns: EDI    = outVal Address
;
; -------------------------------------------------------------------------
ReadVal PROC
  PUSH	EBP
  MOV	EBP, ESP

_userInput:
  mGetString [EBP+20],[EBP+16],[EBP+12]
  POP	ESI	; Address of input
  POP	ECX ; Size of input
  PUSH	ECX ; Store for later
  MOV	EBX, [EBP+24] ; Type of input string
  MOV	EDI, [EBP+32] ; outVal Address

  ; Make sure the value fits in a 32-bit register
  CMP	ECX, 11
  JGE	_notNum

  ; Check if the first symbol is a + or - sign
  MOV	AL, BYTE PTR [ESI]
  CMP	EAX, 45
  JE	_negativeInput
  PUSH	1
  CMP	EAX, 43
  JE	_plusSign
  
_convertString:
  ; Beging loading string bits and setting up for moving through the array
  CLD
  MOV	EAX, 0
  LODSB

  ; Make sure the ASCII values of the string byte are in the range 0 to 9
  CMP	EAX, 57
  JG	_notNum
  CMP	EAX, 48
  JL	_notNum

  ; Convert from ASCII to decimal
  SUB	EAX, 48

  PUSH	ECX
  PUSH	EAX
  DEC	ECX
  MOV	EAX, 1
  CMP	ECX, 0
  JE	_skipValFactor
_valFactor:
  ; Multiply by a factor of 10^n to get the proper value
  MOV	EBX, 10
  MUL	EBX
  LOOP	_valFactor
_skipValFactor:
  MOV	EBX, EAX

  POP	EAX
  MUL	EBX

  ; Sum up the string bits
  ADD	[EDI], EAX

  POP	ECX
  LOOP	_convertString

  ; Multiply by 1 or -1 depending on the leading symbol
  POP	EBX ; Pop sign into EBX
  MOV	EAX, [EDI]
  MUL	EBX
  MOV	[EDI], EAX

  ; Make sure the input fits in the proper range
  CMP	EAX, 2147483647
  JGE	_notNum
  CMP	EAX, -2147483648
  JLE	_notNum

  POP	ECX ; Size of input
  MOV	EAX, [EBP+8] ; strLen
  MOV	[EAX], ECX ; Return the string length

  POP EBP
  RET 28

_negativeInput:
  ; Handles the first digit being -
  DEC	ECX
  PUSH	-1
  LODSB
  JMP	_convertString

_plusSign:
; Handles the first digit being +
  DEC	ECX
  LODSB
  JMP	_convertString

_notNum:
  ; Reset user input if it is not in 0 to 9 with an optional leading + or -
  PUSH	EDX
  MOV	EDX, [EBP+28] ; inputError
  CALL	WriteString
  CALL	CrLf
  POP	EDX
  POP	ECX
  JMP	_userInput

ReadVal ENDP

; -------------------------------------------------------------------------
; Name: WriteVal
;
; Converts an SDWORD integer into a string
;
; Preconditions: The length of the string is known
;
; Postconditions: None
;
; Receives:
;     [EBP+20]    = Negative Symbol Address
;     [EBP+16]    = printArr Address
;     [EBP+12]    = strLen
;     [EBP+8]     = outVal
;
; Returns: None
;
; -------------------------------------------------------------------------
WriteVal PROC
  PUSH	EBP
  MOV	EBP, ESP

; Convert Numeric Value into string
  MOV	EAX, [EBP+8]  ; outVal
  MOV	ECX, [EBP+12] ; strLen
  MOV	EDI, [EBP+16] ; printArr Address
  PUSH	EDI
  MOV	EDX, [EBP+20] ; Negative Symbol Address
  
  ; Check if the input value is negative
  CMP	EAX, 0
  JL	_negativeVal

_toString:
  PUSH	ECX
  PUSH	EAX	

  ; Find the factor of 10 to divide the value by to get the leading digit
  DEC	ECX
  MOV	EAX, 1
  CMP	ECX, 0
  JE	_skipDivFactor
  _divFactor:
    MOV		EBX, 10
	MUL		EBX
	LOOP	_divFactor
  _skipDivFactor:

  ; Divide the value to get the leading digit
  MOV	EBX, EAX
  POP	EAX
  CDQ
  DIV	EBX

  ; Convert from decimal to ASCII, then store the value
  ADD	EAX, 48
  STOSB

  ; Grab the remainder
  MOV	EAX, EDX

  POP	ECX
  LOOP _toString

  ; Store the null terminator at the end of the string
  MOV	AL, 0
  STOSB

; Call mDisplayString
  POP	EDI
  mDisplayString EDI

  POP	EBP
  RET	16

_negativeVal:
  ; Handle negative values by storing a "-" string bit, then taking the absolute value for processing
  DEC	ECX
  PUSH	EAX
  MOV	EAX, [EDX]
  STOSB
  POP	EAX
  MOV	EBX, -1
  MUL	EBX
  JMP	_toString

WriteVal ENDP

; -------------------------------------------------------------------------
; Name: findStrLen
;
; Finds the length of the string version of an integer
;
; Preconditions: The value is an integer
;
; Postconditions: None
;
; Receives:
;     [EBP+12]    = Address of return value
;     [EBP+8]     = outValNumeric Value
;
; Returns: ECX    = The length of the string
;
; -------------------------------------------------------------------------
findStrLen PROC
  PUSH	EBP
  MOV	EBP, ESP

  MOV	EAX, [EBP+8]  ; Numeric Value
  MOV	EDX, [EBP+12] ; Address of return value
  PUSH	EDX

  MOV	ECX, 10
_strLenLoop:
  ; Find the number of digits in the value
  CMP	ECX, 1
  JE	_retLen
  PUSH	ECX
  PUSH	EAX
  MOV	EAX, 1
  DEC	ECX
  _findFactor:
    ; Divide by a factor of 10 to move through the value
    MOV		EBX, 10
	MUL		EBX
	LOOP	_findFactor

  ; End the loop once the end of the value is found
  MOV	EBX, EAX
  POP	EAX
  PUSH	EAX
  CDQ
  DIV	EBX
  CMP	EAX, 0
  POP	EAX
  POP	ECX
  JNE    _retLen
  
  LOOP	_strLenLoop

_retLen:
  
  POP	EDX
  MOV	[EDX], ECX ; Return length of string

  POP	EBP
  RET	8
findStrLen ENDP

END main
