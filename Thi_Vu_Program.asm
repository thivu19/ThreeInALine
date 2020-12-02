.data
	# Prompt
	welcome: .asciiz "=== Welcome to Three in a Line ==="
	instruction: .asciiz "\nTo win: Connect 3 pieces in a row, column or diagonally\n"
	inputPrompt: .asciiz "\nSelect a column to place your piece (1-3): "
	myArrayBoard: .asciiz "\n- - - \n- - - \n- - - \n- - - \n- - - \n- - - \n"
	PlayerTurn: .asciiz "\nPlayer's Turn"
	CPUTurn: .asciiz "\nCPU's Turn\n"
	
	# Invalid Prompt
	inputError: .asciiz "\nError: Input invalid column placement \nPlease reenter ...\n"
	fullColError: .asciiz "\nColumn selected is full. Please select a different column..."
	boardFilled: .asciiz "\nThe board is full! No spaces left!"
	
	# Winner
	OPlayer: .asciiz "\nCPU has won the game!"
	XPlayer: .asciiz "\nPlayer has won the game!"
	tie: .asciiz "\nIt is a tie!"
	
	
.text
main: 
	# Storing the number of columns in registers
	li $t1, 1
	li $t2, 2
 	li $t3, 3
 	li $s0, 36
 	li $s1, 38
 	li $s2, 40
 	li $s6, 'X'
	li $s7, 'O'
 
	li $v0, 4			# 4 - print string, code in $v0
	la $a0, welcome
	syscall
	
	li $v0, 4			# 4 - print string, code in $v0
	la $a0, instruction
	syscall
		
	jal Board
	j userInput
	
#------Display board
Board:
	li $v0, 4			# 4 - print string, code in $v0
	la $a0, myArrayBoard
	syscall
	jr $ra
	
#------Select Column
userInput:
	# Checking if user win
	jal CheckWinner
	# Checking if all the columns in the board are full
	add $s4, $s0, $s1
	add $s4, $s4, $s2
	beq $s4, -12, boardFull
	
	# Indicating that its the players turn
	li $v0, 4
	la $a0, PlayerTurn
	syscall
	
	li $v0, 4			# 4 - print string, code in $v0
	la $a0, inputPrompt
	syscall
	
	li $v0, 5			# 5 - read integer, code in $v0
	syscall
	
	li $t1, 1
	li $t2, 2
 	li $t3, 3
	# Checking for validity of the column entered by the user
	beq $t1, $v0, columnOne
    	beq $t2, $v0, columnTwo
   	beq $t3, $v0, columnThree
   	j invalidColumn

#------Computer Player
CPU:	
	# Checking if CPU win
	jal CheckWinner
	# Checking if all the columns in the board are full
	add $s4, $s0, $s1
	add $s4, $s4, $s2
	beq $s4, -12, boardFull
	
	li $v0, 4
	la $a0, CPUTurn
	syscall
# Generates a valid random column value for the CPU
CPUrandCol:
	li $t1, 1
	li $t2, 2
 	li $t3, 3

	li $v0, 42 		# Generate a random number from 0-2
	la $a1, 3
	syscall
	
	addi $a0, $a0, 1 	# Add one to 0-2
	move $v0, $a0		# store CPU column value 
	
	# Checking for validity of the column entered by the user
	beq $t1, $v0, columnOneCPU
    	beq $t2, $v0, columnTwoCPU
   	beq $t3, $v0, columnThreeCPU
   	j CPUrandCol		# If column is invalid call CPU again
   

#------Validation for Column Input
# Code for column 1:
columnOne:
	# Checking if the column is empty or not
	blt $s0, 1, columnFull
	
	sb $s6, myArrayBoard($s0)
	addi $s0, $s0, -7
   	jal Board 	
    	j CPU
columnOneCPU:
	# Checking if the column is empty or not
	# If full go to CPUrandCol
	blt $s0, 1, CPUrandCol	
	
	sb $s7, myArrayBoard($s0)
	addi $s0, $s0, -7
   	jal Board
    	j userInput
    	
# Code for column 2:
columnTwo:
	# Checking if the column is empty or not
	blt $s1, 3, columnFull
	
   	sb $s6, myArrayBoard($s1)
	addi $s1, $s1, -7
   	jal Board	
    	j CPU
columnTwoCPU:
	# Checking if the column is empty or not
	# If full go to CPUrandCol
	blt $s1, 3, CPUrandCol
	
   	sb $s7, myArrayBoard($s1)
	addi $s1, $s1, -7
   	jal Board
    	j userInput
    		
# Code for column 3:
columnThree:
	# Checking if the column is empty or not
	blt $s2, 5, columnFull
	
   	sb $s6, myArrayBoard($s2)
	addi $s2, $s2, -7
   	jal Board
    	j CPU
columnThreeCPU:
	# Checking if the column is empty or not
	# If full go to CPUrandCol
	blt $s2, 5, CPUrandCol
	
   	sb $s7, myArrayBoard($s2)
	addi $s2, $s2, -7
   	jal Board
    	j userInput	


