#INCLUDE'TOTVS.CH'

User Function dTestaTela()
    Local bInit := {|| }
    //Fontes
    Local cFontPad    := "Tahoma"
    Local oFontBtn    := TFont():New(cFontPad, , -14)
    //Objetos
    Local oDlgPulo
    Local oBtnOK
    //Tamanho da janela
    Local nJanLarg := 400
    Local nJanAltu := 200
    Local nColMeio := (nJanLarg / 2) / 2 // Primeiro dividimos a largura por 2, para termos o tamanho interno da dialog, ai dividimos por 2 novamente para descobrir o meio - ex.: 100 pixels
    Local nLinMeio := (nJanAltu / 2) / 2 // Mesmo caso de acima
     
    //Cria a janela
    oDlgPulo := TDialog():New(0, 0, nJanAltu, nJanLarg, 'Pulo do Gato em Dialogs - Exemplo 2', , , , , CLR_BLACK, RGB(250, 250, 250), , , .T.)
 
        //Como a largura do botão é 60 e a altura é 18, iremos pegar a coluna do meio menos 30 e a linha do meio menos 9
        oBtnOK := TButton():New(nLinMeio - 9, nColMeio - 30, "Botão Centro", oDlgPulo, {|| Alert("teste")}, 060, 018, , oFontBtn, , .T., , , , , , )
 
    //Ativa e exibe a janela
    oDlgPulo:Activate(, , , .T., {|| .T.}, , bInit )
Return
