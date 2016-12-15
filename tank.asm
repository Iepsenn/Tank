.data
	TankColor: .word 0xC0C0C0 	 # cinza
	EraseColor: .word 0x000000	 # preto
	
.text
	jal Cenario
	nop
	jal Begin
	nop
	
	# $s7 flag para a ponta do cano
	#
	#   =====
	#    === 
	#    ======
	#    ===                       
	#   =====
	#
	
	Main:
		li $v0, 12
		syscall
		nop
		move $s0, $v0
		li $s6, 0 # seta a flag que indica se ha um objeto a frente 
		beq $s0, 0x77, Up    # 0x77 = w na tabela ascii
		nop
		beq $s0, 0x73, Down  #  0x73 = s na tabela ascii
		nop
		beq $s0, 0x61, Left   #  0x61 = a na tabela ascii
		nop
		beq $s0, 0x64, Right  #  0x64 = d na tabela ascii
		nop
		beq $0, 0x0, End
		
		Up:
			jal Erase # apaga o tanque para reescrevelo
			nop
			beq $v1, 0x77, AddUp # pula se a última ação ($v1) também tiver sido uptank
			nop
			jal UpTank  # se o tanque NÃO estiver virado pra cima então será virado
			nop
			j Main
			nop
			AddUp:
				jal Verifica
				nop
				beq $s6, 1, UpContinue
				nop
				j nextUp
				nop
				UpContinue: jal UpTank
					    nop
					    j Main
					    nop
				nextUp:	    
				add $gp, $gp, -0x200  # se o tanque já estiver pra cima, subirá uma linha  
				jal UpTank
				nop
				j Main
				nop


		Down:
			jal Erase
			nop
			beq $v1, 0x73, AddDown # pula se a última ação ($v1) também tiver sido downtank
			jal DownTank
			nop
			j Main
			nop
			AddDown:
				jal Verifica
				nop
				beq $s6, 1, DownContinue
				nop
				j nextDown
				nop
			      DownContinue: jal DownTank
					    nop
					    j Main
					    nop
				nextDown:
				add $gp, $gp, 0x200 # desce uma linha
				jal DownTank
				nop
				j Main
				nop
		
		
		Left:
			jal Erase
			nop
			beq $v1, 0x61, AddLeft
			jal LeftTank
			nop
			j Main
			nop
			AddLeft:
				jal Verifica
				nop
				beq $s6, 1, LeftContinue
				nop
				j nextLeft
				nop
			      LeftContinue: jal LeftTank
					    nop
					    j Main
					    nop
				nextLeft:
				add $gp, $gp, -0x4 # anda uma coluna à esquerda
				jal LeftTank
				nop
				j Main
				nop


		Right:
			jal Erase
			nop
			beq $v1, 0x64, AddRight
			jal RightTank
			nop
			j Main
			nop
			AddRight:
				jal Verifica
				nop
				beq $s6, 1, RightContinue
				nop
				j nextRight
				nop
			      RightContinue: jal RightTank
					    nop
					    j Main
					    nop
				nextRight:	    
				add $gp, $gp, 0x4 # uma coluna à direita
				jal RightTank
				nop
				j Main
				nop
		
		End:
			li $v0, 10
			syscall
			
####################################################################################################################################

RightTank:	
############################################################################################
####### pra criar as rodas do tanque, $a0 as da posição 0x0 e $a1 as da posição 0x800 ######
############################################################################################
	move $a0, $gp 		# ponteiro para as rodas 0x0

	
		
				move $a1, $gp
	addi $a1, $a1, 0x800	# ponteiro para as rodas 0x800
	li $t2, 0		# zera contador antes de entrar no loop
	RightTankWheels: 
		beq $t2, 0x5, RightTankMiddle
		nop
		lw $t1, TankColor
		sw $t1, 0($a0)	# printa 'roda' 0x0
		sw $t1, 0($a1)	# printa 'roda' 0x800
		addi $a0, $a0, 0x4 # incrementa pra proxima posição (0x4, 0x8, 0xC, 0x10)
		addi $a1, $a1, 0x4 # (0x804, 0x808, 0x80C, 0x810)
		addi $t2, $t2, 1   # incrementa contador	
	j RightTankWheels
	nop
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x204, $a1 na posição 0x208 e $a2 na posição 0x20C ######
##############################################################################################################
	RightTankMiddle:
		move $a0, $gp	 	
		addi $a0, $a0, 0x204	# ponteiro
		move $a1, $gp
		addi $a1, $a1, 0x208	# ponteiro
		move $a2, $gp
		addi $a2, $a2, 0x20C	# ponteiro
		li $t2, 0		# zera contador antes de entrar no loop
		RightTankMiddle1:
			beq $t2, 0x3, RightTankGun
			nop
			lw $t1, TankColor
			sw $t1, 0($a0)	# printa o 'meio'
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do 'meio' (0x204, 0x404, 0x604, etc)
			addi $a1, $a1, 0x200	# (0x208, 0x408, 0x608, etc)
			addi $a2, $a2, 0x200	# (0x20C, 0x40C, 0x60C, etc)
			addi $t2, $t2, 1	# contador
		j RightTankMiddle1
		nop
