#INCLUDE'TOTVS.CH'
#INCLUDE'TBICONN.CH'

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
//	Início do Template com apresentação da Tela Inicial
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//===================================================================================================================================================
/*/{Protheus.doc} dtLayOut
	(long_description)
	@type  Static Function
	@author C2D
	@since 28/06/2023
*/
User Function dtTela()	
//===================================================================================================================================================
	
	Local aArea := GetArea()
	//Dimensões da janela
	Local nJanAltu := 80
	Local nJanLarg := 400
	//Posicionamento inicial dos objetos na janela
	Local nAltPosI := nJanAltu/2
	Local nLarPosI := nJanLarg/2
	//Objetos da tela
	Local oGrpOpc
	Local oBtnSair
	Local oBtnImp
	Local oBtnLay

	Private aIteTok := {";",","}
	Private oSayArq, oGetArq, cGetArq := Space(99)
	Private oSayTab, oCmbTab, cCmbTab := ""
	Private oSayTok, oCmbTok, cCmbTok := ';'
	Private oDlgOpc	
	
	//cCmbTok := aIteTok[1]

	DEFINE MSDIALOG oDlgOpc TITLE "Importador de Dados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        
        //Grupo Ações
		@ 003, 003 	GROUP oGrpOpc TO nAltPosI, nLarPosI PROMPT "Ações: " OF oDlgOpc COLOR 0, 16777215 PIXEL
		
			//Botões
			@ (nAltPosI)-20, (nLarPosI)-(64*1)  BUTTON oBtnSair PROMPT "Sair"       SIZE 60, 014 OF oDlgOpc ACTION (oDlgOpc:End()) PIXEL
			@ (nAltPosI)-20, (nLarPosI)-(64*2)  BUTTON oBtnImp  PROMPT "Importar"   SIZE 60, 014 OF oDlgOpc ACTION (Processa({|| dtImporta()}, "Aguarde...","Executando Rotina dtImporta")) PIXEL
			@ (nAltPosI)-20, (nLarPosI)-(64*3)  BUTTON oBtnLay  PROMPT "LayOut"     SIZE 60, 014 OF oDlgOpc ACTION (Processa({|| dtLayOut()}, "Aguarde...","Executando Rotina dtLayOut")) PIXEL
	ACTIVATE MSDIALOG oDlgOpc CENTERED
	
	RestArea(aArea)

Return
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	GERAÇÃO DE LAYOUT
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//===================================================================================================================================================
/*/{Protheus.doc} dtLayOut
	(long_description)
	@type  Static Function
	@author C2D
	@since 28/06/2023
*/
Static Function dtLayOut()	
//===================================================================================================================================================
		
	Local aArea 		:= GetArea()	
	Local aObrigatorio	:= {}
    Local cAliasTp		:= GetNextAlias()
	Local cCampo		:= "((cAliasTp)->X3_CAMPO)"
	Local i := 0
	Local cTabela   := ""
	Private aCampoSX3 := {}
	Private aCampoLay := {}
	Private aParamBox := {}
	
PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'
  
   aAdd(aParamBox,{1,"Tabela",Space(5),"@!","","","",6,.T.})
    If ParamBox(aParamBox,"Gerador de LayOut",,,,,,,,"NovosProdutos",.F.,.T.)
        cTabela := Alltrim(MV_PAR01)
	EndIf

/*	OpenSXs(//,//,//,//,"01",cAliasTp,"SX3",//,.F.)
    (cAliasTp)->(DbSetFilter({|| &(cTabela)}, cTabela))
    (cAliasTp)->(DbGoTop())*/
	 aCampos := FwSx3Util():GetAllFields(cTabela)
          
    //While !(cAliasTp)->(Eof())
    For i := 1 to Len(aCampos)   
        If X3Obrigat((aCampos[i])) == .T.
            aAdd(aObrigatorio,Alltrim((aCampos[i])))
        Else
            aAdd(aCampoSX3,Alltrim((aCampos[i])))                                                      
        EndIf
     
    //(cAliasTp)->(dbSkip())
    Next

    cCampos := ArrTokStr(aCampoSX3,"|")
    cObrigatorio := ArrTokStr(aObrigatorio,"|")
    MsgInfo(cCampos + CRLF + cObrigatorio, "Campos")
    
RESET ENVIRONMENT

    RestArea(aArea)

	dtSelCamp()

Return

