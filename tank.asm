#########################################################################################
# COMANDOS                                                                              #
# -No modo Multiplayer:									#								
#	   player 1: w a s d b , respectivamente cima, esquerda, baixo, direita e tiro	#													   
#	   player 2: i j k l m , respectivamente cima, esquerda, baixo, direita e tiro	#													       
# 											#											
# -No modo Singleplayer:								#							    
#	   player 1: w a s d b , respectivamente cima, esquerda, baixo, direita e tiro	#														
#											#						    				
# -comandos comuns a todos modos:							#							
#		pause: p								#					            		
#		end: e									#										
#											#					        				
#											#									        
#  FLAGS                                                                                #
# -tank1    tank2                                                                       #
#   v1    =  a3 	 ultima posiçao do tank                                         #
#   s7    =  s3  	 ponta do cano                                                  #
#   s6    =  s4  	 verifica se há um objeto à frente                              #
#   s5    =  s1  	 verifica pra onde vai atirar                                   #
#   gp    =  k1          ponteiros para $gp                                                                     #
#- indices flag tiro  ---- > 1 - right   2 - left   3 - up   4 - dowm			#									           				    
#											#						
#	usar entrada do terminal para comandos						#
######  Keyboard and Display MMIO Simulator so e usado no modo multiplayer  #############								 		    																		                
#########################################################################################

##################################################
# Unit Width in Pixels: 4;                       #
# Unit Height in Pixels: 4;                      #
# Display Width in Pixels: 512;                  #
# Display Height in Pixels: 512;                 #
# Base address for display: 0x10008000 ($gp);    #
# ultilizar Keyboard and Display MMIO Simulator; #
##################################################

.data
	BorderColor: .word 0xC0C0C0 	 # cinza
	EraseColor: .word 0x000000	 # preto
	BulletColor: .word 0xFF0000	 # vermelho
	TankColor:   .word 0x0000FF 	 # azul
	TankColor2:   .word 0xFFFF00 	 # amarelo
	TankIScore: .word 0
	TankIIScore: .word 0
	Ponteiro: .word 0x10080000
	flag: .word -1
	
.text 
	move $s2, $gp #ponteiro tanque 2
	move $k1, $gp
	jal GameOpening
	nop
	jal ClearGameOpening
	nop
InicioDoJogo:
	jal Cenario3
	nop
	jal Begin
	nop
	jal Begin2
	nop
	jal DrawZeroScore1
	nop
	jal X
	nop
	jal DrawZeroScore2
	nop
	
	
	#
	#   =====
	#    === 
	#    ======
	#    ===                       
	#   =====
	
	
	
	Main:
		li $v0, 12
		syscall
		nop
		move $s0, $v0
		li $s6, 0 # seta a flag que indica se ha um objeto a frente 
		li $s4, 0 # seta a flag que indica se ha um objeto a frente do tanque 2 
		beq $s0, 0x77, Up    # 0x77 = w na tabela ascii
		nop
		beq $s0, 0x73, Down  #  0x73 = s na tabela ascii
		nop
		beq $s0, 0x61, Left   #  0x61 = a na tabela ascii
		nop
		beq $s0, 0x64, Right  #  0x64 = d na tabela ascii
		nop
		beq $s0, 0x62, BangBang #b
		nop
		####### tanque 2
		beq $s0, 0x69, Up2    # i
		nop
		beq $s0, 0x6b, Down2  # k
		nop
		beq $s0, 0x6a, Left2  # j
		nop 
		beq $s0, 0x6c, Right2 # l
		nop
		beq $s0, 0x6d, BangBang2 # m
		nop
		beq $s0, 0x70, Pause # p
		nop
		beq $s0, 0x65, End 
		nop
		j Main
		nop
		
		BangBang:
			beq $s5, 1, isRight
			nop
			beq $s5, 2, isLeft
			nop
			beq $s5, 3, isUp
			nop
			beq $s5, 4, isDown
			nop
			
			isRight: jal ShootRight
				 nop
				 j endBang
				 nop
		       isLeft: jal ShootLeft
				 nop
				 j endBang
				 nop
		       isUp: jal ShootUp
				 nop
				 j endBang
				 nop
		       isDown: jal ShootDown
				 nop
				 j endBang
				 nop
			endBang: #li $s5, 0
				 j Main
			         nop
		
		
		
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
				beq $s6, 1, UpContinue #encontrou um objeto a frente
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
		li $t1, 0x0000FF 
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
			li $t1, 0x0000FF 
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
				li $t1, 0x0000FF 
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
		li $t2, 0
		li $a2, 0	# zera os registradores usados (só pra garantir msm risos)
		li $v1, 0x64	# flag q sinaliza pra qual lado o tanque virou
		li $s5, 1  #flag direçao tiro
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
		li $t1, 0x0000FF 
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
			li $t1, 0x0000FF 
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
			move $s7, $a0 # flag ponta do cano
			li $t2, 0
			LeftTankGun1:
				beq $t2, 0x3, NowTankIsLeft
				nop
				li $t1, 0x0000FF 
				sw $t1, 0($a0)
				addi $a0, $a0, 0x4
				addi $t2, $t2, 1
				#move $s7, $a0 # flag ponta do cano
				j LeftTankGun1
				nop
		NowTankIsLeft:
		nop
		li $a0, 0
		li $a1, 0
		li $t2, 0
		li $a2, 0	# zera os registradores usados
		li $v1, 0x61	# sinaliza pra qual lado o tanque virou
		li $s5, 2  #flag direçao tiro
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
		li $t1, 0x0000FF 
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
			li $t1, 0x0000FF 
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
			move $s7, $a0 # flag ponta do cano	
			li $t2, 0		# zera contador
			uptankgun1:
				beq $t2, 0x3, NowTankIsUp
				nop
				li $t1, 0x0000FF 
				sw $t1, 0($a0)
				addi $a0, $a0, 0x200	# incrementa pra próxima posição (0x208, 0x408, 0x608)
				addi $t2, $t2, 1
				#move $s7, $a0 # flag ponta do cano
				j uptankgun1
				nop
		NowTankIsUp:
		nop
		li $a0, 0
		li $a1, 0
		li $t2, 0
		li $a2, 0	# zera os registradores usados
		li $v1, 0x77	# sinaliza pra qual lado o tanque virou
		li $s5, 3  #flag direçao tiro
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
		li $t1, 0x0000FF 
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
			li $t1, 0x0000FF 
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
				li $t1, 0x0000FF 
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
		li $t2, 0
		li $v1, 0x73	# sinaliza pra qual lado o tanque virou
		li $s5, 4  #flag direçao tiro
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
		
Cenario3:
li $gp, 0
lui $gp, 0x1000
addi $gp, $gp, 0x8000
addi $t0, $gp,7680
addi $t1, $gp,7684
addi $t2, $gp,7688
#--------------
addi $t3, $gp, 8180
addi $t4, $gp, 8184
addi $t5, $gp, 8188
addi $t7, $gp, 65536
                                                      # 65536
li $t6, 0xC0C0C0
vertical3: beq $t0, $t7, horizontal3
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
	  j vertical3
	  nop
horizontal3: addi $t0, $gp, 7692
	    addi $t1, $gp, 8204
	    addi $t2, $gp, 8716
            #--------------
            addi $t3, $gp, 65032
            addi $t4, $gp, 64520
            addi $t5, $gp, 64008
            addi $t7, $gp, 8184

           li $t6, 0xC0C0C0 #contem a cor das bordas 
	  forhorizontal3:  beq $t0, $t7, baseesq3
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
	  	j forhorizontal3
	  	nop
	  	
baseesq3: addi $t0, $gp, 27732  
         addi $t1, $gp, 28244  
         addi $t2, $gp, 28756 
        #------------ 
      	 addi $t3, $gp, 46164
      	 addi $t4, $gp, 45652
     	 addi $t5, $gp, 45140 
     	 li $t7, 0 #counter	
     
    printBaseesq3:  beq $t7, 8, printBasedir3
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
		j printBaseesq3
		nop

printBasedir3:  addi $t0, $gp, 29296
		addi $t1, $gp, 29292
		addi $t2, $gp, 29288
		li $t7, 0 #counter
		  forhorizontal223: beq $t7, 31, basedir3
			nop
			sw $t6, 0($t0)
			sw $t6, 0($t1)
			sw $t6, 0($t2)
			addi $t0, $t0, 512
			addi $t1, $t1, 512
			addi $t2, $t2, 512
			addi $t7, $t7, 1
			j forhorizontal223
			nop
			
############################################################################	
basedir3: addi $t0, $gp, 28064  
         addi $t1, $gp, 28576 
         addi $t2, $gp, 29088 
        #------------ 
      	 addi $t3, $gp, 46496
      	 addi $t4, $gp, 45984
     	 addi $t5, $gp, 45472
     	 li $t7, 0 #counter	
     
     
    printBase3hor:  beq $t7, 8, printBasedir3ver
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
		j printBase3hor
		nop

printBasedir3ver:  addi $t0, $gp, 29580
		 addi $t1, $gp, 29576
		 addi $t2, $gp, 29572
		 li $t7, 0 #counter
		  forprintBasedir3ver: beq $t7, 31, ObjDir31
			nop
			sw $t6, 0($t0)
			sw $t6, 0($t1)
			sw $t6, 0($t2)
			addi $t0, $t0, 512
			addi $t1, $t1, 512
			addi $t2, $t2, 512
			addi $t7, $t7, 1
			j forprintBasedir3ver
			nop	
############################################# 
# 	28064 --------- 27732 
#	46496 --------- 46164
############################################# 
ObjDir31: addi $t0, $gp, 27944  
         addi $t1, $gp, 28456 
         addi $t2, $gp, 28968 
        #------------ 
      	 addi $t3, $gp, 46376
      	 addi $t4, $gp, 45864
     	 addi $t5, $gp, 45352
     	 li $t7, 0 #counter	
     
     
    printObjDir31:  beq $t7, 6, ObjEsq31
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
		j printObjDir31
		nop
		
ObjEsq31: addi $t0, $gp, 27852  
         addi $t1, $gp, 28364  
         addi $t2, $gp, 28876 
        #------------ 
      	 addi $t3, $gp, 46284
      	 addi $t4, $gp, 45772
     	 addi $t5, $gp, 45260 
     	 li $t7, 0 #counter	
     
    printObjEsq31:  beq $t7, 6, ObjEsq32
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
		j printObjEsq31
		nop
		
ObjEsq32:  addi $t0, $gp, 29396
		addi $t1, $gp, 29392
		addi $t2, $gp, 29388
		addi $t4, $gp, 45260
		addi $t5, $gp, 45264
		addi $t9, $gp, 45268
		li $t7, 0 #counter
		  forhorizontalObjEsq32: beq $t7, 10, ObjDir32
			nop
			sw $t6, 0($t0)
			sw $t6, 0($t1)
			sw $t6, 0($t2)
			sw $t6, 0($t4)
			sw $t6, 0($t5)
			sw $t6, 0($t9)
			subi $t4, $t4, 512
			subi $t5, $t5, 512
			subi $t9, $t9, 512
			addi $t0, $t0, 512
			addi $t1, $t1, 512
			addi $t2, $t2, 512
			addi $t7, $t7, 1
			j forhorizontalObjEsq32
			nop
			
ObjDir32:  addi $t0, $gp, 29480
		 addi $t1, $gp, 29476
		 addi $t2, $gp, 29472
		 addi $t4, $gp, 45344
		 addi $t5, $gp, 45348
		 addi $t9, $gp, 45352 
		 li $t7, 0 #counter
		  forhorizontalObjDir32: beq $t7, 10, objBase3
			nop
			sw $t6, 0($t0)
			sw $t6, 0($t1)
			sw $t6, 0($t2)
			sw $t6, 0($t4)
			sw $t6, 0($t5)
			sw $t6, 0($t9)
			addi $t0, $t0, 512
			addi $t1, $t1, 512
			addi $t2, $t2, 512
			subi $t4, $t4, 512
			subi $t5, $t5, 512
			subi $t9, $t9, 512
			addi $t7, $t7, 1
			j forhorizontalObjDir32
			nop			
			
objBase3: addi $t1, $gp, 24468
	    addi $t2, $gp, 50068
	    addi $t4, $gp, 24160
	    addi $t5, $gp, 49760
	    li $t7, 0
	    li $t9, 0
	    forobjBase3: beq $t7, 12, forobjBase32 # ate 12 
			nop
			sw $t6, 0($t1)
			sw $t6, 0($t2)
			sw $t6, 0($t4)
			sw $t6, 0($t5)
			subi $t1, $t1, 4
			subi $t2, $t2, 4
			addi $t4, $t4, 4
			addi $t5, $t5, 4
			addi $t7, $t7, 1
			j forobjBase3
			nop
	   forobjBase32:	beq $t9, 3, objmeio3
	   		nop
	   		li $t7, 0
	   		subi $t1, $t1, 472
	   		addi $t2, $t2, 552
	   		subi $t4, $t4, 552
	   		addi $t5, $t5, 472
	   		addi $t9, $t9, 1						
			j forobjBase3
			nop
			
objmeio3: addi $t8, $gp, 9452
	 addi $t0, $gp, 9456
	 addi $t1, $gp, 9460
	 addi $t2, $gp, 9464
	 addi $t4, $gp, 9468
	 addi $t5, $gp,	9472
	 addi $t9, $gp, 9476
	 li $t7, 0
	 forobjmeio3: beq $t7, 8, objmeio32
	 	     nop
	 	     sw $t6, 0($t0)
		     sw $t6, 0($t1)
		     sw $t6, 0($t2)
		     sw $t6, 0($t4)
	             sw $t6, 0($t5)
	             sw $t6, 0($t8)
	             sw $t6, 0($t9)
		     addi $t8, $t8, 512
	             addi $t9, $t9, 512
		     addi $t0, $t0, 512
	             addi $t1, $t1, 512
		     addi $t2, $t2, 512
		     addi $t4, $t4, 512
	             addi $t5, $t5, 512
		     addi $t7, $t7, 1
		     j forobjmeio3
		     nop
		     
objmeio32:addi $t8, $gp, 64236 
	 addi $t0, $gp, 64240
	 addi $t1, $gp, 64244
	 addi $t2, $gp, 64248
	 addi $t4, $gp, 64252
	 addi $t5, $gp,	64256
	 addi $t9, $gp, 64260
	 li $t7, 0
	 forobjmeio32: beq $t7, 8, fim
	 	     nop
	 	     sw $t6, 0($t0)
		     sw $t6, 0($t1)
		     sw $t6, 0($t2)
		     sw $t6, 0($t4)
	             sw $t6, 0($t5)
	             sw $t6, 0($t8)
	             sw $t6, 0($t9)
		     subi $t8, $t8, 512
	             subi $t9, $t9, 512
		     subi $t0, $t0, 512
	             subi $t1, $t1, 512
		     subi $t2, $t2, 512
		     subi $t4, $t4, 512
	             subi $t5, $t5, 512
		     addi $t7, $t7, 1
		     j forobjmeio32
		     nop		     
	 	     	     									
fim: jr $ra
     nop	

#####################################################################################################################################
#######				DETECTOR DE COLISAO
#################################################################################################################################

Verifica:   li $t1, 0
	    li $t2, 0
   	    li $t3, 0
	    li $t4, 0
	    li $t5, 0
	    li $t6, 0
	    li $t7, 0
   	    li $t8, 0
	    li $t9, 0
	 
	    beq $s0, 0x77, VerUp    
	     nop
	     beq $s0, 0x73, VerDown  
		nop
		beq $s0, 0x61, VerLeft   
		  nop
		  beq $s0, 0x64, VerRight  
		  nop
		  j Fim
		  nop
		  
	 VerUp: subi $s7, $s7, 512
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
	  
      VerRight: #addi $s7, $s7, 4
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
	       
       VerLeft: subi $s7, $s7, 4
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
############			        	BEGIN
#####################################################################################################################################
Begin:	
	li $gp, 0
	lui $gp, 0x1000
	addi $gp, $gp, 0x8000
	addi $gp, $gp, 35912
	move $a0, $gp 		# ponteiro para as rodas 0x0

	
		
	move $a1, $gp
	addi $a1, $a1, 0x800	# ponteiro para as rodas 0x800
	li $t2, 0		# zera contador antes de entrar no loop
	BeginTankWheels: 
		beq $t2, 0x5, BeginTankMiddle
		nop
		li $t1, 0x0000FF 
		sw $t1, 0($a0)	# printa 'roda' 0x0
		sw $t1, 0($a1)	# printa 'roda' 0x800
		addi $a0, $a0, 0x4 # incrementa pra proxima posição (0x4, 0x8, 0xC, 0x10)
		addi $a1, $a1, 0x4 # (0x804, 0x808, 0x80C, 0x810)
		addi $t2, $t2, 1   # incrementa contador	
	j BeginTankWheels
	nop

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
			li $t1, 0x0000FF 
			sw $t1, 0($a0)	# printa o 'meio'
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do 'meio' (0x204, 0x404, 0x604, etc)
			addi $a1, $a1, 0x200	# (0x208, 0x408, 0x608, etc)
			addi $a2, $a2, 0x200	# (0x20C, 0x40C, 0x60C, etc)
			addi $t2, $t2, 1	# contador
		j BeginTankMiddle1
		nop

		BeginTankGun:
			move $a0, $gp	 	
			addi $a0, $a0, 0x410 # ponteiro
			li $t2, 0	     # zera contador
			BeginTankGun1:
				beq $t2, 0x3, NowTankBegin
				nop
				li $t1, 0x0000FF 
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
			  li $s5, 1  #flag direçao 
			  jr $ra


#####################################################################################################################################
############			        	SHOOT 
#####################################################################################################################################
ShootRight: 	move $t1, $s7
	addi $t1, $t1, 4 # proxima posiçao a partir do cano 
	addi $t2, $t1, 4
	li $t3, 0
	li $t4, 0x000000
	li $t5, 0xFF0000
	
	########## som do tiro ################################################
	move $t8, $a3 # ponteiro do tanque 2 (apenas pra n perder ele)         #
									       #
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 2000                                                           #
	li $a2, 126                                                          #
	li $a3, 127                                                            #
	syscall								       #				
									       #
	move $a3, $t8 # devolve o valor do ponteiro                            #
	########################################################################
	
	Wncr: lw $t6, 0($t2) 
	     beq $t6, 0xC0C0C0, EndShootRight	# BorderColor
	     nop
	     beq $t6, 0xFFFF00, Tank1Hit	# acertou tiro no tank 2
	     nop
	     sw $t5, 0($t1)
	     move $t9, $t1
	     addi $t1, $t1, 4
	     addi $t2, $t2, 4
	     
	     BulletRight: beq $t3, 999, BackShootRight
	     	     nop
	     	     addi $t3, $t3, 1
	     	     
	     	     j BulletRight
	     	     nop
	     BackShootRight: li $t3, 0
	     		sw $t4, 0($t9)
	     		j Wncr
	     		nop
	     		
	EndShootRight: jr $ra
		  nop
	     	