############################################################
####### cria o 'cano' do tanque, $a0 na posição 0x410 ######
############################################################
		RightTankGun:
			move $a0, $gp	 	
			addi $a0, $a0, 0x410 # ponteiro
			li $t2, 0	     # zera contador
			RightTankGun1:
				beq $t2, 0x3, NowTankIsRight
				nop
				lw $t1, TankColor
				sw $t1, 0($a0)
				addi $a0, $a0, 0x4 # incrementa pra próxima posição (0x410, 0x414, 0x418)
				addi $t2, $t2, 1   # contador
				move $s7, $a0 # flag ponta do cano
				j RightTankGun1
				nop
		NowTankIsRight:
################################################################################################################################
### 		$v1 guarda a posição pra qual o tanque virou, quando a função é chamada essa flag é comparada                ###
### 		pra decidir seu o tanque só vira ou se também se move.                                                       ###
### ex.:                                                                                                    	             ###
###      jal Right # (0x64 será armazenado em $v1)                                                                           ###
###      nop                                                                                                                 ###
###      (o tanque neste momento está virado para a direita)                                                                 ###
###	 beq $v1, 0x61, AddLeft # (se $v1 fosse 0x61 pularia p/ AddLeft, como n é só faz LeftTank e vira o tank pra esquerda)###
###		jal LeftTank                                                                                                 ###
###		nop                                                                                                          ###
###			AddLeft: (função a qual incrementaria $gp pra mover o tanque se ele estivesse virado pra esquerda)   ###
###				add $gp, $gp, -0x4                                                                           ###
###				jal LeftTank                                                                                 ###
###				nop                                                                                          ###
################################################################################################################################
		nop
		li $a0, 0
		li $a1, 0
		li $a2, 0	# zera os registradores usados (só pra garantir msm risos)
		li $v1, 0x64	# flag q sinaliza pra qual lado o tanque virou
		jr $ra
		
#################################################################################################################################

LeftTank:
############################################################################################
####### pra criar as rodas do tanque, $a0 as da posição 0x8 e $a1 as da posição 0x808 ######
############################################################################################	
	move $a0, $gp 		
	addi $a0, $a0, 0x8	# ponteiro para as rodas 0x8
	move $a1, $gp
	addi $a1, $a1, 0x808	# ponteiro para as rodas 0x808
	li $t2, 0		# zera contador
	LeftTankWheels: 
		beq $t2, 0x5, LeftTankMiddle
		nop
		lw $t1, TankColor
		sw $t1, 0($a0)		# printa roda 0x8
		sw $t1, 0($a1)		# printa roda 0x808 
		addi $a0, $a0, 0x4	# incrementa pra proxima posição (0xC, 0x10, 0x14, 0x18)
		addi $a1, $a1, 0x4	# (0x808, 0x80C, 0x810, 0x814)
		addi $t2, $t2, 1	# incrementa contador
	j LeftTankWheels
	nop
	LeftTankMiddle:
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x20C, $a1 na posição 0x210 e $a2 na posição 0x214 ######
##############################################################################################################
		move $a0, $gp	 	
		addi $a0, $a0, 0x20C	# ponteiro
		move $a1, $gp	 	
		addi $a1, $a1, 0x210	# ponteiro
		move $a2, $gp	 	
		addi $a2, $a2, 0x214	# ponteiro
		li $t2, 0		# zera o contador
		LeftTankMiddle1:
			beq $t2, 0x3, LeftTankGun
			nop
			lw $t1, TankColor
			sw $t1, 0($a0)	# printa o meio
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do meio (0x20C, 0x40C, 0x60C)
			addi $a1, $a1, 0x200	# (0x210, 0x410, 0x610)
			addi $a2, $a2, 0x200	# (0x214, 0x414, 0x614)
			addi $t2, $t2, 1
		j LeftTankMiddle1
		nop
		LeftTankGun:
############################################################
####### cria o 'cano' do tanque, $a0 na posição 0x400 ######
############################################################
			move $a0, $gp	 	# ponteiro
			addi $a0, $a0, 0x400
			li $t2, 0
			LeftTankGun1:
				beq $t2, 0x3, NowTankIsLeft
				nop
				lw $t1, TankColor
				sw $t1, 0($a0)
				addi $a0, $a0, 0x4
				addi $t2, $t2, 1
				move $s7, $a0 # flag ponta do cano
				j LeftTankGun1
				nop
		NowTankIsLeft:
		nop
		li $a0, 0
		li $a1, 0
		li $a2, 0	# zera os registradores usados
		li $v1, 0x61	# sinaliza pra qual lado o tanque virou
		jr $ra
		
###################################################################################################################################

UpTank:	
############################################################################################
####### pra criar as rodas do tanque, $a0 as da posição 0x0 e $a1 as da posição 0x10 #######
############################################################################################
	move $a0, $gp 		# ponteiro para as rodas 0x0
	addi $a0, $a0, 0x400	# soma 400 pq TankUp precisa pular duas linhas (por causa do cano)
	move $a1, $gp 		
	addi $a1, $a1, 0x410	# ponteiro para as rodas 0x10
	li $t2, 0
	UpTankWheels: 
		beq $t2, 0x5, UpTankMiddle
		nop
		lw $t1, TankColor
		sw $t1, 0($a0)		# printa roda
		sw $t1, 0($a1)
		addi $a0, $a0, 0x200	# incrementa pra proxima linha (0x400, 0x600, 0x800, 0xA00)
		addi $a1, $a1, 0x200	# (0x410, 0x610, 0x810, 0xA10)
		addi $t2, $t2, 1	# incrementa ponteiro
	j UpTankWheels
	nop
	UpTankMiddle:
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x604, $a1 na posição 0x608 e $a2 na posição 0x60C ######
##############################################################################################################
		move $a0, $gp	 	# ponteiro
		addi $a0, $a0, 0x604
		move $a1, $gp	 	# ponteiro
		addi $a1, $a1, 0x608
		move $a2, $gp	 	# ponteiro
		addi $a2, $a2, 0x60C
		li $t2, 0		# zera contador
		UpTankMiddle1:
			beq $t2, 0x3, UpTankGun
			nop
			lw $t1, TankColor
			sw $t1, 0($a0)	# printa o meio
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima posição (0x604, 0x804, 0xA04)
			addi $a1, $a1, 0x200	# (0x610, 0x810, 0xA10)
			addi $a2, $a2, 0x200	# (0x614, 0x814, 0xA14)
			addi $t2, $t2, 1
		j UpTankMiddle1
		nop
		UpTankGun:
##########################################################
####### cria o 'cano' do tanque, $a0 na posição 0x8 ######
##########################################################
			move $a0, $gp	 	# ponteiro
			addi $a0, $a0, 0x8	
			li $t2, 0		# zera contador
			uptankgun1:
				beq $t2, 0x3, NowTankIsUp
				nop
				lw $t1, TankColor
				sw $t1, 0($a0)
				addi $a0, $a0, 0x200	# incrementa pra próxima posição (0x208, 0x408, 0x608)
				addi $t2, $t2, 1
				move $s7, $a0 # flag ponta do cano
				j uptankgun1
				nop
		NowTankIsUp:
		nop
		li $a0, 0
		li $a1, 0
		li $a2, 0	# zera os registradores usados
		li $v1, 0x77	# sinaliza pra qual lado o tanque virou
		jr $ra
		
####################################################################################################################################

