#INCLUDE'TOTVS.CH'
#INCLUDE'TBICONN.CH'

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
//	In�cio do Template com apresenta��o da Tela Inicial
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
	//Dimens�es da janela
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
	Local bOk		:= { || lOk := .T., oDlg:End() }

	Private aIteTok := {";",","}
	Private oSayArq, oGetArq, cGetArq := Space(99)
	Private oSayTab, oCmbTab, cCmbTab := ""
	Private oSayTok, oCmbTok, cCmbTok := ';'
	Private oDlgOpc	
	
	//cCmbTok := aIteTok[1]

	DEFINE MSDIALOG oDlgOpc TITLE "Importador de Dados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        
        //Grupo A��es
		@ 003, 003 	GROUP oGrpOpc TO nAltPosI, nLarPosI PROMPT "A��es: " OF oDlgOpc COLOR 0, 16777215 PIXEL
		
			//Bot�es
			@ (nAltPosI)-20, (nLarPosI)-(64*1)  BUTTON oBtnSair PROMPT "Sair"       SIZE 60, 014 OF oDlgOpc ACTION (oDlgOpc:End()) PIXEL
			@ (nAltPosI)-20, (nLarPosI)-(64*2)  BUTTON oBtnImp  PROMPT "Importar"   SIZE 60, 014 OF oDlgOpc ACTION (Processa({|| dtImporta(), bOk}, "Aguarde...","Executando Rotina dtImporta")) PIXEL
			@ (nAltPosI)-20, (nLarPosI)-(64*3)  BUTTON oBtnLay  PROMPT "LayOut"     SIZE 60, 014 OF oDlgOpc ACTION (Processa({|| dtLayOut(), bOk}, "Aguarde...","Executando Rotina dtLayOut")) PIXEL
	ACTIVATE MSDIALOG oDlgOpc CENTERED
	
	RestArea(aArea)

Return
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	GERA��O DE LAYOUT
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
  
   aAdd(aParamBox,{1,"Tabela",Space(5),"@!","","SX2PAD","",6,.T.})
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
	//Local oOk      	:= LoadBitmap( GetResources(), "LBOK")
	//Local oNo      	:= LoadBitmap( GetResources(), "LBNO")	
	Local nSX3 := 1
	Local nLay := 1
	Local oBtn1, oBtn2, oDlg
	Local oFont := TFont():New('Courier new',,-18,.T.)
	Private oSX3, oLay		

	DEFINE MsDialog oDlg Title "Selecione os Campos" From 000,000 To 200,250 PIXEL //Of oMainWnd Style 128
	oDlg:lEscClose := .F.
		
	//@ 116,008 ListBox oSX3 Var cVarQ Fields Header "Obrig.","Campo","T�tulo" ColSizes 30,50,300 Size 124,112 Of oDlg Pixel
	@ 001,008 ListBox oSX3 Fields Header "Campos" ColSizes 30,50 Size 124,112 Of oDlg Pixel
	//@ 116,008 ListBox oSX3 Var cVarQ ITEMS aCampoSX3 SIZE 124,112 Of oDlg Pixel
	//@ 116,196 ListBox oLay Var cVarQ ITEMS aCampoLay Size 124,112 Of oDlg Pixel
	//@ 116,196 ListBox oLay Var cVarQ Fields Header "Obrig.","Campo","T�tulo" ColSizes 30,50,300 Size 124,112 Of oDlg Pixel
	oSX3 := TListBox ():New(006, 008,{|u|if(Pcount()>0,nSX3:=u,nSX3)},aCampoSX3,124, 112,,oDlg,,,,.T.)
    oLay := TListBox ():New(006, 130,{|u|if(Pcount()>0,nLay:=u,nLay)},aCampoLay,124, 112,,oDlg,,,,.T.)

	oSX3:SetArray(aCampoSX3)

    //oSX3:bLine 	:= {|| aDados[nAt]}
		
	//oSX3:bLine 	:= {|| {/*iif*/(aCampoSX3[oSX3:nAt,01],oOk,oNo)/*,aCampoSX3[oSX3:nAt,02],aCampoSX3[oSX3:nAt,03]*/} }
	//oSX3:bLine 	:= {|| {(aCampoSX3[oSX3:nAt,01],oOk,oNo),aCampoSX3[oSX3:nAt,02],aCampoSX3[oSX3:nAt,03]} }
	//oSX3:bChange 	:= {|| cItem := aCampoSX3[nAt,02],aCampoSX3[oSX3:nAt,03]} }

	//oResp:bLDblClick:= { || aCampos[oResp:nAt,1] := !aCampos[oResp:nAt,1] }

	//@ 152/*(nAltPosI)-20*/,144/* (nLarPosI)-(64*2)*/  BUTTON oBtn4 PROMPT ">>>" SIZE 041, 012 OF oDlg ACTION ({|| dtAdd(aCampoSX3[oSX3:nAt])}) PIXEL
	@ 052,125 BUTTON oBtn1 PROMPT ">>>" SIZE 041, 012 OF oDlg ACTION ({|| dtAdd(aCampoSX3[oSX3:nAt])}) PIXEL
	@ 076,125 BUTTON oBtn2 PROMPT "<<<" SIZE 041, 012 OF oDlg ACTION ({|| dtBack(aCampoLay[oLay:nAt])}) PIXEL
	//@ 176/*(nAltPosI)-20*/,144/* (nLarPosI)-(64*2)*/  BUTTON oBtn5 PROMPT "<<<" SIZE 041, 012 OF oDlg ACTION ({|| dtBack(aCampoLay[oLay:nAt])}) PIXEL
    
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
//	IMPORTA��O DO ARQUIVO
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
	//Dimens�es da janela
	Local nJanAltu := 180
	Local nJanLarg := 650
	//Posicionamento Inicial na Janela
	Local nAltPosI := nJanAltu/2
	Local nLarPosI := nJanLarg/2
	//Objetos da tela
	Local oGrpPar, oGrpAco, oBtnSair, oBtnImp, oBtnArq
	
	Private oDlgTin
		
	DEFINE MSDIALOG oDlgTin TITLE "Importador" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Grupo Par�metros
		@ 003, 003 	GROUP oGrpPar TO 060, (nLarPosI) 	PROMPT "Par�metros: " 		OF oDlgTin COLOR 0, 16777215 PIXEL
			//Caminho do arquivo
			@ 013, 006 SAY        oSayArq PROMPT "Arquivo:"              SIZE 060, 007 OF oDlgTin PIXEL
			@ 010, 070 MSGET      oGetArq VAR    cGetArq                 SIZE 240, 010 OF oDlgTin PIXEL
			@ 010, 311 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oDlgTin ACTION (dtPegArq()) PIXEL
									
			//Caracter de Separa��o do CSV
			@ 043, 006 SAY        oSayTok PROMPT "Separador:"            SIZE 060, 007 OF oDlgTin PIXEL
			@ 040, 070 MSCOMBOBOX oCmbTok VAR    cCmbTok ITEMS aIteTok   SIZE 030, 010 OF oDlgTin PIXEL
			
		//Grupo A��es
		@ 063, 003 	GROUP oGrpAco TO nAltPosI-3, nLarPosI 	PROMPT "A��es: " 		OF oDlgTin COLOR 0, 16777215 PIXEL
		
			//Bot�es
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