ShootLeft: 	move $t1, $s7
	subi $t1, $t1, 4 # proxima posiçao a partir do cano 
	subi $t2, $t1, 4
	li $t3, 0
	li $t4, 0x000000
	li $t5, 0xFF0000
	
	########## som do tiro ################################################
	move $t8, $a3 # ponteiro do tanque 2 (apenas pra n perder ele)         #
									       #
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 2000                                                           #
	li $a2, 126                                                            #
	li $a3, 127                                                            #
	syscall								       #				
									       #
	move $a3, $t8 # devolve o valor do ponteiro                            #
	########################################################################
	
	Wncl: lw $t6, 0($t2) 
	     beq $t6, 0xc0c0c0, EndShootLeft
	     nop
	     beq $t6, 0xFFFF00, Tank1Hit
	     nop
	     sw $t5, 0($t1)
	     move $t9, $t1
	     subi $t1, $t1, 4
	     subi $t2, $t2, 4
	     
	     BulletLeft: beq $t3, 999, BackShootLeft
	     	     nop
	     	     addi $t3, $t3, 1
	     	     
	     	     j BulletLeft
	     	     nop
	     BackShootLeft: li $t3, 0
	     		sw $t4, 0($t9)
	     		j Wncl
	     		nop
	     		
	EndShootLeft: jr $ra
		      nop
	
	
ShootUp: 	move $t1, $s7
	subi $t1, $t1, 512 # proxima posiçao a partir do cano 
	subi $t2, $t1, 512
	li $t3, 0
	li $t4, 0x000000
	li $t5, 0xFF0000
	
	########## som do tiro ################################################
	move $t8, $a3 # ponteiro do tanque 2 (apenas pra n perder ele)         #
									       #
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 2000                                                           #
	li $a2, 126                                                            #
	li $a3, 127                                                            #
	syscall								       #				
									       #
	move $a3, $t8 # devolve o valor do ponteiro                            #
	########################################################################
	
	Wncu: lw $t6, 0($t2) 
	     beq $t6, 0xc0c0c0, EndShootUp
	     nop
	     beq $t6, 0xFFFF00, Tank1Hit
	     nop
	     sw $t5, 0($t1)
	     move $t9, $t1
	     subi $t1, $t1, 512
	     subi $t2, $t2, 512
	     
	     BulletUp: beq $t3, 999, BackShootUp
	     	     nop
	     	     addi $t3, $t3, 1
	     	     
	     	     j BulletUp
	     	     nop
	     BackShootUp: li $t3, 0
	     		sw $t4, 0($t9)
	     		j Wncu
	     		nop
	     		
	EndShootUp: jr $ra
		      nop
	
	
ShootDown: 	move $t1, $s7
	addi $t1, $t1, 512 # proxima posiçao a partir do cano 
	addi $t2, $t1, 512
	li $t3, 0
	li $t4, 0x000000
	li $t5, 0xFF0000
	
	########## som do tiro ################################################
	move $t8, $a3 # ponteiro do tanque 2 (apenas pra n perder ele)         #
									       #
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 2000                                                           #
	li $a2, 126                                                            #
	li $a3, 127                                                            #
	syscall								       #				
									       #
	move $a3, $t8 # devolve o valor do ponteiro                            #
	########################################################################
	
	Wncd: lw $t6, 0($t2) 
	     beq $t6, 0xc0c0c0, EndShootDown
	     nop
	     beq $t6, 0xFFFF00, Tank1Hit
	     nop
	     sw $t5, 0($t1)
	     move $t9, $t1
	     addi $t1, $t1, 512
	     addi $t2, $t2, 512
	     
	     BulletDown: beq $t3, 999, BackShootDown
	     	     nop
	     	     addi $t3, $t3, 1
	     	     
	     	     j BulletDown
	     	     nop
	     BackShootDown: li $t3, 0
	     		sw $t4, 0($t9)
	     		j Wncd
	     		nop
	     		
	EndShootDown: jr $ra
		      nop
		      
	Tank1Hit: 
		sw $ra, ($sp)
		jal ExplosionTank1
		nop
		li $s2, 0
		lui $s2, 0x1000
		addi $s2, $s2, 0x8000
		jal ScoreI
		nop
		jal Begin2
		nop
		lw $ra, ($sp)
		jr $ra	
		nop
#####################################################################################################################################
############			        	BEGIN tanque 2
#####################################################################################################################################
Begin2:	addi $s2, $s2, 36244
	move $a0, $s2 		# ponteiro para as rodas 0x0

	
		
				move $a1, $s2
	addi $a1, $a1, 0x800	# ponteiro para as rodas 0x800
	li $t2, 0		# zera contador antes de entrar no loop
	BeginTankWheels2: 
		beq $t2, 0x5, BeginTankMiddle2
		nop
		li $t1, 0xFFFF00
		sw $t1, 0($a0)	# printa 'roda' 0x0
		sw $t1, 0($a1)	# printa 'roda' 0x800
		addi $a0, $a0, 0x4 # incrementa pra proxima posição (0x4, 0x8, 0xC, 0x10)
		addi $a1, $a1, 0x4 # (0x804, 0x808, 0x80C, 0x810)
		addi $t2, $t2, 1   # incrementa contador	
	j BeginTankWheels2
	nop

BeginTankMiddle2:
		move $a0, $s2	 	
		addi $a0, $a0, 0x204	# ponteiro
		move $a1, $s2
		addi $a1, $a1, 0x208	# ponteiro
		move $a2, $s2
		addi $a2, $a2, 0x20C	# ponteiro
		li $t2, 0		# zera contador antes de entrar no loop
		BeginTankMiddle12:
			beq $t2, 0x3, BeginTankGun2
			nop
			li $t1, 0xFFFF00
			sw $t1, 0($a0)	# printa o 'meio'
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do 'meio' (0x204, 0x404, 0x604, etc)
			addi $a1, $a1, 0x200	# (0x208, 0x408, 0x608, etc)
			addi $a2, $a2, 0x200	# (0x20C, 0x40C, 0x60C, etc)
			addi $t2, $t2, 1	# contador
		j BeginTankMiddle12
		nop

		BeginTankGun2:
			move $a0, $s2	 	
			addi $a0, $a0, 0x410 # ponteiro
			li $t2, 0	     # zera contador
			BeginTankGun12:
				beq $t2, 0x3, NowTankBegin2
				nop
				li $t1, 0xFFFF00
				sw $t1, 0($a0)
				addi $a0, $a0, 0x4 # incrementa pra próxima posição (0x410, 0x414, 0x418)
				addi $t2, $t2, 1   # contador
				move $s3, $a0 # flag ponta do cano
				j BeginTankGun12
				nop
		NowTankBegin2:
		 	  nop
			  li $a0, 0
			  li $a1, 0
			  li $a2, 0	# zera os registradores usados (só pra garantir msm risos)
			  li $a3, 0x6c	# flag q sinaliza pra qual lado o tanque virou
			   li $s1, 0x1 # flag tiro
			  jr $ra
			  
			  
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################

#####################################################################################################################################
#################################################################################################################################
#####################################################################################################################################
#################################################################################################################################
#####################################################################################################################################
#################################################################################################################################
#                            TANQUE 2
#####################################################################################################################################
#################################################################################################################################
#####################################################################################################################################
#################################################################################################################################
####################################################################################################################################
Up2:
			jal Erase2 # apaga o tanque para reescrevelo
			nop
			beq $a3, 0x69, AddUp2 # pula se a última ação ($a3) também tiver sido uptank
			nop
			jal UpTank2  # se o tanque NÃO estiver virado pra cima então será virado
			nop
			j Main
			nop
			AddUp2:
				jal Verifica2
				nop
				beq $s4, 1, UpContinue2
				nop
				j nextUp2
				nop
				UpContinue2: jal UpTank2
					    nop
					    j Main
					    nop
				nextUp2:	    
				add $s2, $s2, -0x200  # se o tanque já estiver pra cima, subirá uma linha  
				jal UpTank2
				nop
				j Main
				nop


		Down2:
			jal Erase2
			nop
			beq $a3, 0x6b, AddDown2 # pula se a última ação ($a3) também tiver sido downtank
			jal DownTank2
			nop
			j Main
			nop
			AddDown2:
				jal Verifica2
				nop
				beq $s4, 1, DownContinue2
				nop
				j nextDown2
				nop
			      DownContinue2: jal DownTank2
					    nop
					    j Main
					    nop
				nextDown2:
				add $s2, $s2, 0x200 # desce uma linha
				jal DownTank2
				nop
				j Main
				nop
		
		
		Left2:
			jal Erase2
			nop
			beq $a3, 0x6a, AddLeft2
			jal LeftTank2
			nop
			j Main
			nop
			AddLeft2:
				jal Verifica2
				nop
				beq $s4, 1, LeftContinue2
				nop
				j nextLeft2
				nop
			      LeftContinue2: jal LeftTank2
					    nop
					    j Main
					    nop
				nextLeft2:
				add $s2, $s2, -0x4 # anda uma coluna à esquerda
				jal LeftTank2
				nop
				j Main
				nop


		Right2:
			jal Erase2
			nop
			beq $a3, 0x6c, AddRight2
			jal RightTank2
			nop
			j Main
			nop
			AddRight2:
				jal Verifica2
				nop
				beq $s4, 1, RightContinue2
				nop
				j nextRight2
				nop
			      RightContinue2: jal RightTank2
					    nop
					    j Main
					    nop
				nextRight2:	    
				add $s2, $s2, 0x4 # uma coluna à direita
				jal RightTank2
				nop
				j Main
				nop

		BangBang2:
			beq $s1, 1, isRight2
			nop
			beq $s1, 2, isLeft2
			nop
			beq $s1, 3, isUp2
			nop
			beq $s1, 4, isDown2
			nop
			
			isRight2: jal ShootRight2
				 nop
				 j endBang2
				 nop
		       isLeft2: jal ShootLeft2
				 nop
				 j endBang2
				 nop
		       isUp2: jal ShootUp2
				 nop
				 j endBang2
				 nop
		       isDown2: jal ShootDown2
				 nop
				 j endBang2
				 nop
			endBang2: #li $s1, 0
			          j Main
			          nop
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################

RightTank2:	
	move $a0, $s2 		# ponteiro para as rodas 0x0
	move $a1, $s2
	addi $a1, $a1, 0x800	# ponteiro para as rodas 0x800
	li $t2, 0		# zera contador antes de entrar no loop
	RightTankWheels2: 
		beq $t2, 0x5, RightTankMiddle2
		nop
		li $t1, 0xFFFF00
		sw $t1, 0($a0)	# printa 'roda' 0x0
		sw $t1, 0($a1)	# printa 'roda' 0x800
		addi $a0, $a0, 0x4 # incrementa pra proxima posição (0x4, 0x8, 0xC, 0x10)
		addi $a1, $a1, 0x4 # (0x804, 0x808, 0x80C, 0x810)
		addi $t2, $t2, 1   # incrementa contador	
	j RightTankWheels2
	nop
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x204, $a1 na posição 0x208 e $a2 na posição 0x20C ######
##############################################################################################################
	RightTankMiddle2:
		move $a0, $s2	 	
		addi $a0, $a0, 0x204	# ponteiro
		move $a1, $s2
		addi $a1, $a1, 0x208	# ponteiro
		move $a2, $s2
		addi $a2, $a2, 0x20C	# ponteiro
		li $t2, 0		# zera contador antes de entrar no loop
		RightTankMiddle12:
			beq $t2, 0x3, RightTankGun2
			nop
			li $t1, 0xFFFF00
			sw $t1, 0($a0)	# printa o 'meio'
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do 'meio' (0x204, 0x404, 0x604, etc)
			addi $a1, $a1, 0x200	# (0x208, 0x408, 0x608, etc)
			addi $a2, $a2, 0x200	# (0x20C, 0x40C, 0x60C, etc)
			addi $t2, $t2, 1	# contador
		j RightTankMiddle12
		nop

	RightTankGun2:
			move $a0, $s2	 	
			addi $a0, $a0, 0x410 # ponteiro
			li $t2, 0	     # zera contador
			RightTankGun12:
				beq $t2, 0x3, NowTankIsRight2
				nop
				li $t1, 0xFFFF00
				sw $t1, 0($a0)
				addi $a0, $a0, 0x4 # incrementa pra próxima posição (0x410, 0x414, 0x418)
				addi $t2, $t2, 1   # contador
				move $s3, $a0 # flag ponta do cano
				j RightTankGun12
				nop
		NowTankIsRight2:
		nop
		li $a0, 0
		li $a1, 0
		li $a2, 0	# zera os registradores usados (só pra garantir msm risos)
		li $a3, 0x6c	# flag q sinaliza pra qual lado o tanque virou
		li $s1, 1  #flag direçao tiro
		jr $ra
		
#################################################################################################################################

LeftTank2:
############################################################################################
####### pra criar as rodas do tanque, $a0 as da posição 0x8 e $a1 as da posição 0x808 ######
############################################################################################	
	move $a0, $s2 		
	addi $a0, $a0, 0x8	# ponteiro para as rodas 0x8
	move $a1, $s2
	addi $a1, $a1, 0x808	# ponteiro para as rodas 0x808
	li $t2, 0		# zera contador
	LeftTankWheels2: 
		beq $t2, 0x5, LeftTankMiddle2
		nop
		li $t1, 0xFFFF00
		sw $t1, 0($a0)		# printa roda 0x8
		sw $t1, 0($a1)		# printa roda 0x808 
		addi $a0, $a0, 0x4	# incrementa pra proxima posição (0xC, 0x10, 0x14, 0x18)
		addi $a1, $a1, 0x4	# (0x808, 0x80C, 0x810, 0x814)
		addi $t2, $t2, 1	# incrementa contador
	j LeftTankWheels2
	nop
	LeftTankMiddle2:
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x20C, $a1 na posição 0x210 e $a2 na posição 0x214 ######
##############################################################################################################
		move $a0, $s2	 	
		addi $a0, $a0, 0x20C	# ponteiro
		move $a1, $s2	 	
		addi $a1, $a1, 0x210	# ponteiro
		move $a2, $s2	 	
		addi $a2, $a2, 0x214	# ponteiro
		li $t2, 0		# zera o contador
		LeftTankMiddle12:
			beq $t2, 0x3, LeftTankGun2
			nop
			li $t1, 0xFFFF00
			sw $t1, 0($a0)	# printa o meio
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do meio (0x20C, 0x40C, 0x60C)
			addi $a1, $a1, 0x200	# (0x210, 0x410, 0x6a0)
			addi $a2, $a2, 0x200	# (0x214, 0x414, 0x6a4)
			addi $t2, $t2, 1
		j LeftTankMiddle12
		nop
		LeftTankGun2:
############################################################
####### cria o 'cano' do tanque, $a0 na posição 0x400 ######
############################################################
			move $a0, $s2	 	# ponteiro
			addi $a0, $a0, 0x400
			move $s3, $a0 # flag ponta do cano
			li $t2, 0
			LeftTankGun12:
				beq $t2, 0x3, NowTankIsLeft2
				nop
				li $t1, 0xFFFF00
				sw $t1, 0($a0)
				addi $a0, $a0, 0x4
				addi $t2, $t2, 1
				#move $s3, $a0 # flag ponta do cano
				j LeftTankGun12
				nop
		NowTankIsLeft2:
		nop
		li $a0, 0
		li $a1, 0
		li $a2, 0	# zera os registradores usados
		li $a3, 0x6a	# sinaliza pra qual lado o tanque virou
		li $s1, 2  #flag direçao tiro
		jr $ra
		
###################################################################################################################################

UpTank2:	
############################################################################################
####### pra criar as rodas do tanque, $a0 as da posição 0x0 e $a1 as da posição 0x10 #######
############################################################################################
	move $a0, $s2 		# ponteiro para as rodas 0x0
	addi $a0, $a0, 0x400	# soma 400 pq TankUp precisa pular duas linhas (por causa do cano)
	move $a1, $s2 		
	addi $a1, $a1, 0x410	# ponteiro para as rodas 0x10
	li $t2, 0
	UpTankWheels2: 
		beq $t2, 0x5, UpTankMiddle2
		nop
		li $t1, 0xFFFF00
		sw $t1, 0($a0)		# printa roda
		sw $t1, 0($a1)
		addi $a0, $a0, 0x200	# incrementa pra proxima linha (0x400, 0x600, 0x800, 0xA00)
		addi $a1, $a1, 0x200	# (0x410, 0x6a0, 0x810, 0xA10)
		addi $t2, $t2, 1	# incrementa ponteiro
	j UpTankWheels2
	nop
	UpTankMiddle2:
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x604, $a1 na posição 0x608 e $a2 na posição 0x60C ######
##############################################################################################################
		move $a0, $s2	 	# ponteiro
		addi $a0, $a0, 0x604
		move $a1, $s2	 	# ponteiro
		addi $a1, $a1, 0x608
		move $a2, $s2	 	# ponteiro
		addi $a2, $a2, 0x60C
		li $t2, 0		# zera contador
		UpTankMiddle12:
			beq $t2, 0x3, UpTankGun2
			nop
			li $t1, 0xFFFF00
			sw $t1, 0($a0)	# printa o meio
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima posição (0x604, 0x804, 0xA04)
			addi $a1, $a1, 0x200	# (0x6a0, 0x810, 0xA10)
			addi $a2, $a2, 0x200	# (0x6a4, 0x814, 0xA14)
			addi $t2, $t2, 1
		j UpTankMiddle12
		nop
		UpTankGun2:
##########################################################
####### cria o 'cano' do tanque, $a0 na posição 0x8 ######
##########################################################
			move $a0, $s2	 	# ponteiro
			addi $a0, $a0, 0x8
			move $s3, $a0 # flag ponta do cano	
			li $t2, 0		# zera contador
			uptankgun12:
				beq $t2, 0x3, NowTankIsUp2
				nop
				li $t1, 0xFFFF00
				sw $t1, 0($a0)
				addi $a0, $a0, 0x200	# incrementa pra próxima posição (0x208, 0x408, 0x608)
				addi $t2, $t2, 1
				#move $s3, $a0 # flag ponta do cano
				j uptankgun12
				nop
		NowTankIsUp2:
		nop
		li $a0, 0
		li $a1, 0
		li $a2, 0	# zera os registradores usados
		li $a3, 0x69	# sinaliza pra qual lado o tanque virou
		li $s1, 3  #flag direçao tiro
		jr $ra
		