DownTank:	
###########################################################################################
####### pra criar as rodas do tanque, $a0 as da posição 0x0 e $a1 as da posição 0x10 ######
###########################################################################################
	move $a0, $gp 		# ponteiro pras rodas 0x0
	move $a1, $gp 		
	addi $a1, $a1, 0x10	# ponteiro pras rodas 0x10
	li $t2, 0		# zera contador
	DownTankWheels: 
		beq $t2, 0x5, DownTankMiddle
		nop
		lw $t1, TankColor
		sw $t1, 0($a0)
		sw $t1, 0($a1)
		addi $a0, $a0, 0x200	# incrementa pra proxima linha (0x0, 0x200, 0x400, 0x600, 0x800)
		addi $a1, $a1, 0x200	# (0x10, 0x210, 0x410, 0x610, 0x810)
		addi $t2, $t2, 1
	j DownTankWheels
	nop
	DownTankMiddle:
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x204, $a1 na posição 0x208 e $a2 na posição 0x20C ######
##############################################################################################################
		move $a0, $gp	 	
		addi $a0, $a0, 0x204	# ponteiro
		move $a1, $gp
		addi $a1, $a1, 0x208	# ponteiro
		move $a2, $gp
		addi $a2, $a2, 0x20C	# ponteiro
		li $t2, 0		# zera contador antes de entrar no loop
		DownTankMiddle1:
			beq $t2, 0x3, DownTankGun
			nop
			lw $t1, TankColor
			sw $t1, 0($a0)	# printa o 'meio'
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do 'meio' (0x204, 0x404, 0x604, etc)
			addi $a1, $a1, 0x200	# (0x208, 0x408, 0x608, etc)
			addi $a2, $a2, 0x200	# (0x20C, 0x40C, 0x60C, etc)
			addi $t2, $t2, 1	# contador
		j DownTankMiddle1
		nop
		DownTankGun:
##########################################################
####### cria o 'cano' do tanque, $a0 na posição 0x808 ####
##########################################################
			move $a0, $gp	 	# ponteiro
			addi $a0, $a0, 0x808
			li $t2, 0		# zera contador
			DownTankGun1:
				beq $t2, 0x3, NowTankIsDown
				nop
				lw $t1, TankColor
				sw $t1, 0($a0)
				addi $a0, $a0, 0x200	# incrementa pra próxima posição (0x808, 0xA08, 0xC08)
				addi $t2, $t2, 1	# incrementa contador
				move $s7, $a0 # flag ponta do cano
				j DownTankGun1
				nop
		NowTankIsDown:
		nop
		li $a0, 0
		li $a1, 0
		li $a2, 0	# zera os registradores usados
		li $v1, 0x73	# sinaliza pra qual lado o tanque virou
		jr $ra

###################################################################################################################################

Erase:
	move $a0, $gp	 	# ponteiro
	li $t2, 0		# zera contador de linhas
	j EraseY		# pula pro EraseY
	NextX:
		addi $t2, $t2, 1 # incrementa pra próx linha~
		addi $a0, $a0, 0x1E8 # 0x200 - 0x18 = 0x1E8 (0x200 de cada linha - 0x18 que é onde o $a0 estava por causa do EraseX)
	EraseY:
		li $t3, 0	# zera contador de colunas
		beq $t2, 0x8, Done # número de linhas
		nop
		EraseX:
			#lw $t1, EraseColor	
			li $t1, 0x000000
			sw $t1, 0($a0)
			beq $t3, 0x18, NextX # quando $t3 = 0x18 acabou a linha, pula pra NextX
			nop
			addi $t3, $t3, 0x4   # incrementa $t3
			addi $a0, $a0, 0x4   # incrementa $a0  pra proxima coluna
			j EraseX
			nop
	Done:
		li $a0, 0
		li $t1, 0
		li $t2, 0
		li $t3, 0	# zera registradores usados
		nop
		jr $ra
		nop

####################################################################################################################################
####################################################################################################################################
########                     MAPA
####################################################################################################################################
Cenario:

addi $t0, $gp,7680
addi $t1, $gp,7684
addi $t2, $gp,7688
#--------------
addi $t3, $gp, 8180
addi $t4, $gp, 8184
addi $t5, $gp, 8188
addi $t7, $gp, 65536
                                                      # 65536