//===================================================================================================================================================
/*/{Protheus.doc} dtLayOut
	(long_description)
	@type  Static Function
	@author C2D
	@since 28/06/2023
*/
Static Function dtSelCamp()
//===================================================================================================================================================
			
	//Local lOk		:= .F.
	//Local bOk		:= { || lOk := .T., oDlg:End() }
	//Local bCancel 	:= { || oDlg:End()}	
	Local oOk      	:= LoadBitmap( GetResources(), "LBOK")
	Local oNo      	:= LoadBitmap( GetResources(), "LBNO")	
	Local oBtn4, oBtn5, oDlg
	Local oFont := TFont():New('Courier new',,-18,.T.)
	Private oSX3, oLay		

	DEFINE MsDialog oDlg Title "Selecione os Campos" From 000,000 To 220,500 Of oMainWnd Style 128
	oDlg:lEscClose := .F.
		
	@ 116,008 ListBox oSX3 Var cVarQ Fields Header "Obrig.","Campo","Título" ColSizes 30,50,300 Size 124,112 Of oDlg Pixel
	@ 116,196 ListBox oLayout Var cVarQ Fields Header "Obrig.","Campo","Título" ColSizes 30,50,300 Size 124,112 Of oDlg Pixel
	
	oSX3:SetArray(aCampoSX3)
		
	oSX3:bLine 	:= {|| {/*iif*/(aCampoSX3[oSX3:nAt,01],oOk,oNo)/*,aCampoSX3[oSX3:nAt,02],aCampoSX3[oSX3:nAt,03]*/} }

	//oResp:bLDblClick:= { || aCampos[oResp:nAt,1] := !aCampos[oResp:nAt,1] }

	@ 152/*(nAltPosI)-20*/,144/* (nLarPosI)-(64*2)*/  BUTTON oBtn4 PROMPT ">>>" SIZE 041, 012 OF oDlg ACTION ({|| dtAdd(aCampoSX3[oSX3:nAt])}) PIXEL
	@ 176/*(nAltPosI)-20*/,144/* (nLarPosI)-(64*2)*/  BUTTON oBtn5 PROMPT "<<<" SIZE 041, 012 OF oDlg ACTION ({|| dtBack(aCampoLay[oLay:nAt])}) PIXEL
    
    oSay1:= TSay():New( 100,196,{||"Campos do Layout:"},oDlg,,oFont,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,012)
	
	Activate MsDialog oDlg Centered //On Init EnchoiceBar(oDlg,bOk,bCancel,,@aButtons)
	
Return .T.
//===================================================================================================================================================
/*/{Protheus.doc} dtLayOut
	(long_description)
	@type  Static Function
	@author C2D
	@since 28/06/2023
*/
Static Function dtAdd(cItem)
//===================================================================================================================================================

     oListBox2:Add( cItem, 0 )
     oListBox2:Refresh()

     oListBox1: Del( oSX3:nAt )
     oListBox1:Refresh()

Return

//===================================================================================================================================================
/*/{Protheus.doc} dtLayOut
	(long_description)
	@type  Static Function
	@author C2D
	@since 28/06/2023
*/
Static Function dtBack(cItem)
//===================================================================================================================================================

     oListBox1:Add( cItem, 0 )
     oListBox1:Refresh()

     oListBox2: Del( oLay:nAt )
     oListBox2:Refresh()