####################################################################################################################################

DownTank2:	
###########################################################################################
####### pra criar as rodas do tanque, $a0 as da posição 0x0 e $a1 as da posição 0x10 ######
###########################################################################################
	move $a0, $s2 		# ponteiro pras rodas 0x0
	move $a1, $s2 		
	addi $a1, $a1, 0x10	# ponteiro pras rodas 0x10
	li $t2, 0		# zera contador
	DownTankWheels2: 
		beq $t2, 0x5, DownTankMiddle2
		nop
		li $t1, 0xFFFF00
		sw $t1, 0($a0)
		sw $t1, 0($a1)
		addi $a0, $a0, 0x200	# incrementa pra proxima linha (0x0, 0x200, 0x400, 0x600, 0x800)
		addi $a1, $a1, 0x200	# (0x10, 0x210, 0x410, 0x6a0, 0x810)
		addi $t2, $t2, 1
	j DownTankWheels2
	nop
	DownTankMiddle2:
##############################################################################################################
####### pra criar o 'meio' do tanque, $a0 na posição 0x204, $a1 na posição 0x208 e $a2 na posição 0x20C ######
##############################################################################################################
		move $a0, $s2	 	
		addi $a0, $a0, 0x204	# ponteiro
		move $a1, $s2
		addi $a1, $a1, 0x208	# ponteiro
		move $a2, $s2
		addi $a2, $a2, 0x20C	# ponteiro
		li $t2, 0		# zera contador antes de entrar no loop
		DownTankMiddle12:
			beq $t2, 0x3, DownTankGun2
			nop
			li $t1, 0xFFFF00
			sw $t1, 0($a0)	# printa o 'meio'
			sw $t1, 0($a1)
			sw $t1, 0($a2)
			addi $a0, $a0, 0x200	# incrementa pra próxima linha do 'meio' (0x204, 0x404, 0x604, etc)
			addi $a1, $a1, 0x200	# (0x208, 0x408, 0x608, etc)
			addi $a2, $a2, 0x200	# (0x20C, 0x40C, 0x60C, etc)
			addi $t2, $t2, 1	# contador
		j DownTankMiddle12
		nop
		DownTankGun2:
##########################################################
####### cria o 'cano' do tanque, $a0 na posição 0x808 ####
##########################################################
			move $a0, $s2	 	# ponteiro
			addi $a0, $a0, 0x808
			li $t2, 0		# zera contador
			DownTankGun12:
				beq $t2, 0x3, NowTankIsDown2
				nop
				li $t1, 0xFFFF00
				sw $t1, 0($a0)
				addi $a0, $a0, 0x200	# incrementa pra próxima posição (0x808, 0xA08, 0xC08)
				addi $t2, $t2, 1	# incrementa contador
				move $s3, $a0 # flag ponta do cano
				j DownTankGun12
				nop
		NowTankIsDown2:
		nop
		li $a0, 0
		li $a1, 0
		li $a2, 0	# zera os registradores usados
		li $a3, 0x6b	# sinaliza pra qual lado o tanque virou
		li $s1, 4  #flag direçao tiro
		jr $ra

###################################################################################################################################

Erase2:
	move $a0, $s2	 	# ponteiro
	li $t2, 0		# zera contador de linhas
	j EraseY2		# pula pro EraseY
	NextX2:
		addi $t2, $t2, 1 # incrementa pra próx linha~
		addi $a0, $a0, 0x1E8 # 0x200 - 0x18 = 0x1E8 (0x200 de cada linha - 0x18 que é onde o $a0 estava por causa do EraseX)
	EraseY2:
		li $t3, 0	# zera contador de colunas
		beq $t2, 0x8, Done2 # número de linhas
		nop
		EraseX2:
			#lw $t1, EraseColor	
			li $t1, 0x000000
			sw $t1, 0($a0)
			beq $t3, 0x18, NextX2 # quando $t3 = 0x18 acabou a linha, pula pra NextX
			nop
			addi $t3, $t3, 0x4   # incrementa $t3
			addi $a0, $a0, 0x4   # incrementa $a0  pra proxima coluna
			j EraseX2
			nop
	Done2:
		li $a0, 0
		li $t1, 0
		li $t2, 0
		li $t3, 0	# zera registradores usados
		nop
		jr $ra
		nop
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
#####################################################################################################################################
#######				DETECTOR DE COLISAO
#################################################################################################################################

Verifica2:   li $t1, 0
	    li $t2, 0
   	    li $t3, 0
	    li $t4, 0
	    li $t5, 0
	    li $t6, 0
	    li $t7, 0
   	    li $t8, 0
	    li $t9, 0
	 
	    beq $s0, 0x69, VerUp2    
	     nop
	     beq $s0, 0x6b, VerDown2  
		nop
		beq $s0, 0x6a, VerLeft2   
		  nop
		  beq $s0, 0x6c, VerRight2  
		  nop
		  j Fim2
		  nop
		  
	 VerUp2: subi $s3, $s3, 512
	 	subi $t1, $s3, 4 # LADO ESQUERDO CANO
	 	addi $t2, $s3, 4 # LADO DIREITO CANO 
	 	subi $t3, $s3, 8 
	 	addi $t4, $s3, 8  
	
	 	lw $t5, 0($s3)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag2
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag2
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag2
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag2
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag2
	 	   	  nop
	       j Fim2
	       nop
	       
       VerDown2: addi $s3, $s3, 512
	 	subi $t1, $s3, 4 # LADO ESQUERDO CANO
	 	addi $t2, $s3, 4 # LADO DIREITO CANO 
	 	subi $t3, $s3, 8 
	 	addi $t4, $s3, 8  
	
	 	lw $t5, 0($s3)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag2
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag2
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag2
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag2
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag2
	 	   	  nop
	       j Fim2
	       nop
	  
      VerRight2: #addi $s3, $s3, 4
	 	subi $t1, $s3, 512 # LADO ESQUERDO CANO
	 	addi $t2, $s3, 512 # LADO DIREITO CANO 
	 	subi $t3, $s3, 1024 
	 	addi $t4, $s3, 1024  
	
	 	lw $t5, 0($s3)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag2
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag2
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag2
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag2
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag2
	 	   	  nop
	       j Fim2
	       nop
	       
       VerLeft2: subi $s3, $s3, 4
	 	subi $t1, $s3, 512 # LADO ESQUERDO CANO
	 	addi $t2, $s3, 512 # LADO DIREITO CANO 
	 	subi $t3, $s3, 1024 
	 	addi $t4, $s3, 1024  
	
	 	lw $t5, 0($s3)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag2
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag2
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag2
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag2
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag2
	 	   	  nop
	       j Fim2
	       nop
	           
	   Fim2:    jr $ra
	           nop
	  SetFlag2: li $s4, 1
	  	   jr $ra
	           nop
	           ##################################################
	           ##################################################
	           			#TANQUE 2 TIRO
	           #################################################
	 
ShootRight2: 
	li $t2, 0	
	move $t1, $s3
	addi $t1, $t1, 4 # proxima posiçao a partir do cano 
	addi $t2, $t1, 4
	li $t3, 0
	li $t4, 0x000000
	li $t5, 0xFF0000
	
	########## som do tiro ################################################
	move $t8, $a3 # ponteiro do tanque 2 (apenas pra n perder ele)         #
									       #
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 2000                                                           #
	li $a2, 126                                                            #
	li $a3, 127                                                            #
	syscall								       #				
									       #
	move $a3, $t8 # devolve o valor do ponteiro                            #
	########################################################################
	
	Wncr2: lw $t6, 0($t2) 
	     beq $t6, 0xc0c0c0, EndShootRight2
	     nop
	     beq $t6, 0x0000FF, Tank2Hit	# acertou tiro no tank 1
	     nop
	     sw $t5, 0($t1)
	     move $t9, $t1
	     addi $t1, $t1, 4
	     addi $t2, $t2, 4
	     
	     BulletRight2: beq $t3, 999, BackShootRight2
	     	     nop
	     	     addi $t3, $t3, 1
	     	     
	     	     j BulletRight2
	     	     nop
	     BackShootRight2: li $t3, 0
	     		sw $t4, 0($t9)
	     		j Wncr2
	     		nop
	     		
	EndShootRight2: jr $ra	
		  nop
	     	

ShootLeft2: 
	li $t2, 0
	move $t1, $s3
	subi $t1, $t1, 4 # proxima posiçao a partir do cano 
	subi $t2, $t1, 4
	li $t3, 0
	li $t4, 0x000000
	li $t5, 0xFF0000
	
	########## som do tiro ################################################
	move $t8, $a3 # ponteiro do tanque 2 (apenas pra n perder ele)         #
									       #
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 2000                                                           #
	li $a2, 126                                                            #
	li $a3, 127                                                            #
	syscall								       #				
									       #
	move $a3, $t8 # devolve o valor do ponteiro                            #
	########################################################################
	
	Wncl2: lw $t6, 0($t2) 
	     beq $t6, 0xc0c0c0, EndShootLeft2
	     nop
	     beq $t6, 0x0000FF, Tank2Hit	# acertou tiro no tank 1
	     nop
	     sw $t5, 0($t1)
	     move $t9, $t1
	     subi $t1, $t1, 4
	     subi $t2, $t2, 4
	     
	     BulletLeft2: beq $t3, 999, BackShootLeft2
	     	     nop
	     	     addi $t3, $t3, 1
	     	     
	     	     j BulletLeft2
	     	     nop
	     BackShootLeft2: li $t3, 0
	     		sw $t4, 0($t9)
	     		j Wncl2
	     		nop
	     		
	EndShootLeft2: jr $ra
		      nop
	
	
ShootUp2: move $t1, $s3
	li $t2, 0
	subi $t1, $t1, 512 # proxima posiçao a partir do cano 
	subi $t2, $t1, 512
	li $t3, 0
	li $t4, 0x000000
	li $t5, 0xFF0000
	
	########## som do tiro ################################################
	move $t8, $a3 # ponteiro do tanque 2 (apenas pra n perder ele)         #
									       #
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 2000                                                           #
	li $a2, 126                                                            #
	li $a3, 127                                                            #
	syscall								       #				
									       #
	move $a3, $t8 # devolve o valor do ponteiro                            #
	########################################################################
	
	Wncu2: lw $t6, 0($t2) 
	     beq $t6, 0xc0c0c0, EndShootUp2
	     nop
	     beq $t6, 0x0000FF, Tank2Hit	# acertou tiro no tank 1
	     nop
	     sw $t5, 0($t1)
	     move $t9, $t1
	     subi $t1, $t1, 512
	     subi $t2, $t2, 512
	     
	     BulletUp2: beq $t3, 999, BackShootUp2
	     	     nop
	     	     addi $t3, $t3, 1
	     	     
	     	     j BulletUp2
	     	     nop
	     BackShootUp2: li $t3, 0
	     		sw $t4, 0($t9)
	     		j Wncu2
	     		nop
	     		
	EndShootUp2: jr $ra
		      nop
	
	
ShootDown2: 
	li $t2, 0	
	move $t1, $s3
	addi $t1, $t1, 512 # proxima posiçao a partir do cano 
	addi $t2, $t1, 512
	li $t3, 0
	li $t4, 0x000000
	li $t5, 0xFF0000
	
	########## som do tiro ################################################
	move $t8, $a3 # ponteiro do tanque 2 (apenas pra n perder ele)         #
									       #
	li $v0, 31						               #
	li $a0, 66 # dont care                                                 #
	li $a1, 2000                                                           #
	li $a2, 126                                                            #
	li $a3, 127                                                            #
	syscall								       #				
									       #
	move $a3, $t8 # devolve o valor do ponteiro                            #
	########################################################################
	
	Wncd2: lw $t6, 0($t2) 
	     beq $t6, 0xc0c0c0, EndShootDown2
	     nop
	     beq $t6, 0x0000FF, Tank2Hit	# acertou tiro no tank 1
	     nop
	     sw $t5, 0($t1)
	     move $t9, $t1
	     addi $t1, $t1, 512
	     addi $t2, $t2, 512
	     
	     BulletDown2: beq $t3, 999, BackShootDown2
	     	     nop
	     	     addi $t3, $t3, 1
	     	     
	     	     j BulletDown2
	     	     nop
	     BackShootDown2: li $t3, 0
	     		sw $t4, 0($t9)
	     		j Wncd2
	     		nop
	     		
	EndShootDown2: jr $ra
		      nop	
	
	Tank2Hit:
		sw $ra, ($sp)
		jal ExplosionTank2
		nop
		li $gp, 0
		lui $gp, 0x1000
		addi $gp, $gp, 0x8000
		jal ScoreII
		nop
		jal Begin
		nop
		lw $ra, ($sp)
		jr $ra
		nop
		
		

ExplosionTank1:
	move $t0, $ra
	li $v1, 0
	LoopExplosionTank1:
		beq $v1, 200, EndLoopExplosionTank1
		nop
		jal UpTank2
		nop
		jal LeftTank2
		nop
		jal DownTank2
		nop
		jal RightTank2
		nop
		jal UpTank2
		nop
		jal Erase2
		nop
		addi $v1, $v1, 1
		j LoopExplosionTank1
		nop
	EndLoopExplosionTank1:
	move $ra, $t0
	jr $ra
	nop
	
ExplosionTank2:
	move $t0, $ra
	li $s1, 0
	LoopExplosionTank2:
		beq $s1, 200, EndLoopExplosionTank2
		nop
		jal UpTank
		nop
		jal LeftTank
		nop
		jal DownTank
		nop
		jal RightTank
		nop
		jal UpTank
		nop
		jal Erase
		nop
		addi $s1, $s1, 1
		j LoopExplosionTank2
		nop
	EndLoopExplosionTank2:
	move $ra, $t0
	jr $ra
	nop
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################

