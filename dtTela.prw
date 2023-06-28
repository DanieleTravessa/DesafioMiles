#INCLUDE'TOTVS.CH'
#INCLUDE'TBICONN.CH'

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
  User Function dtTela()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
	
	cCmbTok := aIteTok[1]

	DEFINE MSDIALOG oDlgOpc TITLE "Importador de Dados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        
        //Grupo Ações
		@ 003, 003 	GROUP oGrpOpc TO nAltPosI, nLarPosI PROMPT "Ações: " OF oDlgOpc COLOR 0, 16777215 PIXEL
		
			//Botões
			@ (nAltPosI)-20, (nLarPosI)-(64*1)  BUTTON oBtnSair PROMPT "Sair"       SIZE 60, 014 OF oDlgOpc ACTION (oDlgOpc:End()) PIXEL
			@ (nAltPosI)-20, (nLarPosI)-(64*2)  BUTTON oBtnImp  PROMPT "Importar"   SIZE 60, 014 OF oDlgOpc ACTION (Processa({|| dtImporta(), oDlgOpc:End()}, "Aguarde...")) PIXEL
			@ (nAltPosI)-20, (nLarPosI)-(64*3)  BUTTON oBtnLay  PROMPT "LayOut"     SIZE 60, 014 OF oDlgOpc ACTION (Processa({|| dtLayOut(), oDlgOpc:End()}, "Aguarde...")) PIXEL
	ACTIVATE MSDIALOG oDlgOpc CENTERED
	
	RestArea(aArea)

Return

Static Function dtImporta()

	Local aArea := GetArea()
	//Dimensões da janela
	Local nJanAltu := 180
	Local nJanLarg := 650
	//Posicionamento Inicial na Janela
	Local nAltPosI := nJanAltu/2
	Local nLarPosI := nJanLarg/2
	//Objetos da tela
	Local oGrpPar
	Local oGrpAco
	Local oBtnSair
	Local oBtnImp	
	Local oBtnArq
	
	Private oDlgTin
		
	DEFINE MSDIALOG oDlgTin TITLE "Importador" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Grupo Parâmetros
		@ 003, 003 	GROUP oGrpPar TO 060, (nLarPosI) 	PROMPT "Parâmetros: " 		OF oDlgTin COLOR 0, 16777215 PIXEL
			//Caminho do arquivo
			@ 013, 006 SAY        oSayArq PROMPT "Arquivo:"                  SIZE 060, 007 OF oDlgTin PIXEL
			@ 010, 070 MSGET      oGetArq VAR    cGetArq                     SIZE 240, 010 OF oDlgTin PIXEL
			oGetArq:bHelp := {||	ShowHelpCpo(	"cGetArq",;
									{"Arquivo CSV ou TXT que será importado."+STR_PULA+"Exemplo: C:\teste.CSV"},2,;
									{},2)}
			@ 010, 311 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oDlgTin ACTION (dtPegArq()) PIXEL
			
			//Tipo de Importação
			//@ 028, 006 SAY        oSayTab PROMPT "Tabela de Importação:"     SIZE 060, 007 OF oDlgTin PIXEL
			//@ 025, 070 MSCOMBOBOX oCmbTab VAR    cCmbTab ITEMS aIteTab       SIZE 100, 010 OF oDlgTin PIXEL
			//oCmbTab:bHelp := {||	ShowHelpCpo(	"cCmpTip",;
			//						{"Tipo de Importação que será processada."+STR_PULA+"Exemplo: 1 = Bancos"},2,;
			//						{},2)}
			
			//Caracter de Separação do CSV
			@ 043, 006 SAY        oSayTok PROMPT "Separador:"               SIZE 060, 007 OF oDlgTin PIXEL
			@ 040, 070 MSCOMBOBOX oCmbTok VAR    cCmbTok ITEMS aIteTok       SIZE 030, 010 OF oDlgTin PIXEL
			oGetArq:bHelp := {||	ShowHelpCpo(	"cGetCar",;
									{"Caracter de separação no arquivo."+STR_PULA+"Exemplo: ';'"},2,;
									{},2)}
			
		//Grupo Ações
		@ 063, 003 	GROUP oGrpAco TO nAltPosI-3, nLarPosI 	PROMPT "Ações: " 		OF oDlgTin COLOR 0, 16777215 PIXEL
		
			//Botões
			@ 070, (nLarPosI)-(63*1)  BUTTON oBtnSair PROMPT "Sair"          SIZE 60, 014 OF oDlgTin ACTION (oDlgTin:End()) PIXEL
			@ 070, (nLarPosI)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"      SIZE 60, 014 OF oDlgTin ACTION (Processa({|| dtLeCSV() }, "Aguarde...")) PIXEL
			
	ACTIVATE MSDIALOG oDlgTin CENTERED
	
	RestArea(aArea)