lw $t6, TankColor
vertical: beq $t0, $t7, horizontal
	  nop
	  sw $t6, 0($t0)
	  sw $t6, 0($t1)
	  sw $t6, 0($t2)
	  sw $t6, 0($t3)
	  sw $t6, 0($t4)
	  sw $t6, 0($t5)
	  addi $t0, $t0, 512
	  addi $t1, $t1, 512
	  addi $t2, $t2, 512
	  addi $t3, $t3, 512
	  addi $t4, $t4, 512
	  addi $t5, $t5, 512
	  j vertical
	  nop
horizontal: addi $t0, $gp, 7692
	    addi $t1, $gp, 8204
	    addi $t2, $gp, 8716
            #--------------
            addi $t3, $gp, 65032
            addi $t4, $gp, 64520
            addi $t5, $gp, 64008
            addi $t7, $gp, 8184

           lw $t6, TankColor #contem a cor das bordas 
	  for:  beq $t0, $t7, baseesq
	        nop
	  	sw $t6, 0($t0)
	  	sw $t6, 0($t1)
	  	sw $t6, 0($t2)
	  	sw $t6, 0($t3)
	  	sw $t6, 0($t4)
	  	sw $t6, 0($t5)
	  	addi $t0, $t0, 4
	  	addi $t1, $t1, 4
	  	addi $t2, $t2, 4
	  	addi $t3, $t3, 4
	  	addi $t4, $t4, 4
	  	addi $t5, $t5, 4
	  	j for
	  	nop
	  	
baseesq: addi $t0, $gp, 27732  
         addi $t1, $gp, 28244  
         addi $t2, $gp, 28756 
        #------------ 
      	 addi $t3, $gp, 46164
      	 addi $t4, $gp, 45652
     	 addi $t5, $gp, 45140 
     	 li $t7, 0 #counter	
     
    printBase:  beq $t7, 8, printBaseVert
		nop
		sw $t6, 0($t0)
		sw $t6, 0($t1)
		sw $t6, 0($t2)
		sw $t6, 0($t3)
		sw $t6, 0($t4)
		sw $t6, 0($t5)
		addi $t0, $t0, 4
		addi $t1, $t1, 4
		addi $t2, $t2, 4
		addi $t3, $t3, 4
		addi $t4, $t4, 4
		addi $t5, $t5, 4
		addi $t7, $t7, 1 	
		j printBase
		nop

printBaseVert:  addi $t0, $gp, 29296
		addi $t1, $gp, 29292
		addi $t2, $gp, 29288
		li $t7, 0 #counter
		  for2: beq $t7, 31, basedir
			nop
			sw $t6, 0($t0)
			sw $t6, 0($t1)
			sw $t6, 0($t2)
			addi $t0, $t0, 512
			addi $t1, $t1, 512
			addi $t2, $t2, 512
			addi $t7, $t7, 1
			j for2
			nop
			
############################################################################	
basedir: addi $t0, $gp, 28064  
         addi $t1, $gp, 28576 
         addi $t2, $gp, 29088 
        #------------ 
      	 addi $t3, $gp, 46496
      	 addi $t4, $gp, 45984
     	 addi $t5, $gp, 45472
     	 li $t7, 0 #counter	
     
     
    printBase2:  beq $t7, 8, printBaseVert2
		nop
		sw $t6, 0($t0)
		sw $t6, 0($t1)
		sw $t6, 0($t2)
		sw $t6, 0($t3)
		sw $t6, 0($t4)
		sw $t6, 0($t5)
		subi $t0, $t0, 4
		subi $t1, $t1, 4
		subi $t2, $t2, 4
		subi $t3, $t3, 4
		subi $t4, $t4, 4
		subi $t5, $t5, 4
		addi $t7, $t7, 1 	
		j printBase2
		nop

printBaseVert2:  addi $t0, $gp, 29580
		 addi $t1, $gp, 29576
		 addi $t2, $gp, 29572
		 li $t7, 0 #counter
		  for3: beq $t7, 31, meio
			nop
			sw $t6, 0($t0)
			sw $t6, 0($t1)
			sw $t6, 0($t2)
			addi $t0, $t0, 512
			addi $t1, $t1, 512
			addi $t2, $t2, 512
			addi $t7, $t7, 1
			j for3
			nop	