Return	

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	IMPORTAÇÃO DO ARQUIVO
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//===================================================================================================================================================
/*/{Protheus.doc} dtLayOut
	(long_description)
	@type  Static Function
	@author C2D
	@since 28/06/2023
*/
Static Function dtImporta()
//===================================================================================================================================================

	Local aArea := GetArea()
	//Dimensões da janela
	Local nJanAltu := 180
	Local nJanLarg := 650
	//Posicionamento Inicial na Janela
	Local nAltPosI := nJanAltu/2
	Local nLarPosI := nJanLarg/2
	//Objetos da tela
	Local oGrpPar, oGrpAco, oBtnSair, oBtnImp, oBtnArq
	
	Private oDlgTin
		
	DEFINE MSDIALOG oDlgTin TITLE "Importador" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Grupo Parâmetros
		@ 003, 003 	GROUP oGrpPar TO 060, (nLarPosI) 	PROMPT "Parâmetros: " 		OF oDlgTin COLOR 0, 16777215 PIXEL
			//Caminho do arquivo
			@ 013, 006 SAY        oSayArq PROMPT "Arquivo:"              SIZE 060, 007 OF oDlgTin PIXEL
			@ 010, 070 MSGET      oGetArq VAR    cGetArq                 SIZE 240, 010 OF oDlgTin PIXEL
			@ 010, 311 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oDlgTin ACTION (dtPegArq()) PIXEL
									
			//Caracter de Separação do CSV
			@ 043, 006 SAY        oSayTok PROMPT "Separador:"            SIZE 060, 007 OF oDlgTin PIXEL
			@ 040, 070 MSCOMBOBOX oCmbTok VAR    cCmbTok ITEMS aIteTok   SIZE 030, 010 OF oDlgTin PIXEL
			
		//Grupo Ações
		@ 063, 003 	GROUP oGrpAco TO nAltPosI-3, nLarPosI 	PROMPT "Ações: " 		OF oDlgTin COLOR 0, 16777215 PIXEL
		
			//Botões
			@ 070, (nLarPosI)-(63*1)  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlgTin ACTION (oDlgTin:End()) PIXEL
			@ 070, (nLarPosI)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"  SIZE 60, 014 OF oDlgTin ACTION (Processa({|| dtLeCSV()}, "Aguarde...")) PIXEL
			
	ACTIVATE MSDIALOG oDlgTin CENTERED
	
	RestArea(aArea)
Return

//===================================================================================================================================================
/*/{Protheus.doc} dtLayOut
	(long_description)
	@type  Static Function
	@author C2D
	@since 28/06/2023
*/
Static Function dtPegArq()
//===================================================================================================================================================

	Local cArq := ""
	
	cArq := cGetFile( "Arquivo | *.*","Arquivo LayOut ",0,,.F.,GETF_LOCALHARD,.F.)					
	cGetArq := PadR(cArq, 99)
	
Return cGetArq

//===================================================================================================================================================
/*/{Protheus.doc} dtLayOut
	(long_description)
	@type  Static Function
	@author C2D
	@since 28/06/2023
*/
Static Function dtLeCSV()
//===================================================================================================================================================
    
    Local cLinha    := ''        
    Local aArea     := GetArea()        
   // Local cAliasTp  := GetNextAlias()
    //Local cFiltro   := "X3_ARQUIVO == 'SB1'"    
    Local oArq      := FwFileReader():New(cGetArq)

    Private aCabec  	:= {}
    Private aLinha  	:= {}
    Private aCampos 	:= {}
	Private aRegistro 	:= {}   
    Private cB1cod  	:= ''
    Private cB1desc 	:= ''
    Private cB1tipo 	:= ''
    Private cB1um   	:= ''
    Private nB1prv  	:= 0   

//*PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'
    
//    OpenSXs(/**/,/**/,/**/,/**/,"01",cAliasTp,"SX3",/**/,.F.)
    
//    (cAliasTp)->(DbSetFilter({|| &(cFiltro)}, cFiltro))
//    (cAliasTp)->(DbGoTop())   
   
    //aCampoSX3 := FwSx3Util():GetAllFields("SB1")
    
    If oArq:Open()
        If !oArq:EOF()
            While (oArq:HasLine())
                cLinha := oArq:GetLine()
                If ('COD' $ UPPER(cLinha))
                    aCampos:= StrTokArr(cLinha, cCmbTok)                   
				Else
					aRegistro := StrTokArr(cLinha, cCmbTok)
				EndIf                                              						 
				If !Vazio(aCampos) .and. !Vazio(aRegistro)
					dtImpCSV()
				EndIf	
			EndDo			
        EndIf    
        oArq:Close()
    EndIf	
    
	RestArea(aArea)

Reset Environment

Return 

/*{Protheus.doc} dtImpCSV
    @type  Function
    @author Daniele Travessa
    @since 08/05/2023 */
    
Static Function dtImpCSV()

    Local aDados        := {}
    //Local nOper         := 3
    Local n := 0
    //Private lMsErroAuto := .F.

    //PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'EST'

   // aAdd(aDados, {'B1_FILIAL', xFilial('SB1') ,''})
	
    	For n := 1 to Len(aCampos)//aCabec
        	aAdd(aDados, {aCampos[n], aRegistro[n],''})        
    	Next

    Alert(ArrTokStr(aDados))
    
    //MsExecAuto({|x, y| MATA010(x, y), aDados, nOper})

   // If lMsErroAuto
        //MostraErro()
    //EndIf

Return 