Return

//===================================================================================================================================================
Static Function dtLayOut()
//===================================================================================================================================================
	Local cTabela   	:= ""
	Local aArea 		:= GetArea()
	Local aCampos		:= {}
	Local aObrigatorio	:= {}
    Local cAliasTp		:= GetNextAlias()
	Local cCampo		:= "((cAliasTp)->X3_CAMPO)"
	
	Private aParamBox	:= {}
	
PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'
  

   aAdd(aParamBox,{1,"Tabela",Space(5),"@!","","SX2PAD","",60,.T.})
    If ParamBox(aParamBox,"Gerador de LayOut",,,,,,,,"NovosProdutos",.T.,.T.)
        cTabela := Alltrim(MV_PAR01)
	EndIf

	OpenSXs(/**/,/**/,/**/,/**/,"01",cAliasTp,"SX3",/**/,.F.)
    (cAliasTp)->(DbSetFilter({|| (cTabela)}, cTabela))
    (cAliasTp)->(DbGoTop())
          
    While !(cAliasTp)->(Eof())
       
        If X3Obrigat(&(cCampo)) == .T.
            aAdd(aObrigatorio,Alltrim(&(cCampo)))
        Else
            aAdd(aCampos,Alltrim(&(cCampo)))                                                      
        EndIf
     
    (cAliasTp)->(dbSkip())
    EndDo

    cCampos := ArrTokStr(aCampos,"|")
    cObrigatorio := ArrTokStr(aObrigatorio,"|")
    MsgInfo(cCampos + CRLF + cObrigatorio)
    
RESET ENVIRONMENT

    RestArea(aArea)

	dtSelCamp(aCampos)

Return

//*************************
Static Function dtPegArq()
//*************************
	Local cArq := ""
	cArq := cGetFile( "Arquivo | *.*",;				//Máscara
					"Arquivo LayOut ",;				//Título
							0,;						//Número da máscara
							,;						//Diretório Inicial
							.F.,;					//.F. == Abrir; .T. == Salvar
							GETF_LOCALHARD,;		//Unidade do disco localDiretório full. Ex.: 'C:\TOTVS\arquivo.xlsx'
							.F.)									//Não exibe diretório do servidor

	//cGetFile([mascar],[ctitulo],[nmasc],[cdirinit],[lsalvar],[nopcoes])							
	/*//Caso o arquivo não exista ou estiver em branco ou não for a extensão txt
	If Empty(cArqAux) .Or. !File(cArqAux) .Or. (SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "txt" .And. SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "csv")
		MsgStop("Arquivo <b>inválido</b>!", "Atenção")*/
		
	//Senão, define o get
	//Else
		cGetArq := PadR(cArq, 99)
		//oGetArq:Refresh()
	//EndIf*/

Return cGetArq