############################################# 
# 	28064 --------- 27732 
#	46496 --------- 46164
############################################# 

meio: addi $t0, $gp, 27900
      addi $t1, $gp, 27896
      addi $t2, $gp, 27904 
      
      addi $t3, $gp, 46332
      addi $t4, $gp, 46336
      addi $t5, $gp, 46328 
      li $t7, 0 #counter
          objmeio: beq $t7, 12, lados 
          	nop
      		sw $t6, 0($t0)
		sw $t6, 0($t1)
		sw $t6, 0($t2)
		sw $t6, 0($t3)
		sw $t6, 0($t4)
		sw $t6, 0($t5)
		subi $t0, $t0, 512
		subi $t1, $t1, 512
		subi $t2, $t2, 512
		addi $t3, $t3, 512
		addi $t4, $t4, 512
		addi $t5, $t5, 512
		addi $t7, $t7, 1
		j objmeio
		nop
lados: addi $t0, $gp, 37196
       addi $t1, $gp, 37708
       addi $t2, $gp, 36684 #200 #-12
      
       addi $t3, $gp, 36520
       addi $t4, $gp, 37032 #-200 #+12
       addi $t5, $gp, 36008
       li $t7, 0 #counter				
       objlados: beq $t7, 10, fim 
          	nop
      		sw $t6, 0($t0)
		sw $t6, 0($t1)
		sw $t6, 0($t2)
		sw $t6, 0($t3)
		sw $t6, 0($t4)
		sw $t6, 0($t5)
		subi $t0, $t0, 4
		subi $t1, $t1, 4
		subi $t2, $t2, 4
		addi $t3, $t3, 4
		addi $t4, $t4, 4
		addi $t5, $t5, 4
		addi $t7, $t7, 1
		j objlados
		nop
fim: jr $ra
     nop
#####################################################################################################################################
#######				DETECTOR DE COLISAO
#################################################################################################################################

Verifica:  beq $a0, 0x77, VerUp    
	     nop
	     beq $s0, 0x73, VerDown  
		nop
		beq $s0, 0x61, VerLeft   
		  nop
		  beq $s0, 0x64, VerRight  
		  nop
		  
	 VerUp: #subi $s7, $s7, 512
	 	subi $t1, $s7, 4 # LADO ESQUERDO CANO
	 	addi $t2, $s7, 4 # LADO DIREITO CANO 
	 	subi $t3, $s7, 8 
	 	addi $t4, $s7, 8  
	
	 	lw $t5, 0($s7)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag
	 	   	  nop
	       j Fim
	       nop
	       
       VerDown: addi $s7, $s7, 512
	 	subi $t1, $s7, 4 # LADO ESQUERDO CANO
	 	addi $t2, $s7, 4 # LADO DIREITO CANO 
	 	subi $t3, $s7, 8 
	 	addi $t4, $s7, 8  
	
	 	lw $t5, 0($s7)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag
	 	   	  nop
	       j Fim
	       nop
	  
      VerRight: addi $s7, $s7, 4
	 	subi $t1, $s7, 512 # LADO ESQUERDO CANO
	 	addi $t2, $s7, 512 # LADO DIREITO CANO 
	 	subi $t3, $s7, 1024 
	 	addi $t4, $s7, 1024  
	
	 	lw $t5, 0($s7)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag
	 	   	  nop
	       j Fim
	       nop
	       
       VerLeft: #subi $s7, $s7, 4
	 	subi $t1, $s7, 512 # LADO ESQUERDO CANO
	 	addi $t2, $s7, 512 # LADO DIREITO CANO 
	 	subi $t3, $s7, 1024 
	 	addi $t4, $s7, 1024  
	
	 	lw $t5, 0($s7)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag
	 	   	  nop
	       j Fim
	       nop
	           
	   Fim:    jr $ra
	           nop
	  SetFlag: li $s6, 1
	  	   jr $ra
	           nop
	 
