1. Introdução
Jogo inspirado no Tank Game Mode de Combat da Atari, disponível em SingePlayer
e MultiPlayer.
2. Especificações de uso
Unit Width in Pixels: 4;
Unit Height in Pixels: 4;
Display Width in Pixels: 512;
Display Height in Pixels: 512;
Base address for display: 0x10008000 ($gp);
Keyboard and Display MMIO Simulator;
Tanque 1: A, W, S, D, B;
Tanque 2: J, I, K, L, M;
Pause: P;
End: E;
3. Especificações dos Métodos de Criação
3.1. Menus, Cenário e demais Objetos
São plotados no bitmap ao decorrer do jogo através de store words
contendo cores;
3.2. Tanques, Placar e Tiro
São plotados da mesma forma que os menus e cenários, com a diferença de
utilizar cores diferentes, a fim de melhorar a identificação no tratamento de
exceções;
3.3. Exceções
3.3.1. Colisão
Através de uma flag apontando para a ponta do tanque, desprezando
sua posição, é calculado o valor da próxima posição de memória, e esta é
comparada à cor dos objetos para definir se o movimento é válido ;3.3.2. Tiro
É utilizado um contador delay para simular movimento. É calculado
sempre uma posição à frente da "bala" e seu conteúdo é tratado em casos de
colisão;
4. Alguns Erros
Em alguns momentos do jogo, quando o tanque passa ao lado de algum objeto,
mesmo sem encostar, acaba "engolindo" uma parte dele;
Mode de jogo singleplayer foi desenvolvido para teste, sem muita pretensão, e
acaba, por esse motivo, tendo alguns e