//********************************************************************************
Static Function dtSelCamp(aCampos)
//********************************************************************************
	
	Local oResp		:= Nil	
	Local aRet 		:= {}	
	Local nI		:= 0
	Local lOk		:= .F.
	Local bOk		:= { || lOk := .T., oDlg:End() }
	Local bCancel 	:= { || oDlg:End()}
	Local aButtons	:= {}
	Local oOk      	:= LoadBitmap( GetResources(), "LBOK")
	Local oNo      	:= LoadBitmap( GetResources(), "LBNO")
	Public _cZACUsuarios := ""
	
	aRet := FWSFALLUSERS()
	
	For nI := 1 to Len(aRet)
		If Upper(aRet[nI][3]) <> Upper("Administrador") .and. Upper(aRet[nI][3]) <> Upper("Admin") .and. Upper(aRet[nI][3]) <> Upper("Administrator")
			aAdd( aUsers , { .F. , aRet[nI][2], aRet[nI][3], aRet[nI][4] })
		Endif
	Next
		
	ASort( aCampos,,, {|x,y| x[4] < y[4] })
		
	DEFINE MsDialog oDlg Title "Selecione os Campos" From 00,00 To 27,95 Of oMainWnd Style 128
	oDlg:lEscClose := .F.
	
	Aadd( aButtons, {"PESQUISA", {|| PesqUser(oResp) }, "Pesquisa...", "Pesquisa" , {|| .T.}} )

	@ 035,005 ListBox oResp Var cVarQ Fields Header "","Codigo","Usuário","Nome" ColSizes 20,50,50,50 Size 365,170 Of oDlg Pixel
	oResp:SetArray(aCampos)
	oResp:bLDblClick:= { || aCampos[oResp:nAt,1] := !aCampos[oResp:nAt,1] }
	oResp:bLine 	:= { || {	iif(aCampos[oResp:nAt,01],oOk,oNo),aCampos[oResp:nAt,02],aCampos[oResp:nAt,03],aCampos[oResp:nAt,04]} }
	Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,bOk,bCancel,,@aButtons)
	/*   		
	If lOk
		For nI := 1 to Len(aUsers)
			If aUsers[nI,01]
				_cZACUsuarios += Alltrim(aUsers[nI,03])+"/"
			Endif
		Next
	Endif
	 */
Return .T.


//*******************************************************************************************************************


Static Function dtLeCSV()
    
    //Local cPasta    := 'C:\InstanciasVSCode\ProjetoImportador\'
    //Local cArq      := 'Produtos.csv'
    //Local cDir      := cPasta+cArq
    Local cLinha    := ''    
    
    Local aArea     := GetArea()
    
    Local aCampoSX3 := {}
    //Local aCampErr  := {}

    Local cAliasTp  := GetNextAlias()
    Local cFiltro   := "X3_ARQUIVO == 'SB1'"
    //Local cCampo    := "(cAliasTp)->X3_CAMPO"
    //Local n         := 0
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
 

PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'

    
    OpenSXs(/**/,/**/,/**/,/**/,"01",cAliasTp,"SX3",/**/,.F.)
    
    (cAliasTp)->(DbSetFilter({|| &(cFiltro)}, cFiltro))
    (cAliasTp)->(DbGoTop())
    
    /*While &cFiltro .and. SX3->(EOF())
        For n :=1 to &cFiltro->(LastRec())
        cCampo := &(cCampo)
        aAdd(aCabec, cCampo)    
        Next
        SX3->(DbSkip())
    EndDo*/
    aCampoSX3 := FwSx3Util():GetAllFields("SB1")
    
    If oArq:Open()
        If !oArq:EOF()
            While (oArq:HasLine())
                cLinha := oArq:GetLine()
                If ('COD' $ UPPER(cLinha))
                    aCampos:= StrTokArr(cLinha, ',') //considerar indicar uma variável para escolha do separador
                    //aSize(aCabec,Len(aCampos))
				
                	/*For n := 1 to Len(aCampos)
                    	(Alltrim(aCampos[n]) $ aCampoSX3)
                    	//If    nPos := ASCAN(aCampoSX3, {|x|Alltrim(x)==Alltrim(aCampos[n])})
                        	//If nPos>Len(aCabec)
                            	aAdd(aCabec, aCampos[n])
                        	EndIf
                	        	aCabec[nPos] := aCampos[n]                                                            
                        	Else
                            	aAdd(aCampErr, aCampos[n])
                    	EndIf
					Next	*/		
				Else
					aRegistro := StrTokArr(cLinha, ',')
					/*For n := 1 to len(aCabec)
						aAdd(aRegistro, aLinha[n])						
					Next */
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

    Alert(ArrTokStr(aDados,"|"))
    
    //MsExecAuto({|x, y| MATA010(x, y), aDados, nOper})

   // If lMsErroAuto
        //MostraErro()
    //EndIf

Return 