#####################################################################################################################################
############			        	ERASEs (fail)
#####################################################################################################################################
EraseRight:         li $t1, 0   #contadores 
		    li $t2, 0
		    li $t3, 0
		    move $t4, $s7
		    li $t5, 0x000000 #preto
		    RightGun:beq $t1, 6, MiddleRight
		    	nop
		    	sw $t5, 0($t4)
		    	subi $t4, $t4, 4
		    	addi $t1, $t1, 1
		    	j RightGun
		    	nop
		    MiddleRight: subi $t6, $s7, 24
		    		 subi $t7, $t6, 512 #acima do cano
		    		 addi $t6, $t6, 512 #abaixo do cano
		    		 PrintMid: beq $t2, 3, RoadsRight
		    		 	   nop
		    		 	   sw $t5, 0($t6)
		    			   sw $t5, 0($t7)
		    			   addi $t6, $t6, 4
		    			   addi $t7, $t7, 4
		    			   addi $t2, $t2, 1
		    			   j PrintMid
		    			   nop
	            RoadsRight:  subi $t6, $s7, 28
		    		 subi $t7, $t6, 1024 #rodas de cima
		    		 addi $t6, $t6, 1024 #rodas de baixo
		    		 PrintRoads: beq $t3, 5, EndEraseRight
		    		 	   nop
		    		 	   sw $t5, 0($t6)
		    			   sw $t5, 0($t7)
		    			   addi $t6, $t6, 4
		    			   addi $t7, $t7, 4
		    			   addi $t3, $t3, 1
		    			   j PrintRoads
		    			   nop
		   EndEraseRight: jr $ra
		   		  nop
#####################################################################################################################################
############			        	BEGIN
#####################################################################################################################################
Begin:	addi $gp, $gp, 35912
	move $a0, $gp 		# ponteiro para as rodas 0x0

	
		
				move $a1, $gp
	addi $a1, $a1, 0x800	# ponteiro para as rodas 0x800
	li $t2, 0		# zera contador antes de entrar no loop
	BeginTankWheels: 
		beq $t2, 0x5, BeginTankMiddle
		nop
		lw $t1, TankColor
		sw $t1, 0($a0)	# printa 'roda' 0x0
		sw $t1, 0($a1)	# printa 'roda' 0x800
		addi $a0, $a0, 0x4 # incrementa pra proxima posição (0x4, 0x8, 0xC, 0x10)
		addi $a1, $a1, 0x4 # (0x804, 0x808, 0x80C, 0x810)
		addi $t2, $t2, 1   # incrementa contador	
	j BeginTankWheels
	nop
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x204, $a1 na posição 0x208 e $a2 na posição 0x20C ######
##############################################################################################################
	BeginTankMiddle:
		move $a0, $gp	 	
		addi $a0, $a0, 0x204	# ponteiro
		move $a1, $gp
		addi $a1, $a1, 0x208	# ponteiro
		move $a2, $gp
		addi $a2, $a2, 0x20C	# ponteiro
		li $t2, 0		# zera contador antes de entrar no loop
		BeginTankMiddle1:
			beq $t2, 0x3, BeginTankGun
			nop
			lw $t1, TankColor
			sw $t1, 0($a0)	# printa o 'meio'
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do 'meio' (0x204, 0x404, 0x604, etc)
			addi $a1, $a1, 0x200	# (0x208, 0x408, 0x608, etc)
			addi $a2, $a2, 0x200	# (0x20C, 0x40C, 0x60C, etc)
			addi $t2, $t2, 1	# contador
		j BeginTankMiddle1
		nop
############################################################
####### cria o 'cano' do tanque, $a0 na posição 0x410 ######
############################################################
		BeginTankGun:
			move $a0, $gp	 	
			addi $a0, $a0, 0x410 # ponteiro
			li $t2, 0	     # zera contador
			BeginTankGun1:
				beq $t2, 0x3, NowTankBegin
				nop
				lw $t1, TankColor
				sw $t1, 0($a0)
				addi $a0, $a0, 0x4 # incrementa pra próxima posição (0x410, 0x414, 0x418)
				addi $t2, $t2, 1   # contador
				move $s7, $a0 # flag ponta do cano
				j BeginTankGun1
				nop
		NowTankBegin:
		 	  nop
			  li $a0, 0
			  li $a1, 0
			  li $a2, 0	# zera os registradores usados (só pra garantir msm risos)
			  li $v1, 0x64	# flag q sinaliza pra qual lado o tanque virou
			  jr $ra
		