GameOpening:
	li $t0, 0
	lui $t0, 0x1000
	addi $t0, $t0, 0x8000
	addi $t0, $t0, 0x98
	addi $t0, $t0, 0x2028
	li $a0, 0xC0C0C0
	WriteTank:
	sw $a0, 0x0($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x4($t0)
	sw $a0, 0xC($t0)
	sw $a0, 0x10($t0)
	sw $a0 0x208($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x808($t0)
	sw $a0, 0xA08($t0) 
	sw $a0, 0xC08($t0)
	sw $a0, 0xE08($t0) # T
	addi $t0, $t0, 0x20
	sw $a0, 0x4($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x200($t0)
	sw $a0, 0x20C($t0)
	sw $a0 0x400($t0)
	sw $a0, 0x40C($t0)
	sw $a0, 0x60C($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x80C($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA0C($t0)
	sw $a0, 0xA00($t0) 
	sw $a0, 0xC00($t0) 
	sw $a0, 0xE00($t0) 
	sw $a0, 0xC0C($t0) 
	sw $a0, 0xE0C($t0) # A
	addi $t0, $t0, 0x20
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0xC00($t0)
	sw $a0, 0xE00($t0)
	sw $a0, 0xC($t0)
	sw $a0 0x20C($t0)
	sw $a0, 0x40C($t0)
	sw $a0, 0x60C($t0)
	sw $a0, 0x80C($t0)
	sw $a0, 0xA0C($t0)
	sw $a0, 0x404($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0xE0C($t0)
	sw $a0, 0xC0C($t0) # N
	addi $t0, $t0, 0x20
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0xC00($t0)
	sw $a0, 0xE00($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x804($t0)
	sw $a0, 0xA08($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x208($t0)
	sw $a0, 0xC08($t0)
	sw $a0, 0xE08($t0)
	sw $a0, 0x8($t0) # K
	EnterToPlay:
	move $t0, $gp
	addi $t0, $t0, 0x8030
	addi $t0, $t0, 0x5600
	addi $t0, $t0, 0x58
	li $a0, 0xC0C0C0
	li $t1, 0
	ETP1:
	## singleplayer ##
		sw $a0, 4($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x204($t0)
		sw $a0, 0x404($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0xA00($t0) # 1
		addi $t0, $t0, 0x20
		sw $a0, 0x0($t0)
		sw $a0, 0x4($t0)
		sw $a0 0x8($t0)
		sw $a0, 0x200($t0)
		sw $a0 0x400($t0)
		sw $a0 0x600($t0)
		sw $a0 0x604($t0)
		sw $a0 0x608($t0)
		sw $a0 0x808($t0)
		sw $a0 0xA08($t0)
		sw $a0 0xA04($t0)
		sw $a0 0xA00($t0)  # S
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0, 0x200($t0)
		sw $a0 0x400($t0)
		sw $a0 0x600($t0)
		sw $a0 0x800($t0)
		sw $a0 0xA00($t0) # I
		addi $t0, $t0, 0x8 # ESPAÇO
		sw $a0, 0x0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x8($t0)
		sw $a0 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x808($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0x604($t0) # N
		addi $t0, $t0, 0x10 
		sw $a0, 0x8($t0)
		sw $a0 0x4($t0)
		sw $a0, 0x0($t0)
		sw $a0, 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0 0xA00($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0x808($t0)
		sw $a0, 0x608($t0)   # G
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0xA04($t0)
		sw $a0 0xA08($t0) # L
		addi $t0, $t0, 0x10
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0 0x8($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)   # E
		addi $t0, $t0, 0x10
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)  # P
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0xA04($t0)
		sw $a0 0xA08($t0) # L
		addi $t0, $t0, 0x10
		sw $a0, 0x4($t0)
		sw $a0, 0x200($t0)
		sw $a0, 0x208($t0)
		sw $a0 0x400($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x808($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0xA00($t0) # A
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x204($t0)
		sw $a0 0x404($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA04($t0) # Y
		addi $t0, $t0, 0x10 
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0 0x8($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)   # E
		addi $t0, $t0, 0x10
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA08($t0)   # R
	## multiplayer ##
	move $t0, $gp
	addi $t0, $t0, 0x8030
	addi $t0, $t0, 0x6600
	addi $t0, $t0, 0x58
	li $a0, 0xC0C0C0
	li $t1, 0
	sw $a0, 0xA08($t0)
	sw $a0, 0xA04($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x208($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x4($t0)
	sw $a0, 0x0($t0) # 2
	addi $t0, $t0, 0x20
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0x8($t0)
	sw $a0 0x208($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x808($t0)
	sw $a0, 0xA08($t0)
	sw $a0, 0x404($t0) # M
	addi $t0, $t0, 0x10
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0xA04($t0)
	sw $a0, 0x8($t0)
	sw $a0 0x208($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x808($t0)
	sw $a0, 0xA08($t0) # U
	addi $t0, $t0, 0x10
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0xA04($t0)
	sw $a0 0xA08($t0) # L
	addi $t0, $t0, 0x10
	sw $a0, 0x0($t0)
	sw $a0 0x4($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x204($t0)
	sw $a0, 0x404($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x804($t0)
	sw $a0 0xA04($t0) # T
	addi $t0, $t0, 0x10
	sw $a0, 0x0($t0)
	sw $a0, 0x200($t0)
	sw $a0 0x400($t0)
	sw $a0 0x600($t0)
	sw $a0 0x800($t0)
	sw $a0 0xA00($t0) # I
	addi $t0, $t0, 0x8
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)  # P
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0xA04($t0)
		sw $a0 0xA08($t0) # L
		addi $t0, $t0, 0x10
		sw $a0, 0x4($t0)
		sw $a0, 0x200($t0)
		sw $a0, 0x208($t0)
		sw $a0 0x400($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x808($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0xA00($t0) # A
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x204($t0)
		sw $a0 0x404($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA04($t0) # Y
		addi $t0, $t0, 0x10 
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0 0x8($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)   # E
		addi $t0, $t0, 0x10
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA08($t0)   # R
		
	DrawTank:
	move $t0, $gp
	addi $t0, $t0, 0x8CC4
	li $a0, 0x146314  # verdinho mais escuro
	sw $a0, 0x0($t0)
	sw $a0, 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, -0x1FC($t0)
	sw $a0, -0x3FC($t0)
	sw $a0, -0x3FC($t0)
	sw $a0, -0x5F8($t0)
	sw $a0, -0x5F4($t0)
	sw $a0, -0x5F0($t0)
	sw $a0, -0x5EC($t0)
	sw $a0, -0x5E8($t0)
	sw $a0, -0x5E4($t0)
	sw $a0, -0x7E4($t0)
	sw $a0, -0x9E4($t0)
	sw $a0, -0xBE4($t0)
	sw $a0, -0xDE0($t0)
	sw $a0, -0xFDC($t0)
	sw $a0, -0xFD8($t0)
	sw $a0, -0xFD4($t0)
	sw $a0, -0xFD0($t0)
	sw $a0, -0xFCC($t0) # desce p comecar o cano
	sw $a0, -0xDC8($t0)
	sw $a0, -0xDC4($t0)
	sw $a0, -0xDC0($t0)
	sw $a0, -0xDBC($t0)
	sw $a0, -0xDB8($t0)
	sw $a0, -0xDB4($t0)
	sw $a0, -0xDB0($t0)
	sw $a0, -0xDAC($t0)	
	sw $a0, -0xDA8($t0)
	sw $a0, -0xDA4($t0)
	sw $a0, -0xBA4($t0)
	sw $a0, -0xFA4($t0)
	sw $a0, -0xDA0($t0)
	sw $a0, -0xBA0($t0)
	sw $a0, -0xFA0($t0)
	sw $a0, -0xF9C($t0)
	sw $a0, -0xD9C($t0)
	sw $a0, -0xB9C($t0)
	sw $a0, -0xBC4($t0)
	sw $a0, -0x9C4($t0)
	sw $a0, -0x7C4($t0)
	sw $a0, -0x5C4($t0) # fim da cabecinha do tanque
	sw $a0, -0x5c0($t0)
	sw $a0, -0x5BC($t0)
	sw $a0, -0x5B8($t0)
	sw $a0, -0x5B4($t0)
	sw $a0, -0x5B0($t0)
	sw $a0, -0x5AC($t0)
	sw $a0, -0x5A8($t0)
	sw $a0, -0x5A4($t0)
	sw $a0, -0x3A0($t0)
	sw $a0, -0x1A0($t0)
	sw $a0, 0x64($t0)
	sw $a0, 0x264($t0)
	sw $a0, 0x464($t0)
	sw $a0, 0x664($t0)
	li $a0, 0x425a42  # preto qse cinza
	sw $a0, 0x660($t0)
	sw $a0, 0x65C($t0)
	sw $a0, 0x658($t0)
	sw $a0, 0x654($t0)
	sw $a0, 0x650($t0)
	sw $a0, 0x64C($t0)
	sw $a0, 0x648($t0)
	sw $a0, 0x64C($t0)
	sw $a0, 0x648($t0)
	sw $a0, 0x644($t0)
	sw $a0, 0x640($t0)
	sw $a0, 0x63C($t0)
	sw $a0, 0x638($t0)
	sw $a0, 0x634($t0)
	sw $a0, 0x630($t0)
	sw $a0, 0x62c($t0)
	sw $a0, 0x628($t0)
	sw $a0, 0x624($t0)
	sw $a0, 0x620($t0)
	sw $a0, 0x61c($t0)
	sw $a0, 0x618($t0)
	sw $a0, 0x614($t0)
	sw $a0, 0x610($t0)
	sw $a0, 0x60c($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x7FC($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0x804($t0)
	sw $a0, 0x808($t0)
	sw $a0, 0x80C($t0)
	sw $a0, 0x810($t0)
	sw $a0, 0x814($t0)
	sw $a0, 0x818($t0)
	sw $a0, 0x81c($t0)
	sw $a0, 0x820($t0)
	sw $a0, 0x824($t0)
	sw $a0, 0x828($t0)
	sw $a0, 0x82C($t0)
	sw $a0, 0x830($t0)
	sw $a0, 0x834($t0)
	sw $a0, 0x838($t0)
	sw $a0, 0x83C($t0)
	sw $a0, 0x840($t0)
	sw $a0, 0x844($t0)
	sw $a0, 0x848($t0)
	sw $a0, 0x84C($t0)
	sw $a0, 0x850($t0)
	sw $a0, 0x854($t0)
	sw $a0, 0x858($t0)
	sw $a0, 0x85C($t0)
	sw $a0, 0x860($t0)
	sw $a0, 0x864($t0)
	sw $a0, 0x868($t0)
	sw $a0, 0xA6C($t0)
	sw $a0, 0xA68($t0)
	sw $a0, 0x9F8($t0)
	sw $a0, 0x9FC($t0)
	sw $a0, 0xBFC($t0)
	sw $a0, 0xDFC($t0)
	sw $a0, 0x1000($t0)
	sw $a0, 0x1004($t0)
	sw $a0, 0x1008($t0)
	sw $a0, 0x100C($t0)
	sw $a0, 0x1010($t0)
	sw $a0, 0x1014($t0)
	sw $a0, 0x1018($t0)
	sw $a0, 0x101C($t0)
	sw $a0, 0x1020($t0)
	sw $a0, 0x1024($t0)
	sw $a0, 0x1028($t0)
	sw $a0, 0x102c($t0)
	sw $a0, 0x1030($t0)
	sw $a0, 0x1034($t0)
	sw $a0, 0x1038($t0)
	sw $a0, 0x103c($t0)
	sw $a0, 0x1040($t0)
	sw $a0, 0x1044($t0)
	sw $a0, 0x1048($t0)
	sw $a0, 0x104c($t0)
	sw $a0, 0x1050($t0)
	sw $a0, 0x1054($t0)
	sw $a0, 0x1058($t0)
	sw $a0, 0x105c($t0)
	sw $a0, 0x1060($t0)
	sw $a0, 0x1064($t0)
	sw $a0, 0xE68($t0)
	sw $a0, 0xC68($t0)
	sw $a0, 0xA68($t0) # fim das rodas no canto direito
	li $a0, 0x146314  # verdinho mais escuro
	sw $a0, -0x5C8($t0)
	sw $a0, -0x5CC($t0)
	sw $a0, -0x5D0($t0)
	sw $a0, -0x5D4($t0)
	sw $a0, -0x5D8($t0)
	sw $a0, -0x5DC($t0)
	sw $a0, -0x5E0($t0)
	li $a0, 0x20a120 # verdinho mais claro p pintar
	sw $a0, -0x7E0($t0)
	sw $a0, -0x9E0($t0)
	sw $a0, -0xBE0($t0)
	sw $a0, -0xDDC($t0)
	sw $a0, -0xDD8($t0)
	sw $a0, -0xDD4($t0)
	sw $a0, -0xDD0($t0)
	sw $a0, -0xDCC($t0)
	sw $a0, -0xBC8($t0)
	sw $a0, -0xBCC($t0)
	sw $a0, -0xBD0($t0)
	sw $a0, -0xBD4($t0)
	sw $a0, -0xBD8($t0)
	sw $a0, -0xBDC($t0)
	sw $a0, -0x9DC($t0)
	sw $a0, -0x7DC($t0)
	sw $a0, -0x7D8($t0)
	sw $a0, -0x9D8($t0)
	sw $a0, -0x7D4($t0)
	sw $a0, -0x9D4($t0)
	sw $a0, -0x7D0($t0)
	sw $a0, -0x9D0($t0)
	sw $a0, -0x7CC($t0)
	sw $a0, -0x9CC($t0)
	sw $a0, -0x7C8($t0)
	sw $a0, -0x9C8($t0)
	sw $a0, -0x3A4($t0) # pintando corpo do tanque
	sw $a0, -0x3A8($t0)
	sw $a0, -0x3AC($t0)
	sw $a0, -0x3B0($t0)
	sw $a0, -0x3B4($t0)
	sw $a0, -0x3B8($t0)
	sw $a0, -0x3BC($t0)
	sw $a0, -0x3C0($t0)
	sw $a0, -0x3C4($t0)
	sw $a0, -0x3C8($t0)
	sw $a0, -0x3CC($t0)
	sw $a0, -0x3D0($t0)
	sw $a0, -0x3D4($t0)
	sw $a0, -0x3D8($t0)
	sw $a0, -0x3DC($t0)
	sw $a0, -0x3E0($t0)
	sw $a0, -0x3E4($t0)
	sw $a0, -0x3E8($t0)
	sw $a0, -0x3EC($t0)
	sw $a0, -0x3F0($t0)
	sw $a0, -0x3F4($t0)
	sw $a0, -0x3F8($t0)
	sw $a0, -0x1F8($t0) #pintando corpo do tanque
	sw $a0, -0x1f4($t0)
	sw $a0, -0x1F0($t0)
	sw $a0, -0x1EC($t0)
	sw $a0, -0x1E8($t0)
	sw $a0, -0x1E4($t0)
	sw $a0, -0x1E0($t0)
	sw $a0, -0x1DC($t0)
	sw $a0, -0x1D8($t0)
	sw $a0, -0x1D4($t0)
	sw $a0, -0x1D0($t0)
	sw $a0, -0x1CC($t0)
	sw $a0, -0x1C8($t0)
	sw $a0, -0x1C4($t0)
	sw $a0, -0x1C0($t0)
	sw $a0, -0x1BC($t0)
	sw $a0, -0x1B8($t0)
	sw $a0, -0x1B4($t0)
	sw $a0, -0x1B0($t0)
	sw $a0, -0x1AC($t0)
	sw $a0, -0x1A8($t0)
	sw $a0, -0x1A4($t0)
	sw $a0, 0x60($t0)
	sw $a0, 0x5C($t0)
	sw $a0, 0x58($t0)
	sw $a0, 0x54($t0)
	sw $a0, 0x50($t0)
	sw $a0, 0x4C($t0)
	sw $a0, 0x48($t0)
	sw $a0, 0x44($t0)
	sw $a0, 0x40($t0)
	sw $a0, 0x3C($t0)
	sw $a0, 0x38($t0)
	sw $a0, 0x34($t0)
	sw $a0, 0x30($t0)
	sw $a0, 0x2C($t0)
	sw $a0, 0x28($t0)
	sw $a0, 0x24($t0)
	sw $a0, 0x20($t0)
	sw $a0, 0x1C($t0)
	sw $a0, 0x18($t0)
	sw $a0, 0x14($t0)
	sw $a0, 0x10($t0)
	sw $a0, 0xC($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x4($t0)
	sw $a0, 0x204($t0)
	sw $a0, 0x208($t0)
	sw $a0, 0x20c($t0)
	sw $a0, 0x210($t0)
	sw $a0, 0x214($t0)
	sw $a0, 0x218($t0)
	sw $a0, 0x21c($t0)
	sw $a0, 0x220($t0)
	sw $a0, 0x224($t0)
	sw $a0, 0x228($t0)
	sw $a0, 0x22c($t0)
	sw $a0, 0x230($t0)
	sw $a0, 0x234($t0)
	sw $a0, 0x238($t0)
	sw $a0, 0x23c($t0)
	sw $a0, 0x240($t0)
	sw $a0, 0x244($t0)
	sw $a0, 0x248($t0)
	sw $a0, 0x24c($t0)
	sw $a0, 0x250($t0)
	sw $a0, 0x254($t0)
	sw $a0, 0x258($t0)
	sw $a0, 0x25c($t0)
	sw $a0, 0x260($t0)
	sw $a0, 0x460($t0)
	sw $a0, 0x45c($t0)
	sw $a0, 0x458($t0)
	sw $a0, 0x454($t0)
	sw $a0, 0x450($t0)
	sw $a0, 0x44c($t0)
	sw $a0, 0x448($t0)
	sw $a0, 0x444($t0)
	sw $a0, 0x440($t0)
	sw $a0, 0x43c($t0)
	sw $a0, 0x438($t0)
	sw $a0, 0x434($t0)
	sw $a0, 0x430($t0)
	sw $a0, 0x42c($t0)
	sw $a0, 0x428($t0)
	sw $a0, 0x424($t0)
	sw $a0, 0x420($t0)
	sw $a0, 0x41c($t0)
	sw $a0, 0x418($t0)
	sw $a0, 0x414($t0)
	sw $a0, 0x410($t0)
	sw $a0, 0x40c($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x404($t0)  # termina de pintar barriga na esquerda
	#li $a0, 0x425a42  # preto qse cinza
	li $a0, 0xff0000
	sw $a0, 0xC04($t0) # fazer ~pneus
	sw $a0, 0xC08($t0)
	sw $a0, 0xC0c($t0)
	sw $a0, 0xa08($t0)
	sw $a0, 0xE08($t0)
	sw $a0, 0xC20($t0) # fazer ~pneus
	sw $a0, 0xC24($t0)
	sw $a0, 0xC28($t0)
	sw $a0, 0xa24($t0)
	sw $a0, 0xE24($t0)
	sw $a0, 0xC3c($t0) 
	sw $a0, 0xC40($t0)
	sw $a0, 0xC44($t0)
	sw $a0, 0xa40($t0)
	sw $a0, 0xE40($t0)
	sw $a0, 0xC58($t0) 
	sw $a0, 0xC5c($t0)
	sw $a0, 0xC60($t0)
	sw $a0, 0xa5c($t0)
	sw $a0, 0xE5c($t0)
	li $a0, 0x425a42  # caninho la em cima
	sw $a0, -0x11D4($t0)
	sw $a0, -0x13D4($t0)
	sw $a0, -0x13D0($t0)
	sw $a0, -0x13CC($t0)
	sw $a0, -0x13C8($t0)
	sw $a0, -0x13C4($t0)
	sw $a0, -0x13C0($t0)
	li $a0, 0xc0c0c0 # bandeirinha
	sw $a0, -0x13D8($t0)
	sw $a0, -0x13DC($t0)
	sw $a0, -0x15D8($t0)
	sw $a0, -0x15Dc($t0)
	li $v0, 12
	syscall
	beq $v0, 0x31, SinglePlayer
	nop
	nop
	li $a0, 0
	li $t0, 0
	li $v0, 0
	jr $ra
	nop
#############################################
#############################################
############# LIMPAR TELA ###################
#############################################
ClearGameOpening:
	move $t0, $gp
	addi $t0, $t0, 0x98
	addi $t0, $t0, 0x2028
	li $a0, 0x000000
	sw $a0, 0x0($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x4($t0)
	sw $a0, 0xC($t0)
	sw $a0, 0x10($t0)
	sw $a0 0x208($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x808($t0)
	sw $a0, 0xA08($t0) 
	sw $a0, 0xC08($t0)
	sw $a0, 0xE08($t0) # T
	addi $t0, $t0, 0x20
	sw $a0, 0x4($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x200($t0)
	sw $a0, 0x20C($t0)
	sw $a0 0x400($t0)
	sw $a0, 0x40C($t0)
	sw $a0, 0x60C($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x80C($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA0C($t0)
	sw $a0, 0xA00($t0) 
	sw $a0, 0xC00($t0) 
	sw $a0, 0xE00($t0) 
	sw $a0, 0xC0C($t0) 
	sw $a0, 0xE0C($t0) # A
	addi $t0, $t0, 0x20
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0xC00($t0)
	sw $a0, 0xE00($t0)
	sw $a0, 0xC($t0)
	sw $a0 0x20C($t0)
	sw $a0, 0x40C($t0)
	sw $a0, 0x60C($t0)
	sw $a0, 0x80C($t0)
	sw $a0, 0xA0C($t0)
	sw $a0, 0x404($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0xE0C($t0)
	sw $a0, 0xC0C($t0) # N
	addi $t0, $t0, 0x20
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0xC00($t0)
	sw $a0, 0xE00($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x804($t0)
	sw $a0, 0xA08($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x208($t0)
	sw $a0, 0xC08($t0)
	sw $a0, 0xE08($t0)
	sw $a0, 0x8($t0) # K
	move $t0, $gp
	addi $t0, $t0, 0x8030
	addi $t0, $t0, 0x5600
	addi $t0, $t0, 0x58
	li $a0, 0x000000
	li $t1, 0
	## singleplayer ##
		sw $a0, 4($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x204($t0)
		sw $a0, 0x404($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0xA00($t0) # 1
		addi $t0, $t0, 0x20
		sw $a0, 0x0($t0)
		sw $a0, 0x4($t0)
		sw $a0 0x8($t0)
		sw $a0, 0x200($t0)
		sw $a0 0x400($t0)
		sw $a0 0x600($t0)
		sw $a0 0x604($t0)
		sw $a0 0x608($t0)
		sw $a0 0x808($t0)
		sw $a0 0xA08($t0)
		sw $a0 0xA04($t0)
		sw $a0 0xA00($t0)  # S
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0, 0x200($t0)
		sw $a0 0x400($t0)
		sw $a0 0x600($t0)
		sw $a0 0x800($t0)
		sw $a0 0xA00($t0) # I
		addi $t0, $t0, 0x8 # ESPAÇO
		sw $a0, 0x0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x8($t0)
		sw $a0 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x808($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0x604($t0) # N
		addi $t0, $t0, 0x10 
		sw $a0, 0x8($t0)
		sw $a0 0x4($t0)
		sw $a0, 0x0($t0)
		sw $a0, 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0 0xA00($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0x808($t0)
		sw $a0, 0x608($t0)   # G
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0xA04($t0)
		sw $a0 0xA08($t0) # L
		addi $t0, $t0, 0x10
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0 0x8($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)   # E
		addi $t0, $t0, 0x10
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)  # P
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0xA04($t0)
		sw $a0 0xA08($t0) # L
		addi $t0, $t0, 0x10
		sw $a0, 0x4($t0)
		sw $a0, 0x200($t0)
		sw $a0, 0x208($t0)
		sw $a0 0x400($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x808($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0xA00($t0) # A
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x204($t0)
		sw $a0 0x404($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA04($t0) # Y
		addi $t0, $t0, 0x10 
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0 0x8($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)   # E
		addi $t0, $t0, 0x10
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA08($t0)   # R
	## multiplayer ##
	move $t0, $gp
	addi $t0, $t0, 0x8030
	addi $t0, $t0, 0x6600
	addi $t0, $t0, 0x58
	li $a0, 0x000000
	li $t1, 0
	sw $a0, 0xA08($t0)
	sw $a0, 0xA04($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x208($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x4($t0)
	sw $a0, 0x0($t0) # 2
	addi $t0, $t0, 0x20
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0x8($t0)
	sw $a0 0x208($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x808($t0)
	sw $a0, 0xA08($t0)
	sw $a0, 0x404($t0) # M
	addi $t0, $t0, 0x10
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0xA04($t0)
	sw $a0, 0x8($t0)
	sw $a0 0x208($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x808($t0)
	sw $a0, 0xA08($t0) # U
	addi $t0, $t0, 0x10
	sw $a0, 0x0($t0)
	sw $a0 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0xA00($t0)
	sw $a0, 0xA04($t0)
	sw $a0 0xA08($t0) # L
	addi $t0, $t0, 0x10
	sw $a0, 0x0($t0)
	sw $a0 0x4($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x204($t0)
	sw $a0, 0x404($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x804($t0)
	sw $a0 0xA04($t0) # T
	addi $t0, $t0, 0x10
	sw $a0, 0x0($t0)
	sw $a0, 0x200($t0)
	sw $a0 0x400($t0)
	sw $a0 0x600($t0)
	sw $a0 0x800($t0)
	sw $a0 0xA00($t0) # I
	addi $t0, $t0, 0x8
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)  # P
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0xA04($t0)
		sw $a0 0xA08($t0) # L
		addi $t0, $t0, 0x10
		sw $a0, 0x4($t0)
		sw $a0, 0x200($t0)
		sw $a0, 0x208($t0)
		sw $a0 0x400($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x808($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA08($t0)
		sw $a0, 0xA00($t0) # A
		addi $t0, $t0, 0x10
		sw $a0, 0x0($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x204($t0)
		sw $a0 0x404($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA04($t0) # Y
		addi $t0, $t0, 0x10 
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0 0x8($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0xA04($t0)
		sw $a0, 0xA08($t0)   # E
		addi $t0, $t0, 0x10
		sw $a0, 0($t0)
		sw $a0 0x200($t0)
		sw $a0, 0x400($t0)
		sw $a0, 0x600($t0)
		sw $a0, 0x800($t0)
		sw $a0, 0xA00($t0)
		sw $a0, 0x4($t0)
		sw $a0, 0x8($t0)
		sw $a0, 0x208($t0)
		sw $a0, 0x408($t0)
		sw $a0, 0x608($t0)
		sw $a0, 0x604($t0)
		sw $a0, 0x804($t0)
		sw $a0, 0xA08($t0)   # R
	move $t0, $gp
	addi $t0, $t0, 0x8CC4
	sw $a0, 0x0($t0)
	sw $a0, 0x200($t0)
	sw $a0, 0x400($t0)
	sw $a0, 0x600($t0)
	sw $a0, 0x800($t0)
	sw $a0, -0x1FC($t0)
	sw $a0, -0x3FC($t0)
	sw $a0, -0x3FC($t0)
	sw $a0, -0x5F8($t0)
	sw $a0, -0x5F4($t0)
	sw $a0, -0x5F0($t0)
	sw $a0, -0x5EC($t0)
	sw $a0, -0x5E8($t0)
	sw $a0, -0x5E4($t0)
	sw $a0, -0x7E4($t0)
	sw $a0, -0x9E4($t0)
	sw $a0, -0xBE4($t0)
	sw $a0, -0xDE0($t0)
	sw $a0, -0xFDC($t0)
	sw $a0, -0xFD8($t0)
	sw $a0, -0xFD4($t0)
	sw $a0, -0xFD0($t0)
	sw $a0, -0xFCC($t0) # desce p comecar o cano
	sw $a0, -0xDC8($t0)
	sw $a0, -0xDC4($t0)
	sw $a0, -0xDC0($t0)
	sw $a0, -0xDBC($t0)
	sw $a0, -0xDB8($t0)
	sw $a0, -0xDB4($t0)
	sw $a0, -0xDB0($t0)
	sw $a0, -0xDAC($t0)	
	sw $a0, -0xDA8($t0)
	sw $a0, -0xDA4($t0)
	sw $a0, -0xBA4($t0)
	sw $a0, -0xFA4($t0)
	sw $a0, -0xDA0($t0)
	sw $a0, -0xBA0($t0)
	sw $a0, -0xFA0($t0)
	sw $a0, -0xF9C($t0)
	sw $a0, -0xD9C($t0)
	sw $a0, -0xB9C($t0)
	sw $a0, -0xBC4($t0)
	sw $a0, -0x9C4($t0)
	sw $a0, -0x7C4($t0)
	sw $a0, -0x5C4($t0) # fim da cabecinha do tanque
	sw $a0, -0x5c0($t0)
	sw $a0, -0x5BC($t0)
	sw $a0, -0x5B8($t0)
	sw $a0, -0x5B4($t0)
	sw $a0, -0x5B0($t0)
	sw $a0, -0x5AC($t0)
	sw $a0, -0x5A8($t0)
	sw $a0, -0x5A4($t0)
	sw $a0, -0x3A0($t0)
	sw $a0, -0x1A0($t0)
	sw $a0, 0x64($t0)
	sw $a0, 0x264($t0)
	sw $a0, 0x464($t0)
	sw $a0, 0x664($t0)
	sw $a0, 0x660($t0)
	sw $a0, 0x65C($t0)
	sw $a0, 0x658($t0)
	sw $a0, 0x654($t0)
	sw $a0, 0x650($t0)
	sw $a0, 0x64C($t0)
	sw $a0, 0x648($t0)
	sw $a0, 0x64C($t0)
	sw $a0, 0x648($t0)
	sw $a0, 0x644($t0)
	sw $a0, 0x640($t0)
	sw $a0, 0x63C($t0)
	sw $a0, 0x638($t0)
	sw $a0, 0x634($t0)
	sw $a0, 0x630($t0)
	sw $a0, 0x62c($t0)
	sw $a0, 0x628($t0)
	sw $a0, 0x624($t0)
	sw $a0, 0x620($t0)
	sw $a0, 0x61c($t0)
	sw $a0, 0x618($t0)
	sw $a0, 0x614($t0)
	sw $a0, 0x610($t0)
	sw $a0, 0x60c($t0)
	sw $a0, 0x608($t0)
	sw $a0, 0x604($t0)
	sw $a0, 0x7FC($t0)
	sw $a0, 0x800($t0)
	sw $a0, 0x804($t0)
	sw $a0, 0x808($t0)
	sw $a0, 0x80C($t0)
	sw $a0, 0x810($t0)
	sw $a0, 0x814($t0)
	sw $a0, 0x818($t0)
	sw $a0, 0x81c($t0)
	sw $a0, 0x820($t0)
	sw $a0, 0x824($t0)
	sw $a0, 0x828($t0)
	sw $a0, 0x82C($t0)
	sw $a0, 0x830($t0)
	sw $a0, 0x834($t0)
	sw $a0, 0x838($t0)
	sw $a0, 0x83C($t0)
	sw $a0, 0x840($t0)
	sw $a0, 0x844($t0)
	sw $a0, 0x848($t0)
	sw $a0, 0x84C($t0)
	sw $a0, 0x850($t0)
	sw $a0, 0x854($t0)
	sw $a0, 0x858($t0)
	sw $a0, 0x85C($t0)
	sw $a0, 0x860($t0)
	sw $a0, 0x864($t0)
	sw $a0, 0x868($t0)
	sw $a0, 0xA6C($t0)
	sw $a0, 0xA68($t0)
	sw $a0, 0x9F8($t0)
	sw $a0, 0x9FC($t0)
	sw $a0, 0xBFC($t0)
	sw $a0, 0xDFC($t0)
	sw $a0, 0x1000($t0)
	sw $a0, 0x1004($t0)
	sw $a0, 0x1008($t0)
	sw $a0, 0x100C($t0)
	sw $a0, 0x1010($t0)
	sw $a0, 0x1014($t0)
	sw $a0, 0x1018($t0)
	sw $a0, 0x101C($t0)
	sw $a0, 0x1020($t0)
	sw $a0, 0x1024($t0)
	sw $a0, 0x1028($t0)
	sw $a0, 0x102c($t0)
	sw $a0, 0x1030($t0)
	sw $a0, 0x1034($t0)
	sw $a0, 0x1038($t0)
	sw $a0, 0x103c($t0)
	sw $a0, 0x1040($t0)
	sw $a0, 0x1044($t0)
	sw $a0, 0x1048($t0)
	sw $a0, 0x104c($t0)
	sw $a0, 0x1050($t0)
	sw $a0, 0x1054($t0)
	sw $a0, 0x1058($t0)
	sw $a0, 0x105c($t0)
	sw $a0, 0x1060($t0)
	sw $a0, 0x1064($t0)
	sw $a0, 0xE68($t0)
	sw $a0, 0xC68($t0)
	sw $a0, -0x5C8($t0)
	sw $a0, -0x5CC($t0)
	sw $a0, -0x5D0($t0)
	sw $a0, -0x5D4($t0)
	sw $a0, -0x5D8($t0)
	sw $a0, -0x5DC($t0)
	sw $a0, -0x5E0($t0)
	sw $a0, -0x7E0($t0)
	sw $a0, -0x9E0($t0)
	sw $a0, -0xBE0($t0)
	sw $a0, -0xDDC($t0)
	sw $a0, -0xDD8($t0)
	sw $a0, -0xDD4($t0)
	sw $a0, -0xDD0($t0)
	sw $a0, -0xDCC($t0)
	sw $a0, -0xBC8($t0)
	sw $a0, -0xBCC($t0)
	sw $a0, -0xBD0($t0)
	sw $a0, -0xBD4($t0)
	sw $a0, -0xBD8($t0)
	sw $a0, -0xBDC($t0)
	sw $a0, -0x9DC($t0)
	sw $a0, -0x7DC($t0)
	sw $a0, -0x7D8($t0)
	sw $a0, -0x9D8($t0)
	sw $a0, -0x7D4($t0)
	sw $a0, -0x9D4($t0)
	sw $a0, -0x7D0($t0)
	sw $a0, -0x9D0($t0)
	sw $a0, -0x7CC($t0)
	sw $a0, -0x9CC($t0)
	sw $a0, -0x7C8($t0)
	sw $a0, -0x9C8($t0)
	sw $a0, -0x3A4($t0) # pintando corpo do tanque
	sw $a0, -0x3A8($t0)
	sw $a0, -0x3AC($t0)
	sw $a0, -0x3B0($t0)
	sw $a0, -0x3B4($t0)
	sw $a0, -0x3B8($t0)
	sw $a0, -0x3BC($t0)
	sw $a0, -0x3C0($t0)
	sw $a0, -0x3C4($t0)
	sw $a0, -0x3C8($t0)
	sw $a0, -0x3CC($t0)
	sw $a0, -0x3D0($t0)
	sw $a0, -0x3D4($t0)
	sw $a0, -0x3D8($t0)
	sw $a0, -0x3DC($t0)
	sw $a0, -0x3E0($t0)
	sw $a0, -0x3E4($t0)
	sw $a0, -0x3E8($t0)
	sw $a0, -0x3EC($t0)
	sw $a0, -0x3F0($t0)
	sw $a0, -0x3F4($t0)
	sw $a0, -0x3F8($t0)
	sw $a0, -0x1F8($t0) #pintando corpo do tanque
	sw $a0, -0x1f4($t0)
	sw $a0, -0x1F0($t0)
	sw $a0, -0x1EC($t0)
	sw $a0, -0x1E8($t0)
	sw $a0, -0x1E4($t0)
	sw $a0, -0x1E0($t0)
	sw $a0, -0x1DC($t0)
	sw $a0, -0x1D8($t0)
	sw $a0, -0x1D4($t0)
	sw $a0, -0x1D0($t0)
	sw $a0, -0x1CC($t0)
	sw $a0, -0x1C8($t0)
	sw $a0, -0x1C4($t0)
	sw $a0, -0x1C0($t0)
	sw $a0, -0x1BC($t0)
	sw $a0, -0x1B8($t0)
	sw $a0, -0x1B4($t0)
	sw $a0, -0x1B0($t0)
	sw $a0, -0x1AC($t0)
	sw $a0, -0x1A8($t0)
	sw $a0, -0x1A4($t0)
	sw $a0, 0x60($t0)
	sw $a0, 0x5C($t0)
	sw $a0, 0x58($t0)
	sw $a0, 0x54($t0)
	sw $a0, 0x50($t0)
	sw $a0, 0x4C($t0)
	sw $a0, 0x48($t0)
	sw $a0, 0x44($t0)
	sw $a0, 0x40($t0)
	sw $a0, 0x3C($t0)
	sw $a0, 0x38($t0)
	sw $a0, 0x34($t0)
	sw $a0, 0x30($t0)
	sw $a0, 0x2C($t0)
	sw $a0, 0x28($t0)
	sw $a0, 0x24($t0)
	sw $a0, 0x20($t0)
	sw $a0, 0x1C($t0)
	sw $a0, 0x18($t0)
	sw $a0, 0x14($t0)
	sw $a0, 0x10($t0)
	sw $a0, 0xC($t0)
	sw $a0, 0x8($t0)
	sw $a0, 0x4($t0)
	sw $a0, 0x204($t0)
	sw $a0, 0x208($t0)
	sw $a0, 0x20c($t0)
	sw $a0, 0x210($t0)
	sw $a0, 0x214($t0)
	sw $a0, 0x218($t0)
	sw $a0, 0x21c($t0)
	sw $a0, 0x220($t0)
	sw $a0, 0x224($t0)
	sw $a0, 0x228($t0)
	sw $a0, 0x22c($t0)
	sw $a0, 0x230($t0)
	sw $a0, 0x234($t0)
	sw $a0, 0x238($t0)
	sw $a0, 0x23c($t0)
	sw $a0, 0x240($t0)
	sw $a0, 0x244($t0)
	sw $a0, 0x248($t0)
	sw $a0, 0x24c($t0)
	sw $a0, 0x250($t0)
	sw $a0, 0x254($t0)
	sw $a0, 0x258($t0)
	sw $a0, 0x25c($t0)
	sw $a0, 0x260($t0)
	sw $a0, 0x460($t0)
	sw $a0, 0x45c($t0)
	sw $a0, 0x458($t0)
	sw $a0, 0x454($t0)
	sw $a0, 0x450($t0)
	sw $a0, 0x44c($t0)
	sw $a0, 0x448($t0)
	sw $a0, 0x444($t0)
	sw $a0, 0x440($t0)
	sw $a0, 0x43c($t0)
	sw $a0, 0x438($t0)
	sw $a0, 0x434($t0)
	sw $a0, 0x430($t0)
	sw $a0, 0x42c($t0)
	sw $a0, 0x428($t0)
	sw $a0, 0x424($t0)
	sw $a0, 0x420($t0)
	sw $a0, 0x41c($t0)
	sw $a0, 0x418($t0)
	sw $a0, 0x414($t0)
	sw $a0, 0x410($t0)
	sw $a0, 0x40c($t0)
	sw $a0, 0x408($t0)
	sw $a0, 0x404($t0)  # termina de pintar barriga na esquerda
	sw $a0, 0xC04($t0) # fazer ~pneus
	sw $a0, 0xC08($t0)
	sw $a0, 0xC0c($t0)
	sw $a0, 0xa08($t0)
	sw $a0, 0xE08($t0)
	sw $a0, 0xC20($t0) # fazer ~pneus
	sw $a0, 0xC24($t0)
	sw $a0, 0xC28($t0)
	sw $a0, 0xa24($t0)
	sw $a0, 0xE24($t0)
	sw $a0, 0xC3c($t0) 
	sw $a0, 0xC40($t0)
	sw $a0, 0xC44($t0)
	sw $a0, 0xa40($t0)
	sw $a0, 0xE40($t0)
	sw $a0, 0xC58($t0) 
	sw $a0, 0xC5c($t0)
	sw $a0, 0xC60($t0)
	sw $a0, 0xa5c($t0)
	sw $a0, 0xE5c($t0)
	sw $a0, -0x11D4($t0)
	sw $a0, -0x13D4($t0)
	sw $a0, -0x13D0($t0)
	sw $a0, -0x13CC($t0)
	sw $a0, -0x13C8($t0)
	sw $a0, -0x13C4($t0)
	sw $a0, -0x13C0($t0)
	sw $a0, -0x13D8($t0)
	sw $a0, -0x13DC($t0)
	sw $a0, -0x15D8($t0)
	sw $a0, -0x15Dc($t0)
	li $a0, 0
	li $t0, 0
	li $v0, 0
	jr $ra
	nop

ScoreII: move $k0, $ra
	 jal EraseScore2
	 nop
	 lw $t1, TankIIScore
	 addi $t1, $t1, 1
	 sw $t1, TankIIScore
	 
	 beq $t1, 0x1, DrawOneScore2
	 nop
	 beq $t1, 0x2, DrawTwoScore2
	 nop
	 beq $t1, 0x3, DrawThreeScore2
	 nop
	 beq $t1, 0x4, DrawFourScore2
	 nop
	 beq $t1, 0x5, PlayerIIWIn
	 nop
	 EndScore2: jr $k0
	            nop
###################################################3
###################################################################################################################
###################################################################################################################

	 	     
ScoreI:  move $k0, $ra
	 jal EraseScore1
	 nop
 	 lw $t1, TankIScore
	 addi $t1, $t1, 1
	 sw $t1, TankIScore
	 
	 beq $t1, 0x1, DrawOneScore1
	 nop
	 beq $t1, 0x2, DrawTwoScore1
	 nop
	 beq $t1, 0x3, DrawThreeScore1
	 nop
	 beq $t1, 0x4, DrawFourScore1
	 nop
	 beq $t1, 0x5, PlayerIWIn
	 nop
	 EndScore1: jr $k0
	            nop

DrawZeroScore1: li $t4, 0x0000FF
       move $t0, $k1
       addi $t1, $t0, 712
       addi $t2, $t0, 680
       addi $t5, $t2, 4 #vertical
       li $t3, 0
   Print0: beq $t3, 12, NextPrint0
          nop
          sw $t4, 0($t1)
          sw $t4, 0($t2)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t3, $t3, 1
          j Print0
          nop
    NextPrint0: subi $t2, $t2,512
    		addi $t6, $t2,4
                li $t3, 0
         NextPrint0for: beq $t3, 7, EndPrint0
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextPrint0for
          	nop       
   EndPrint0: jr $ra
       nop
       
DrawZeroScore2: li $t4, 0xFFFF00
       move $t0, $k1
       addi $t1, $t0, 820
       addi $t2, $t0, 788
       addi $t5, $t2, 4 #vertical
       li $t3, 0
   Print02: beq $t3, 12, NextPrint02
          nop
          sw $t4, 0($t1)
          sw $t4, 0($t2)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t3, $t3, 1
          j Print02
          nop
    NextPrint02: subi $t2, $t2,512
    		addi $t6, $t2,4
                li $t3, 0
         NextPrint0for2: beq $t3, 7, EndPrint02
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextPrint0for2
          	nop       
   EndPrint02: jr $ra
               nop
#################################################################
##################### Numeros     ###############################      
#################################################################            
DrawOneScore1: li $t4, 0x0000FF
       move $t0, $k1
       addi $t1, $t0, 712
       move $t2, $t1
       li $t3, 0
       li $t8, 0
   Print1: beq $t3, 12, NextPrint1
          nop
          sw $t4, 0($t1)
          addi $t1, $t1, 512
          addi $t3, $t3, 1
          j Print1
          nop
    NextPrint1: beq $t8, 3, EndPrint1
                nop
                addi $t2, $t2, 508
                sw $t4, ($t2)
                addi $t8, $t8, 1
                j NextPrint1
                nop
   EndPrint1: j EndScore1
       nop
       
DrawOneScore2: li $t4, 0xFFFF00
       move $t0, $k1
       addi $t1, $t0, 820
       move $t2, $t1
       li $t3, 0
       li $t8, 0
   Print12: beq $t3, 12, NextPrint12
          nop
          sw $t4, 0($t1)
          addi $t1, $t1, 512
          addi $t3, $t3, 1
          j Print1
          nop
    NextPrint12: beq $t8, 3, EndPrint12
                nop
                addi $t2, $t2, 508
                sw $t4, ($t2)
                addi $t8, $t8, 1
                j NextPrint1
                nop
   EndPrint12: j EndScore2
       nop
       
DrawTwoScore1: li $t4, 0x0000FF
       move $t0, $k1
       addi $t1, $t0, 712
       #addi $t7, $t0, 680
       addi $t2, $t0, 3752
       addi $t5, $t0, 680 #vertical
       addi $t8, $t5, 2560  #meio
       li $t3, 0
       li $t9, 0
   PrintTwoFor: beq $t3, 6, NextPrintTwo
          nop
          sw $t4, 0($t1)
          sw $t4, 0($t2)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t3, $t3, 1
          j PrintTwoFor
          nop
    NextPrintTwo: subi $t2, $t2,512
    		addi $t6, $t2,4
                li $t3, 0
         NextNextPrintTwo: beq $t3, 8, PrintTwoMid
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextNextPrintTwo
          	nop
     PrintTwoMid: beq $t9, 8, EndPrintTwo
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j PrintTwoMid
          	nop     	       
    EndPrintTwo: j EndScore1
       nop
       
DrawTwoScore2: li $t4, 0xFFFF00
       move $t0, $k1
       addi $t1, $t0, 820
       #addi $t7, $t0, 788
       addi $t2, $t0, 3860
       addi $t5, $t0, 788 #vertical
       addi $t8, $t5, 2560  #meio
       li $t3, 0
       li $t9, 0
   PrintTwoFor2: beq $t3, 6, NextPrintTwo2
          nop
          sw $t4, 0($t1)
          sw $t4, 0($t2)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t3, $t3, 1
          j PrintTwoFor
          nop
    NextPrintTwo2: subi $t2, $t2,512
    		addi $t6, $t2,4
                li $t3, 0
         NextNextPrintTwo2: beq $t3, 8, PrintTwoMid2
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextNextPrintTwo2
          	nop
     PrintTwoMid2: beq $t9, 8, EndPrintTwo2
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j PrintTwoMid2
          	nop     	       
    EndPrintTwo2: j EndScore2
       nop
       
DrawThreeScore1: li $t4, 0x0000FF
       move $t0, $k1
       addi $t1, $t0, 712
       addi $t2, $t0, 680
       addi $t5, $t2, 4 #vertical
       addi $t8, $t2, 2564  #meio
       li $t3, 0
       li $t9, 0
   PrintThreeFor: beq $t3, 12, NextPrintThree
          nop
          sw $t4, 0($t1)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t3, $t3, 1
          j PrintThreeFor
          nop
    NextPrintThree: subi $t2, $t2,512
    		addi $t6, $t2,4
                li $t3, 0
         NextNextPrintThree: beq $t3, 7, PrintThreeMid
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextNextPrintThree
          	nop
     PrintThreeMid: beq $t9, 8, EndPrintThree
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j PrintThreeMid
          	nop     	       
    EndPrintThree: j EndScore1
       nop
       
DrawThreeScore2: li $t4, 0xFFFF00
       move $t0, $k1
       addi $t1, $t0, 820
       addi $t2, $t0, 788
       addi $t5, $t2, 4 #vertical
       addi $t8, $t2, 2564  #meio
       li $t3, 0
       li $t9, 0
   PrintThreeFor2: beq $t3, 12, NextPrintThree2
          nop
          sw $t4, 0($t1)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t3, $t3, 1
          j PrintThreeFor2
          nop
    NextPrintThree2: subi $t2, $t2,512
    		addi $t6, $t2,4
                li $t3, 0
         NextNextPrintThree2: beq $t3, 7, PrintThreeMid2
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextNextPrintThree2
          	nop
     PrintThreeMid2: beq $t9, 8, EndPrintThree2
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j PrintThreeMid2
          	nop     	       
    EndPrintThree2: j EndScore2
       nop
       
DrawFourScore1: li $t4, 0x0000FF
       move $t0, $k1
       addi $t1, $t0, 712
       addi $t2, $t0, 680
       addi $t5, $t2, 4 #vertical
       addi $t8, $t2, 2560  #meio
       li $t3, 0
       li $t7, 0
       li $t9, 0
   PrintFourFor: beq $t3, 12, PrintFourFor2
          nop
          sw $t4, 0($t1)
          addi $t1, $t1, 512
          addi $t3, $t3, 1
          j PrintFourFor
          nop
     PrintFourFor2: beq $t7, 6, NextPrintFour
          nop
          sw $t4, 0($t2)
          addi $t2, $t2, 512
          addi $t7, $t7, 1
          j PrintFourFor2
          nop     
    NextPrintFour: #subi $t2, $t2,512
    		#addi $t6, $t2,4
                li $t3, 0
         
     PrintFourMid: beq $t9, 8, EndPrintFour
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j PrintThreeMid
          	nop     	       
    EndPrintFour: j EndScore1
       nop
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
DrawFourScore2: li $t4, 0xFFFF00
       move $t0, $k1
       addi $t1, $t0, 820
       addi $t2, $t0, 788
       addi $t5, $t2, 4 #vertical
       addi $t8, $t2, 2560  #meio
       li $t3, 0
       li $t7, 0
       li $t9, 0
   PrintFourWHile2: beq $t3, 12, PrintFour2For2
          nop
          sw $t4, 0($t1)
          addi $t1, $t1, 512
          addi $t3, $t3, 1
          j PrintFourWHile2
          nop
     PrintFour2For2: beq $t7, 6, NextPrintFour2
          nop
          sw $t4, 0($t2)
          addi $t2, $t2, 512
          addi $t7, $t7, 1
          j PrintFour2For2
          nop     
    NextPrintFour2: #subi $t2, $t2,512
    		#addi $t6, $t2,4
                li $t3, 0
         
     PrintFourMid2: beq $t9, 8, EndPrintFour2
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j PrintThreeMid2
          	nop     	       
    EndPrintFour2: j EndScore2
       nop

       
DrawFiveScore1: li $t4, 0x0000FF
       move $t0, $k1
       addi $t1, $t0, 712
       addi $t7, $t0, 3784
       addi $t2, $t0, 680
       addi $t5, $t2, 4 #vertical
       addi $t8, $t2, 2564  #meio
       li $t3, 0
       li $t9, 0
   PrintFiveFor: beq $t3, 6, NextPrintFive
          nop
          sw $t4, 0($t2)
          sw $t4, 0($t7)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t7, $t7, 512
          addi $t3, $t3, 1
          j PrintFiveFor
          nop
    NextPrintFive: addi $t2, $t2,2556
    		addi $t6, $t2,4
                li $t3, 0
         NextNextPrintFive: beq $t3, 8, PrintFiveMid
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextNextPrintFive
          	nop
     PrintFiveMid: beq $t9, 8, EndPrintFive
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j PrintFiveMid
          	nop     	       
    EndPrintFive: jr $ra
       nop
      
DrawFiveScore2: li $t4, 0xFFFF00
       move $t0, $k1
       addi $t1, $t0, 820
       addi $t2, $t0, 788
       addi $t7, $t0, 3892
       addi $t5, $t2, 4 #vertical
       addi $t8, $t2, 2564  #meio
       li $t3, 0
       li $t9, 0
   PrintFiveFor2: beq $t3, 6, NextPrintFive2
          nop
          sw $t4, 0($t2)
          sw $t4, 0($t7)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t7, $t7, 512
          addi $t3, $t3, 1
          j PrintFiveFor2
          nop
    NextPrintFive2: addi $t2, $t2,2556
    		addi $t6, $t2,4
                li $t3, 0
         NextNextPrintFive2: beq $t3, 8, PrintFiveMid2
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextNextPrintFive2
          	nop
     PrintFiveMid2: beq $t9, 8, EndPrintFive2
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j PrintFiveMid2
          	nop     	       
    EndPrintFive2: jr $ra
       nop
#################################################################     
#################################################################      
#################################################################       
#################################################################      

X: move $t0, $k1 #750
   addi $t1, $t0, 3824       
   li $t4, 0xc0c0c0
   sw $t4, 0($t1)
   sw $t4, 508($t1)
   sw $t4, 516($t1)
   sw $t4, -508($t1)
   sw $t4, -516($t1)
   jr $ra
   nop
   
EraseScore1: li $t4, 0x000
       move $t0, $k1
       addi $t1, $t0, 712
       addi $t2, $t0, 680
       addi $t5, $t2, 4 #vertical
       addi $t8, $t2, 2560  #meio
       li $t3, 0
       li $t9, 0
       sw $t4, 508($t1)
       sw $t4, 1016($t1)
       sw $t4, 1524($t1)
   EraseNumberFor: beq $t3, 12, NextEraseNumber
          nop
          sw $t4, 0($t1)
          sw $t4, 0($t2)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t3, $t3, 1
          j EraseNumberFor
          nop
    NextEraseNumber: subi $t2, $t2,512
    		addi $t6, $t2,4
                li $t3, 0
         NextNextEraseNumber: beq $t3, 7, EraseMidNumb
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextNextEraseNumber
          	nop
     EraseMidNumb: beq $t9, 8, EndEraseNumber
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j EraseMidNumb
          	nop     	       
    EndEraseNumber: jr $ra
       nop
       
EraseScore2: li $t4, 0x000
       move $t0, $k1
       addi $t1, $t0, 820
       addi $t2, $t0, 788
       addi $t5, $t2, 4 #vertical
       addi $t8, $t2, 2636  #meio
       li $t3, 0
       li $t9, 0
       sw $t4, 508($t1)
       sw $t4, 1016($t1)
       sw $t4, 1524($t1)
   EraseNumberFor2: beq $t3, 12, NextEraseNumber2
          nop
          sw $t4, 0($t1)
          sw $t4, 0($t2)
          addi $t1, $t1, 512
          addi $t2, $t2, 512
          addi $t3, $t3, 1
          j EraseNumberFor2
          nop
    NextEraseNumber2: subi $t2, $t2,512
    		addi $t6, $t2,4
                li $t3, 0
         NextNextEraseNumber2: beq $t3, 7, EraseMidNumb2
                nop
                sw $t4, 0($t5)
                sw $t4, 0($t6)
                addi $t5, $t5, 4
          	addi $t6, $t6, 4
          	addi $t3, $t3, 1
          	j NextNextEraseNumber2
          	nop
     EraseMidNumb2: beq $t9, 8, EndEraseNumber2
     		nop
     		sw $t4, 0($t8)
                addi $t8, $t8, 4
          	addi $t9, $t9, 1
          	j EraseMidNumb2
          	nop     	       
    EndEraseNumber2: jr $ra
       nop 
#######################################################       
#######################################################       
#######################################################       
	 	    	 	    
PlayerIIWIn:
	    jal DrawFiveScore2
	    nop
	    jal WritePlayer2Win
	    nop
	    li $v0, 12
	    syscall
	    nop
	    beq $v0, 0x31, SinglePlayer
	    nop
	    beq $v0, 0x79, ResetaTela
	    nop
	    jal ResetaTela2
	    nop
	    li $v0, 10
	     syscall

PlayerIWIn: 
	    jal DrawFiveScore1
	    nop
	    jal WritePlayer1Win
	    nop
	    li $v0, 12
	    syscall
	    nop
	    beq $v0, 0x31, SinglePlayer
	    nop
	    beq $v0, 0x79, ResetaTela
	    nop
	    jal ResetaTela2
	    nop
	    li $v0, 10
	     syscall
####################################################################################################################
###################p escrever q ganhou #############################################################################	     
####################################################################################################################	     
WritePlayer1Win:li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
addi $t0, $t0, 0x4088
li $a0, 0x0000FF
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)  # P
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0xA04($t0)  
sw $a0, 0xA08($t0) # L
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x8($t0)
sw $a0, 0x204($t0)
sw $a0 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0) # Y
addi $t0, $t0, 0x10 
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0 0x8($t0)
sw $a0, 0x604($t0)
sw $a0, 0x608($t0)
sw $a0, 0xA04($t0)
sw $a0, 0xA08($t0)   # E
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA08($t0)   # R
addi $t0, $t0, 0x20 
sw $a0, 4($t0)
sw $a0 0x200($t0)
sw $a0, 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # 1
addi $t0, $t0, 0x20 
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # W
addi $t0, $t0, 0x10
sw $a0, 4($t0)
sw $a0 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x8($t0)
sw $a0 0($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # I
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x404($t0) # N
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x4($t0)
sw $a0 0x8($t0)
sw $a0, 0x200($t0)
sw $a0 0x400($t0)
sw $a0 0x600($t0)
sw $a0 0x604($t0)
sw $a0 0x608($t0)
sw $a0 0x808($t0)
sw $a0 0xA08($t0)
sw $a0 0xA04($t0)
sw $a0 0xA00($t0)  # S
addi $t0, $t0, 0x10
sw $a0, -0x200($t0)
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0xA00($t0) # !
########################################
#####3 trofeuzinho
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8CDC
addi $t0, $t0, 0x8000
li $a0, 0xFFFF00
sw $a0, 0($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, -0x1Fc($t0)
sw $a0, -0x1f8($t0)
sw $a0, 0xA04($t0)
sw $a0, 0xC08($t0)
sw $a0, 0xC0C($t0)
sw $a0, 0xC10($t0)
sw $a0, 0xE14($t0)
sw $a0, 0x1018($t0)
sw $a0, 0x121c($t0)
sw $a0, 0x141c($t0)
sw $a0, 0x161c($t0)
sw $a0, 0x181c($t0)
sw $a0, 0x1818($t0)
sw $a0, 0x1814($t0)
sw $a0, 0x1810($t0)
sw $a0, 0x1820($t0)
sw $a0, 0x1824($t0)
sw $a0, 0x1828($t0)
sw $a0, 0x182c($t0)
sw $a0, 0x1620($t0)
sw $a0, 0x1420($t0)
sw $a0, 0x1220($t0)
sw $a0, 0x1024($t0)
sw $a0, 0xE28($t0)
sw $a0, 0xC2C($t0)
sw $a0, 0xC30($t0)
sw $a0, 0xC34($t0)
sw $a0, 0xA38($t0)
sw $a0, 0x83C($t0)
sw $a0, 0x63C($t0)
sw $a0, 0x43C($t0)
sw $a0, 0x23C($t0)
sw $a0, 0x3C($t0)
sw $a0, -0x1C8($t0)
sw $a0, -0x1CC($t0)
sw $a0, -0x1D0($t0)
sw $a0, -0x3D0($t0)
sw $a0, -0x5D0($t0)
sw $a0, -0x7D0($t0)
sw $a0, -0x7D4($t0)
sw $a0, -0x7CC($t0)
sw $a0, -0x7D8($t0)
sw $a0, -0x7DC($t0)
sw $a0, -0x7E0($t0)
sw $a0, -0x7E4($t0)
sw $a0, -0x7E8($t0)
sw $a0, -0x7EC($t0)
sw $a0, -0x7F0($t0)
sw $a0, -0x7F4($t0)
sw $a0, -0x7F8($t0)
sw $a0, -0x5F4($t0)
sw $a0, -0x3F4($t0)
sw $a0, -0x1F4($t0)
sw $a0, 0xC($t0)
sw $a0, 0x20C($t0)
sw $a0, 0x40C($t0)
sw $a0, 0x60C($t0)
sw $a0, 0x80C($t0)
sw $a0, 0xA10($t0)
sw $a0, 0xA2c($t0)
sw $a0, 0x830($t0)
sw $a0, 0x630($t0)
sw $a0, 0x430($t0)
sw $a0, 0x230($t0)
sw $a0, 0x30($t0)
li $a0, 0x804000 # marronzinho p fazer o suporte
sw $a0, 0x1a0c($t0)
sw $a0, 0x1c0c($t0)
sw $a0, 0x1e0c($t0)
sw $a0, 0x1e10($t0)
sw $a0, 0x1e14($t0)
sw $a0, 0x1e18($t0)
sw $a0, 0x1e1c($t0)
sw $a0, 0x1e20($t0)
sw $a0, 0x1e24($t0)
sw $a0, 0x1e28($t0)
sw $a0, 0x1e2c($t0)
sw $a0, 0x1e30($t0)
sw $a0, 0x1c30($t0)
sw $a0, 0x1a30($t0)
sw $a0, 0x1a2c($t0)
sw $a0, 0x1a28($t0)
sw $a0, 0x1a24($t0)
sw $a0, 0x1a20($t0)
sw $a0, 0x1a1c($t0)
sw $a0, 0x1a18($t0)
sw $a0, 0x1a14($t0)
sw $a0, 0x1a10($t0)
li $a0, 0xe6b800 # amarelo
sw $a0, 0x1c10($t0)
sw $a0, 0x1c14($t0)
sw $a0, 0x1c18($t0)
sw $a0, 0x1c1c($t0)
sw $a0, 0x1c20($t0)
sw $a0, 0x1c24($t0)
sw $a0, 0x1c28($t0)
sw $a0, 0x1c2c($t0)
li $a0, 0xfff5cc  # branquinho fail
sw $a0, -0x3DC($t0)
sw $a0, -0x1DC($t0)
sw $a0, 0x24($t0)
sw $a0, 0x220($t0)
li $a0, 0xffff33 # amarelinho p colorir
sw $a0, -0x5DC($t0)
sw $a0, -0x5D8($t0)
sw $a0, -0x5D4($t0)
sw $a0, -0x3D4($t0)
sw $a0, -0x1D4($t0)
sw $a0, 0x2c($t0)
sw $a0, 0x22c($t0)
sw $a0, 0x42c($t0)
sw $a0, 0x62c($t0)
sw $a0, 0x82c($t0)
sw $a0, 0x828($t0)
sw $a0, 0xA28($t0)
sw $a0, 0xC28($t0)
sw $a0, 0xE24($t0)
sw $a0, 0x1020($t0)
sw $a0, 0x101C($t0)
sw $a0, 0xE20($t0)
sw $a0, 0xE1C($t0)
sw $a0, 0xE18($t0)
sw $a0, 0xC14($t0)
sw $a0, 0xA14($t0)
sw $a0, 0x814($t0)
sw $a0, 0x810($t0)
sw $a0, 0x610($t0)
sw $a0, 0x410($t0)
sw $a0, 0x210($t0)
sw $a0, 0x10($t0)
sw $a0, -0x1F0($t0)
sw $a0, -0x3F0($t0)
sw $a0, -0x5F0($t0)
sw $a0, -0x5EC($t0)
sw $a0, -0x5E8($t0)
sw $a0, -0x5E4($t0)
sw $a0, -0x5E0($t0)
sw $a0, -0x3E0($t0)
sw $a0, -0x1E0($t0)
sw $a0, 0x20($t0)
sw $a0, 0x1c($t0)
sw $a0, -0x1E4($t0)
sw $a0, -0x3E4($t0)
sw $a0, -0x3E8($t0)
sw $a0, -0x3EC($t0)
sw $a0, -0x1EC($t0)
sw $a0, 0x14($t0)
sw $a0, 0x214($t0)
sw $a0, 0x414($t0)
sw $a0, 0x614($t0)
sw $a0, -0x1E8($t0)
sw $a0, 0x18($t0)
sw $a0, 0x218($t0)
sw $a0, 0x418($t0)
sw $a0, 0x618($t0)
sw $a0, 0x818($t0)
sw $a0, 0xA18($t0)
sw $a0, 0xC18($t0)
sw $a0, 0xC1C($t0)
sw $a0, 0xA1C($t0)
sw $a0, 0x81C($t0)
sw $a0, 0x61C($t0)
sw $a0, 0x41C($t0)
sw $a0, 0x21C($t0)
sw $a0, 0x420($t0)
sw $a0, 0x620($t0)
sw $a0, 0x820($t0)
sw $a0, 0xA20($t0)
sw $a0, 0xC20($t0)
sw $a0, 0xC24($t0)
sw $a0, 0xA24($t0)
sw $a0, 0x824($t0)
sw $a0, 0x624($t0)
sw $a0, 0x424($t0)
sw $a0, 0x224($t0)
sw $a0, 0x628($t0)
sw $a0, 0x428($t0)
sw $a0, 0x228($t0)
sw $a0, 0x028($t0)
sw $a0, -0x1D8($t0)
sw $a0, -0x3D8($t0)
#######################################33
# play again?
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
addi $t0, $t0, 0x8060
addi $t0, $t0, 0x6000
subi $t0, $t0, 0x400
li $a0, 0xc0c0c0 # cinza
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)  # P
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0xA04($t0)  
sw $a0, 0xA08($t0) # L
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x8($t0)
sw $a0, 0x204($t0)
sw $a0 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0) # Y
addi $t0, $t0, 0x20
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x808($t0)
sw $a0, 0x404($t0)
sw $a0, 0x608($t0) # G
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 4($t0)
sw $a0 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x8($t0)
sw $a0 0($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # I
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x404($t0) # N
addi $t0, $t0, 0x10
sw $a0, 0x200($t0)
sw $a0, 0x0($t0)
sw $a0, -0x1FC($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0xA08($t0) # ?
addi $t0, $t0, 0x20
sw $a0, -0x200($t0)
sw $a0, -0x1FC($t0)
sw $a0, 0($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0) 
sw $a0, 0xA04($t0) # [
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x8($t0)
sw $a0, 0x204($t0)
sw $a0 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0) # Y
addi $t0, $t0, 0x20
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x808($t0)
sw $a0, 0x608($t0)
sw $a0, 0x408($t0)
sw $a0, 0x208($t0) # O
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA08($t0)   # R
addi $t0, $t0, 0x20
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x404($t0) # N
addi $t0, $t0, 0x10
sw $a0, -0x200($t0)
sw $a0, -0x1FC($t0)
sw $a0, 0x4($t0)
sw $a0, 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0)
sw $a0, 0xA00($t0) # ]

li $a0, 0
li $t0, 0
jr $ra
nop

#######################	     

WritePlayer2Win:
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
addi $t0, $t0, 0x4088
li $a0, 0xFFFF00
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)  # P
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0xA04($t0)  
sw $a0, 0xA08($t0) # L
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x8($t0)
sw $a0, 0x204($t0)
sw $a0 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0) # Y
addi $t0, $t0, 0x10 
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0 0x8($t0)
sw $a0, 0x604($t0)
sw $a0, 0x608($t0)
sw $a0, 0xA04($t0)
sw $a0, 0xA08($t0)   # E
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA08($t0)   # R
addi $t0, $t0, 0x20 
sw $a0, 0xA08($t0)
sw $a0, 0xA04($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x800($t0)
sw $a0, 0x604($t0)
sw $a0, 0x408($t0)
sw $a0, 0x208($t0)
sw $a0, 0x8($t0)
sw $a0, 0x4($t0)
sw $a0, 0x0($t0) # 2
addi $t0, $t0, 0x20 
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # W
addi $t0, $t0, 0x10
sw $a0, 4($t0)
sw $a0 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x8($t0)
sw $a0 0($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # I
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x404($t0) # N
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x4($t0)
sw $a0 0x8($t0)
sw $a0, 0x200($t0)
sw $a0 0x400($t0)
sw $a0 0x600($t0)
sw $a0 0x604($t0)
sw $a0 0x608($t0)
sw $a0 0x808($t0)
sw $a0 0xA08($t0)
sw $a0 0xA04($t0)
sw $a0 0xA00($t0)  # S
addi $t0, $t0, 0x10
sw $a0, -0x200($t0)
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0xA00($t0) # !
########################################
#####3 trofeuzinho
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8CDC
addi $t0, $t0, 0x8000
li $a0, 0xFFFF00
sw $a0, 0($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, -0x1Fc($t0)
sw $a0, -0x1f8($t0)
sw $a0, 0xA04($t0)
sw $a0, 0xC08($t0)
sw $a0, 0xC0C($t0)
sw $a0, 0xC10($t0)
sw $a0, 0xE14($t0)
sw $a0, 0x1018($t0)
sw $a0, 0x121c($t0)
sw $a0, 0x141c($t0)
sw $a0, 0x161c($t0)
sw $a0, 0x181c($t0)
sw $a0, 0x1818($t0)
sw $a0, 0x1814($t0)
sw $a0, 0x1810($t0)
sw $a0, 0x1820($t0)
sw $a0, 0x1824($t0)
sw $a0, 0x1828($t0)
sw $a0, 0x182c($t0)
sw $a0, 0x1620($t0)
sw $a0, 0x1420($t0)
sw $a0, 0x1220($t0)
sw $a0, 0x1024($t0)
sw $a0, 0xE28($t0)
sw $a0, 0xC2C($t0)
sw $a0, 0xC30($t0)
sw $a0, 0xC34($t0)
sw $a0, 0xA38($t0)
sw $a0, 0x83C($t0)
sw $a0, 0x63C($t0)
sw $a0, 0x43C($t0)
sw $a0, 0x23C($t0)
sw $a0, 0x3C($t0)
sw $a0, -0x1C8($t0)
sw $a0, -0x1CC($t0)
sw $a0, -0x1D0($t0)
sw $a0, -0x3D0($t0)
sw $a0, -0x5D0($t0)
sw $a0, -0x7D0($t0)
sw $a0, -0x7D4($t0)
sw $a0, -0x7CC($t0)
sw $a0, -0x7D8($t0)
sw $a0, -0x7DC($t0)
sw $a0, -0x7E0($t0)
sw $a0, -0x7E4($t0)
sw $a0, -0x7E8($t0)
sw $a0, -0x7EC($t0)
sw $a0, -0x7F0($t0)
sw $a0, -0x7F4($t0)
sw $a0, -0x7F8($t0)
sw $a0, -0x5F4($t0)
sw $a0, -0x3F4($t0)
sw $a0, -0x1F4($t0)
sw $a0, 0xC($t0)
sw $a0, 0x20C($t0)
sw $a0, 0x40C($t0)
sw $a0, 0x60C($t0)
sw $a0, 0x80C($t0)
sw $a0, 0xA10($t0)
sw $a0, 0xA2c($t0)
sw $a0, 0x830($t0)
sw $a0, 0x630($t0)
sw $a0, 0x430($t0)
sw $a0, 0x230($t0)
sw $a0, 0x30($t0)
li $a0, 0x804000 # marronzinho p fazer o suporte
sw $a0, 0x1a0c($t0)
sw $a0, 0x1c0c($t0)
sw $a0, 0x1e0c($t0)
sw $a0, 0x1e10($t0)
sw $a0, 0x1e14($t0)
sw $a0, 0x1e18($t0)
sw $a0, 0x1e1c($t0)
sw $a0, 0x1e20($t0)
sw $a0, 0x1e24($t0)
sw $a0, 0x1e28($t0)
sw $a0, 0x1e2c($t0)
sw $a0, 0x1e30($t0)
sw $a0, 0x1c30($t0)
sw $a0, 0x1a30($t0)
sw $a0, 0x1a2c($t0)
sw $a0, 0x1a28($t0)
sw $a0, 0x1a24($t0)
sw $a0, 0x1a20($t0)
sw $a0, 0x1a1c($t0)
sw $a0, 0x1a18($t0)
sw $a0, 0x1a14($t0)
sw $a0, 0x1a10($t0)
li $a0, 0xe6b800 # amarelo
sw $a0, 0x1c10($t0)
sw $a0, 0x1c14($t0)
sw $a0, 0x1c18($t0)
sw $a0, 0x1c1c($t0)
sw $a0, 0x1c20($t0)
sw $a0, 0x1c24($t0)
sw $a0, 0x1c28($t0)
sw $a0, 0x1c2c($t0)
li $a0, 0xfff5cc  # branquinho fail
sw $a0, -0x3DC($t0)
sw $a0, -0x1DC($t0)
sw $a0, 0x24($t0)
sw $a0, 0x220($t0)
li $a0, 0xffff33 # amarelinho p colorir
sw $a0, -0x5DC($t0)
sw $a0, -0x5D8($t0)
sw $a0, -0x5D4($t0)
sw $a0, -0x3D4($t0)
sw $a0, -0x1D4($t0)
sw $a0, 0x2c($t0)
sw $a0, 0x22c($t0)
sw $a0, 0x42c($t0)
sw $a0, 0x62c($t0)
sw $a0, 0x82c($t0)
sw $a0, 0x828($t0)
sw $a0, 0xA28($t0)
sw $a0, 0xC28($t0)
sw $a0, 0xE24($t0)
sw $a0, 0x1020($t0)
sw $a0, 0x101C($t0)
sw $a0, 0xE20($t0)
sw $a0, 0xE1C($t0)
sw $a0, 0xE18($t0)
sw $a0, 0xC14($t0)
sw $a0, 0xA14($t0)
sw $a0, 0x814($t0)
sw $a0, 0x810($t0)
sw $a0, 0x610($t0)
sw $a0, 0x410($t0)
sw $a0, 0x210($t0)
sw $a0, 0x10($t0)
sw $a0, -0x1F0($t0)
sw $a0, -0x3F0($t0)
sw $a0, -0x5F0($t0)
sw $a0, -0x5EC($t0)
sw $a0, -0x5E8($t0)
sw $a0, -0x5E4($t0)
sw $a0, -0x5E0($t0)
sw $a0, -0x3E0($t0)
sw $a0, -0x1E0($t0)
sw $a0, 0x20($t0)
sw $a0, 0x1c($t0)
sw $a0, -0x1E4($t0)
sw $a0, -0x3E4($t0)
sw $a0, -0x3E8($t0)
sw $a0, -0x3EC($t0)
sw $a0, -0x1EC($t0)
sw $a0, 0x14($t0)
sw $a0, 0x214($t0)
sw $a0, 0x414($t0)
sw $a0, 0x614($t0)
sw $a0, -0x1E8($t0)
sw $a0, 0x18($t0)
sw $a0, 0x218($t0)
sw $a0, 0x418($t0)
sw $a0, 0x618($t0)
sw $a0, 0x818($t0)
sw $a0, 0xA18($t0)
sw $a0, 0xC18($t0)
sw $a0, 0xC1C($t0)
sw $a0, 0xA1C($t0)
sw $a0, 0x81C($t0)
sw $a0, 0x61C($t0)
sw $a0, 0x41C($t0)
sw $a0, 0x21C($t0)
sw $a0, 0x420($t0)
sw $a0, 0x620($t0)
sw $a0, 0x820($t0)
sw $a0, 0xA20($t0)
sw $a0, 0xC20($t0)
sw $a0, 0xC24($t0)
sw $a0, 0xA24($t0)
sw $a0, 0x824($t0)
sw $a0, 0x624($t0)
sw $a0, 0x424($t0)
sw $a0, 0x224($t0)
sw $a0, 0x628($t0)
sw $a0, 0x428($t0)
sw $a0, 0x228($t0)
sw $a0, 0x028($t0)
sw $a0, -0x1D8($t0)
sw $a0, -0x3D8($t0)
#######################################33
# play again?
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
addi $t0, $t0, 0x8060
addi $t0, $t0, 0x6000
subi $t0, $t0, 0x400
li $a0, 0xc0c0c0 # cinza
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)  # P
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0xA04($t0)  
sw $a0, 0xA08($t0) # L
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x8($t0)
sw $a0, 0x204($t0)
sw $a0 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0) # Y
addi $t0, $t0, 0x20
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x808($t0)
sw $a0, 0x404($t0)
sw $a0, 0x608($t0) # G
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 4($t0)
sw $a0 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x8($t0)
sw $a0 0($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # I
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x404($t0) # N
addi $t0, $t0, 0x10
sw $a0, 0x200($t0)
sw $a0, 0x0($t0)
sw $a0, -0x1FC($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0xA08($t0) # ?
addi $t0, $t0, 0x20
sw $a0, -0x200($t0)
sw $a0, -0x1FC($t0)
sw $a0, 0($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0) 
sw $a0, 0xA04($t0) # [
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x8($t0)
sw $a0, 0x204($t0)
sw $a0 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0) # Y
addi $t0, $t0, 0x20
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x808($t0)
sw $a0, 0x608($t0)
sw $a0, 0x408($t0)
sw $a0, 0x208($t0) # O
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA08($t0)   # R
addi $t0, $t0, 0x20
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x404($t0) # N
addi $t0, $t0, 0x10
sw $a0, -0x200($t0)
sw $a0, -0x1FC($t0)
sw $a0, 0x4($t0)
sw $a0, 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0)
sw $a0, 0xA00($t0) # ]

li $a0, 0
li $t0, 0
jr $ra
nop

ResetaTela:
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
li $t1, 0
li $t2, 0x000000
LoopPraResetar:
sw $t2, 0($t0)
addi $t0, $t0, 0x4
addi $t1, $t1, 1
beq $t1, 16512, FimLoopPraResetar
nop
j LoopPraResetar
nop
FimLoopPraResetar:
li $t0, 0
li $t1, 0
sw $t0, TankIScore
sw $t1, TankIIScore
li $t2, 0
li $s2, 0
lui $s2, 0x1000
addi $s2, $s2, 0x8000
li $a0, 0
li $gp, 0
lui $gp, 0x8000
addi $gp, $gp, 0x8000
j InicioDoJogo
nop



###################################################################################################################
##################################### SCORE #######################################################################
###################################################################################################################
###################################################################################################################
###################################################################################################################


ResetaTela2:
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
li $t1, 0
li $t2, 0x000000
LoopPraResetar2:
sw $t2, 0($t0)
addi $t0, $t0, 0x4
addi $t1, $t1, 1
beq $t1, 16000, FimLoopPraResetar2
nop
j LoopPraResetar2
nop
FimLoopPraResetar2:
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
addi $t0, $t0, 0x8064
li $a0, 0xC0C0C0
sw $a0, 0x0($t0)
sw $a0, 0x8($t0)
sw $a0, 0x4($t0)
sw $a0 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0) # T
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x8($t0)
sw $a0, 0x604($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x808($t0) # H
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x404($t0) # N
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x408($t0)
sw $a0, 0x208($t0)
sw $a0, 0x8($t0) # K
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x4($t0)
sw $a0 0x8($t0)
sw $a0, 0x200($t0)
sw $a0 0x400($t0)
sw $a0 0x600($t0)
sw $a0 0x604($t0)
sw $a0 0x608($t0)
sw $a0 0x808($t0)
sw $a0 0xA08($t0)
sw $a0 0xA04($t0)
sw $a0 0xA00($t0)  # S
addi $t0, $t0, 0x10 # ESPAÇO
addi $t0, $t0, 0x10 
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0 0x8($t0)
sw $a0, 0x604($t0)
sw $a0, 0x608($t0) # F
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x808($t0)
sw $a0, 0x608($t0)
sw $a0, 0x408($t0)
sw $a0, 0x208($t0) # O
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA08($t0)   # R
addi $t0, $t0, 0x10
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)  # P
addi $t0, $t0, 0x10
sw $a0, 0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0xA04($t0)  
sw $a0, 0xA08($t0) # L
addi $t0, $t0, 0x10
sw $a0, 0x4($t0)
sw $a0, 0x200($t0)
sw $a0, 0x208($t0)
sw $a0 0x400($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x604($t0)
sw $a0, 0x600($t0)
sw $a0, 0x808($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # A
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x8($t0)
sw $a0, 0x204($t0)
sw $a0 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0) # Y
addi $t0, $t0, 0x10
sw $a0, 4($t0)
sw $a0 0x204($t0)
sw $a0, 0x404($t0)
sw $a0, 0x604($t0)
sw $a0, 0x804($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x8($t0)
sw $a0 0($t0)
sw $a0, 0xA08($t0)
sw $a0, 0xA00($t0) # I
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA00($t0)
sw $a0, 0x8($t0)
sw $a0 0x208($t0)
sw $a0, 0x408($t0)
sw $a0, 0x608($t0)
sw $a0, 0x808($t0)
sw $a0, 0xA08($t0)
sw $a0, 0x404($t0) # N
addi $t0, $t0, 0x10
sw $a0, 0x0($t0)
sw $a0, 0x4($t0)
sw $a0, 0x8($t0)
sw $a0, 0x200($t0)
sw $a0, 0x400($t0)
sw $a0 0x600($t0)
sw $a0, 0x800($t0)
sw $a0, 0xA04($t0)
sw $a0, 0x808($t0)
sw $a0, 0x404($t0)
sw $a0, 0x608($t0) # G
addi $t0, $t0, 0x10
sw $a0, -0x200($t0)
sw $a0, 0x0($t0)
sw $a0 0x200($t0)
sw $a0, 0x400($t0)
sw $a0, 0x600($t0)
sw $a0, 0xA00($t0) # !

jr $ra
nop
###########################################################################################
######################################################################################
######################################################################################
#####################################################
Pause:
	jal FlagPause
	nop
	li $v0, 12
	syscall
	nop
	move $s0, $v0
	beq $s0, 0x70, Despause
	nop
	j Pause
	nop
	

FlagPause:
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
addi $t0, $t0, 0x3E0
li $t1, 0
li $t2, 0xC0C0C0
sw $t2, 0($t0)
sw $t2, 4($t0)
sw $t2, 0x200($t0)
sw $t2, 0x204($t0)
sw $t2, 0x400($t0)
sw $t2, 0x404($t0)
sw $t2, 0x600($t0)
sw $t2, 0x604($t0)
sw $t2, 0x800($t0)
sw $t2, 0x804($t0)
sw $t2, 0xC($t0)
sw $t2, 0x10($t0)
sw $t2, 0x20C($t0)
sw $t2, 0x210($t0)
sw $t2, 0x40C($t0)
sw $t2, 0x410($t0)
sw $t2, 0x60C($t0)
sw $t2, 0x610($t0)
sw $t2, 0x80C($t0)
sw $t2, 0x810($t0)

jr $ra
nop


Despause:
li $t0, 0
lui $t0, 0x1000
addi $t0, $t0, 0x8000
addi $t0, $t0, 0x3E0
li $t1, 0
li $t2, 0x000000
sw $t2, 0($t0)
sw $t2, 4($t0)
sw $t2, 0x200($t0)
sw $t2, 0x204($t0)
sw $t2, 0x400($t0)
sw $t2, 0x404($t0)
sw $t2, 0x600($t0)
sw $t2, 0x604($t0)
sw $t2, 0x800($t0)
sw $t2, 0x804($t0)
sw $t2, 0xC($t0)
sw $t2, 0x10($t0)
sw $t2, 0x20C($t0)
sw $t2, 0x210($t0)
sw $t2, 0x40C($t0)
sw $t2, 0x410($t0)
sw $t2, 0x60C($t0)
sw $t2, 0x610($t0)
sw $t2, 0x80C($t0)
sw $t2, 0x810($t0)

j Main
nop


###############################################################################################
###############################################################################################
###############################################################################################
################ SINGLE PLAYER MODE  ##########################################################
###############################################################################################
###############################################################################################
SinglePlayer:
jal ClearGameOpening
nop
# ponta can0 s7 s3
move $s2, $gp #ponteiro tanque 2
	move $k1, $gp
jal Cenario3
nop
jal DrawZeroScore1
nop
jal X
nop
jal DrawZeroScore2
nop
jal Begin2
nop
jal Begin
nop

#jal Erase2
#nop



###########################

moveTank:
############################

li $s4, 0
li $k0, 0


li $a0, 0
li $a1, 11 # numero da casa q ele vai andar 
 li $v0, 42   #random
syscall
move $k0, $a0

li $a0, 0
li $a1, 4 # 0 up 1 down 2 right 3 left 
li $v0, 42   #random
syscall
#move $k1, $a0
sw $a0, flag
         
lw $t0, flag
beq $t0, 0, ffu #testa a direção 
nop
beq $t0, 1, ffd
nop
beq $t0, 2, ffr
nop
beq $t0, 3, ffl
nop

ffu:
     jal Erase2
     nop
     jal UpTank2 #tanque é virado para direção gerada 
     nop
     j fu # e logo em seguida é feito uma verificação de objetos a frente pra ver se atira
     nop
     

ffd: 
     nop
     jal Erase2
     nop
     jal DownTank2
     nop
     j fd
     nop
  
ffr: 
     jal Erase2
     nop
     jal RightTank2
     nop
     j fr
     nop
   
ffl: 
     jal Erase2
     nop
     jal LeftTank2
     nop
     j fl
     nop
                           
continue: lw $t0, flag
beq $t0, 0, moveUp
nop
beq $t0, 1, moveDown
nop
beq $t0, 2, moveRight
nop     
j moveLeft     
nop     
     
moveUp: beq $k0, -1, moveTank
	nop
	jal Verifica2S
	nop
	beq $s4, 1, moveTank
	nop
	jal Verifica2S
	nop
	beq $s4, 1, moveTank
	nop
	jal Erase2
	nop
	add $s2, $s2, -0x200 
	jal UpTank2
	nop   
	subi $k0, $k0, 1
	li $t9, 0
	#j moveUp
	atrasoup: beq $t9, 1200, moveUp
		  nop
		  addi $t9, $t9, 1
		  j atrasoup   
		  nop
	nop

moveDown: beq $k0, -1, moveTank
	nop
	jal Verifica2S
	nop
	beq $s4, 1, moveTank
	nop
	jal Verifica2S
	nop
	beq $s4, 1, moveTank
	nop
	jal Erase2
	nop
	add $s2, $s2, 0x200 
	jal DownTank2
	nop   
	subi $k0, $k0, 1
	atrasodown: beq $t9, 1200, moveDown
		  nop
		  addi $t9, $t9, 1
		  j atrasodown
		  nop

moveRight: beq $k0, -1, moveTank
	nop
	jal Verifica2S
	nop
	beq $s4, 1, moveTank
	nop
	jal Verifica2S
	nop
	beq $s4, 1, moveTank
	nop
	jal Erase2
	nop
	add $s2, $s2, 0x4 
	jal RightTank2
	nop   
	subi $k0, $k0, 1
	atrasoright: beq $t9, 1200, moveRight
		  nop
		  addi $t9, $t9, 1
		  j atrasoright
		  nop
	
moveLeft: beq $k0, -1, moveTank
	nop
	jal Verifica2S
	nop
	beq $s4, 1, moveTank
	nop
	jal Verifica2S
	nop
	beq $s4, 1, moveTank
	nop
	jal Erase2
	nop
	add $s2, $s2, -0x4 
	jal LeftTank2
	nop   
	subi $k0, $k0, 1
	atrasoleft: beq $t9, 1200, moveLeft
		  nop
		  addi $t9, $t9, 1
		  j atrasoleft
		  nop															
				
fu: move $t1, $s3 
  wncu: lw $t2, 0($t1)
       bne $t2, 0x000000, vfu #se encontrou algo diferente dos objetos
       nop
       addi $t1,$t1, -0x200     				
       j wncu
       nop
  vfu: beq $t2, 0x0000FF, shootu #se encontrou o adversário pula pro metodo que faz atirar 
       nop
        j moveTank1   #se nao eh lido o movimento do playerI
     nop
     continueffu:
       j continue
       nop
       shootu: jal ShootUp2
  	  nop
  	  #j moveTank
  	   j moveTank1   
     nop
     #continueffu:       			
	  j continue 
	  nop
	  
fd: move $t1, $s3
  wncd: lw $t2, 0($t1)
       bne $t2, 0x000000, vfd
       nop
       addi $t1,$t1, 0x200     				
       j wncd
       nop
  vfd: beq $t2, 0x0000FF, shootd
       nop
        j moveTank1   
     nop
     continueffd:
       j continue
       nop
       shootd: jal ShootDown2
  	  nop
  	  #j moveTank	
  	   j moveTank1   
     nop
    # continueffd:							
	  j continue 
	  nop
	  
fr: move $t1, $s3
  wncr: lw $t2, 0($t1)
       bne $t2, 0x000000, vfr
       nop
       addi $t1,$t1, 0x4     				
       j wncr
       nop
  vfr: beq $t2, 0x0000FF, shootr
       nop
        j moveTank1   
     nop
     continueffr:
       j continue
       nop
       shootr: jal ShootRight2
  	  nop
  	  #j moveTank
  	   j moveTank1   
     nop
    # continueffr:
    	  j continue 
    	  nop
    	  
fl: move $t1, $s3
  wncl: lw $t2, 0($t1)
       bne $t2, 0x000000, vfl
       nop
       addi $t1,$t1, -0x4    				
       j wncl
       nop
  vfl: beq $t2, 0x0000FF, shootl
       nop
        j moveTank1   
     nop
     continueffl:
       j continue
       nop          
  shootl: jal ShootLeft2
  	  nop
  	  #j moveTank     
  	   j moveTank1   
     nop
     #continueffl:
  	  j continue 
  	  nop


###################################################################################################################################

####################################################################################################################################
#######				DETECTOR DE COLISAO
#################################################################################################################################

#################       								
#################
######
#################
#################
######
#################
#################


Verifica2S:   li $t1, 0
	    li $t2, 0
   	    li $t3, 0
	    li $t4, 0
	    li $t5, 0
	    li $t6, 0
	    li $t7, 0
   	    li $t8, 0
	    li $t9, 0
	 
	    beq $a3, 0x69, VerUp2S    
	     nop
	     beq $a3, 0x6b, VerDown2S  
		nop
		beq $a3, 0x6a, VerLeft2S   
		  nop
		  beq $a3, 0x6c, VerRight2S  
		  nop
		  j Fim2
		  nop
		  
	 VerUp2S:#subi $s3, $s3, 512 
	 	subi $s3, $s3, 512
	 	subi $t1, $s3, 4 # LADO ESQUERDO CANO
	 	addi $t2, $s3, 4 # LADO DIREITO CANO 
	 	subi $t3, $s3, 8 
	 	addi $t4, $s3, 8  
	
	 	lw $t5, 0($s3)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag2S
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag2S
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag2S
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag2S
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag2S
	 	   	  nop
	       j Fim2S
	       nop
	       
       VerDown2S: addi $s3, $s3, 512
	 	subi $t1, $s3, 4 # LADO ESQUERDO CANO
	 	addi $t2, $s3, 4 # LADO DIREITO CANO 
	 	subi $t3, $s3, 8 
	 	addi $t4, $s3, 8  
	
	 	lw $t5, 0($s3)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag2S
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag2S
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag2S
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag2S
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag2S
	 	   	  nop
	       j Fim2S
	       nop
	  
      VerRight2S: #addi $s3, $s3, 4
	 	subi $t1, $s3, 512 # LADO ESQUERDO CANO
	 	addi $t2, $s3, 512 # LADO DIREITO CANO 
	 	subi $t3, $s3, 1024 
	 	addi $t4, $s3, 1024  
	
	 	lw $t5, 0($s3)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag2S
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag2S
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag2S
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag2S
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag2S
	 	   	  nop
	       j Fim2S
	       nop
	       
       VerLeft2S: subi $s3, $s3, 4
	 	subi $t1, $s3, 512 # LADO ESQUERDO CANO
	 	addi $t2, $s3, 512 # LADO DIREITO CANO 
	 	subi $t3, $s3, 1024 
	 	addi $t4, $s3, 1024  
	
	 	lw $t5, 0($s3)
	 	lw $t6, 0($t1)
	 	lw $t7, 0($t2)
	 	lw $t8, 0($t3)
	 	lw $t9, 0($t4)
	 	
	 	beq $t5, 0xC0C0C0, SetFlag2S
	 	  nop
	 	  beq $t6, 0xC0C0C0, SetFlag2S
	 	    nop
	 	    beq $t7, 0xC0C0C0, SetFlag2S
	 	       nop
	 	       beq $t8, 0xC0C0C0, SetFlag2S
	 	    	  nop
	 	    	  beq $t9, 0xC0C0C0, SetFlag2S
	 	   	  nop
	       j Fim2S
	       nop
	           
	   Fim2S:    jr $ra
	           nop
	  SetFlag2S: li $s4, 1
	  	   jr $ra
	           nop
	           
	
MainS:
		li $s6, 0 # seta a flag que indica se ha um objeto a frente 
		beq $s0, 0x77, UpS    # 0x77 = w na tabela ascii
		nop
		beq $s0, 0x73, DownS  #  0x73 = s na tabela ascii
		nop
		beq $s0, 0x61, LeftS   #  0x61 = a na tabela ascii
		nop
		beq $s0, 0x64, RightS  #  0x64 = d na tabela ascii
		nop
		beq $s0, 0x62, BangBangS #b
		nop
		beq $s0, 0x70, PauseS # p
		nop
		beq $s0, 0x65, End 
		nop
		j MainS
		nop
		
		BangBangS:
			beq $s5, 1, isRightS
			nop
			beq $s5, 2, isLeftS
			nop
			beq $s5, 3, isUpS
			nop
			beq $s5, 4, isDownS
			nop
			
			isRightS: jal ShootRight
				 nop
				 j endBangS
				 nop
		       isLeftS: jal ShootLeft
				 nop
				 j endBangS
				 nop
		       isUpS: jal ShootUp
				 nop
				 j endBangS
				 nop
		       isDownS: jal ShootDown
				 nop
				 j endBangS
				 nop
			endBangS: #li $s5, 0
				 #j Main
			         lw $t0, flag
			         beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
		
		
		
		UpS:
			jal Erase # apaga o tanque para reescrevelo
			nop
			beq $v1, 0x77, AddUpS # pula se a última ação ($v1) também tiver sido uptank
			nop
			jal UpTank  # se o tanque NÃO estiver virado pra cima então será virado
			nop
			#j Main
			lw $t0, flag
			beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
			AddUpS:
				jal Verifica
				nop
				beq $s6, 1, UpContinueS
				nop
				j nextUpS
				nop
				UpContinueS: jal UpTank
					    nop
					    #j Main
					    lw $t0, flag
					    beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
				nextUpS:	    
				add $gp, $gp, -0x200  # se o tanque já estiver pra cima, subirá uma linha  
				jal UpTank
				nop
				#j Main
				lw $t0, flag
				beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop


		DownS:
			jal Erase
			nop
			beq $v1, 0x73, AddDownS # pula se a última ação ($v1) também tiver sido downtank
			jal DownTank
			nop
			#j Main
			lw $t0, flag
			beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
			AddDownS:
				jal Verifica
				nop
				beq $s6, 1, DownContinueS
				nop
				j nextDownS
				nop
			      DownContinueS: jal DownTank
					    nop
					    #j Main
					    lw $t0, flag
					    beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
				nextDownS:
				add $gp, $gp, 0x200 # desce uma linha
				jal DownTank
				nop
				#j Main
				lw $t0, flag
				beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
		
		
		LeftS:
			jal Erase
			nop
			beq $v1, 0x61, AddLeftS
			jal LeftTank
			nop
			#j Main
			lw $t0, flag
			beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
			AddLeftS:
				jal Verifica
				nop
				beq $s6, 1, LeftContinueS
				nop
				j nextLeftS
				nop
			      LeftContinueS: jal LeftTank
					    nop
					    #j Main
					    lw $t0, flag
					    beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
				nextLeftS:
				add $gp, $gp, -0x4 # anda uma coluna à esquerda
				jal LeftTank
				nop
				#j Main
				lw $t0, flag
				beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop


		RightS:
			jal Erase
			nop
			beq $v1, 0x64, AddRightS
			jal RightTank
			nop
			#j Main
			lw $t0, flag
			beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
			AddRightS:
				jal Verifica
				nop
				beq $s6, 1, RightContinueS
				nop
				j nextRightS
				nop
			      RightContinueS: jal RightTank
					    nop
					    #j Main
					    lw $t0, flag
					    beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
				nextRightS:	    
				add $gp, $gp, 0x4 # uma coluna à direita
				jal RightTank
				nop
				#j Main
				lw $t0, flag
				beq $t0, 0, continueffu	
				nop	
				beq $t0, 1, continueffd
				nop
				beq $t0, 2, continueffr
				nop
				beq $t0, 3, continueffl
				nop
	        
	        
		
	           
PauseS:
	jal FlagPause
	nop
	li $v0, 12
	syscall
	nop
	move $s0, $v0
	beq $s0, 0x70, MainS
	nop
	j PauseS
	nop	
	
   		           		
moveTank1:
li $t0, 0xffff0004
ler: lw $t2, 0($t0)
beq $t2, $zero, ler
nop
#li $v0, 10
#syscall
move $s0, $t2
j MainS 
nop