#------Check Winner
CheckWinner:
	la $a0, myArrayBoard
# Checks Row
RowX:
	lb $t0, 36($a0)			
	lb $t1, 38($a0)
	lb $t2, 40($a0)
	bne $t0, $s6, RowO		
	bne $t1, $s6, RowO 		
	bne $t2, $s6, RowO		
	j WinnerPromptX
RowO:
	bne $t0, $s7, incRow		
	bne $t1, $s7, incRow		
	bne $t2, $s7, incRow		
	j WinnerPromptO
incRow:
	blt $t0, 1, Col1		# If $t0 < 1 then go check Col1
	addi $a0, $a0, -7
	j RowX

# Column Winner	
# Checking for winner in column 1
Col1:
	la $a0, myArrayBoard	
COL1X:
	lb $t0, 36($a0)			
	lb $t1, 29($a0)
	lb $t2, 22($a0)
	bne $t0, $s6, COL1O  
	bne $t1, $s6, COL1O
	bne $t2, $s6, COL1O
	j WinnerPromptX
COL1O:	
	bne $t0, $s7, incCOL1		
	bne $t1, $s7, incCOL1		
	bne $t2, $s7, incCOL1		
	j WinnerPromptO
incCOL1:
	blt $t0, 1, Col2		# If $t0 < 1 then go check Col2
	addi $a0, $a0, -7
	j COL1X	
	
# Checking for winner in column 2
Col2:
	la $a0, myArrayBoard
COL2X:
	lb $t0, 38($a0)			
	lb $t1, 31($a0)
	lb $t2, 24($a0)
	bne $t0, $s6, COL2O  
	bne $t1, $s6, COL2O
	bne $t2, $s6, COL2O
	j WinnerPromptX
COL2O:	
	bne $t0, $s7, incCOL2	
	bne $t1, $s7, incCOL2		
	bne $t2, $s7, incCOL2		
	j WinnerPromptO
incCOL2:
	blt $t0, 1, Col3		# If $t0 < 1 then go check Col3
	addi $a0, $a0, -7
	j COL2X	
	
# Checking for winner in column 3
Col3:
	la $a0, myArrayBoard
COL3X:
	lb $t0, 40($a0)			
	lb $t1, 33($a0)
	lb $t2, 26($a0)
	bne $t0, $s6, COL3O  
	bne $t1, $s6, COL3O
	bne $t2, $s6, COL3O
	j WinnerPromptX
COL3O:	
	bne $t0, $s7, incCOL3	
	bne $t1, $s7, incCOL3		
	bne $t2, $s7, incCOL3		
	j WinnerPromptO
incCOL3:
	blt $t0, 1, DRL		# If $t0 < 1 then go check DRL
	addi $a0, $a0, -7
	j COL3X	
	
# Diagonal Right to Left Winner
DRL:
	la $a0, myArrayBoard
DRLX:
	lb $t0, 22($a0)			
	lb $t1, 31($a0)
	lb $t2, 40($a0)
	bne $t0, $s6, DRLO  
	bne $t1, $s6, DRLO
	bne $t2, $s6, DRLO
	j WinnerPromptX
DRLO:	
	bne $t0, $s7, incDRL		
	bne $t1, $s7, incDRL		
	bne $t2, $s7, incDRL		
	j WinnerPromptO
incDRL:
	blt $t2, 1, DLR		# If $t2 < 1 then go check DLR
	addi $a0, $a0, -7
	j DRLX
	
# Diagonal Left to Right Winner
DLR:
	la $a0, myArrayBoard
DLRX:
	lb $t0, 36($a0)			
	lb $t1, 31($a0)
	lb $t2, 26($a0)
	bne $t0, $s6, DLRO  
	bne $t1, $s6, DLRO
	bne $t2, $s6, DLRO
	j WinnerPromptX
DLRO:	
	bne $t0, $s7, incDLR		
	bne $t1, $s7, incDLR		
	bne $t2, $s7, incDLR		
	j WinnerPromptO
incDLR:
	blt $t0, 5, return		# If $t2 < 5 then return
	addi $a0, $a0, -7
	j DLRX	
return: 
	jr $ra

#------Winner Prompt
WinnerPromptX:
	li $v0, 4			
	la $a0, XPlayer
	syscall	
	j Exit
WinnerPromptO:
	li $v0, 4			
	la $a0, OPlayer
	syscall
	j Exit
	
#------Invalid Message
# Player's input is invalid
invalidColumn:
	li $v0, 4			
	la $a0, inputError
	syscall
	j userInput
# Column is full
columnFull:
	li $v0, 4			
	la $a0, fullColError
	syscall
	j userInput
# Board is full
boardFull:
	li $v0, 4			
	la $a0, boardFilled
	syscall
	li $v0, 4
	la $a0, tie
	syscall
	j Exit
	
#------End program
Exit:	li $v0, 10			
	syscall

