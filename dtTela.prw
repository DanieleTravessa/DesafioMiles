#INCLUDE'TOTVS.CH'
		
User Function dtTela()
	Local aArea := GetArea()
	//Dimensões da janela
	Local nJanAltu := 80
	Local nJanLarg := 400
	Local nAltPosI := nJanAltu/2
	Local nLarPosI := nJanLarg/2
	//Objetos da tela
	Local oGrpOpc
	Local oBtnSair
	Local oBtnImp
	Local oBtnLay

//	Private aIteTip := {}
	Private oSayArq, oGetArq, cGetArq := Space(99)
	Private oSayTip, oCmbTip, cCmbTip := ""
	Private oSayCar, oGetCar, cGetCar := ';'
	Private oDlgOpc

	DEFINE MSDIALOG oDlgOpc TITLE "Importador de Dados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        
        //Grupo Ações
		@ 003, 003 	GROUP oGrpOpc TO nAltPosI, nLarPosI PROMPT "Ações: " OF oDlgOpc COLOR 0, 16777215 PIXEL
		
			//Botões
			@ (nAltPosI)-20, (nLarPosI)-(63*1)  BUTTON oBtnSair PROMPT "Sair"       SIZE 60, 014 OF oDlgOpc ACTION (oDlgOpc:End()) PIXEL
			@ (nAltPosI)-20, (nLarPosI)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"   SIZE 60, 014 OF oDlgOpc ACTION (Processa({|| dtImporta() }, "Aguarde...")) PIXEL
			@ (nAltPosI)-20, (nLarPosI)-(63*3)  BUTTON oBtnLay  PROMPT "LayOut"     SIZE 60, 014 OF oDlgOpc ACTION (Processa({|| dtLayOut() }, "Aguarde...")) PIXEL
	ACTIVATE MSDIALOG oDlgOpc CENTERED
	
	RestArea(aArea)

Return

Static Function dtImporta()
	Local aArea := GetArea()
	//Dimensões da janela
	Local nJanAltu := 180
	Local nJanLarg := 650
	//Objetos da tela
	Local oGrpPar
	Local oGrpAco
	Local oBtnSair
	Local oBtnImp
	//Local oBtnObri
	Local oBtnArq
	
	Private aIteTip := {}
	Private oSayArq, oGetArq, cGetArq := Space(99)
	Private oSayTip, oCmbTip, cCmbTip := ""
	Private oSayCar, oGetCar, cGetCar := ';'
	Private oDlgPvt

	DEFINE MSDIALOG oDlgPvt TITLE "Importador" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Grupo Parâmetros
		@ 003, 003 	GROUP oGrpPar TO 060, (nJanLarg/2) 	PROMPT "Parâmetros: " 		OF oDlgPvt COLOR 0, 16777215 PIXEL
			//Caminho do arquivo
			@ 013, 006 SAY        oSayArq PROMPT "Arquivo:"                  SIZE 060, 007 OF oDlgPvt PIXEL
			@ 010, 070 MSGET      oGetArq VAR    cGetArq                     SIZE 240, 010 OF oDlgPvt PIXEL
			oGetArq:bHelp := {||	ShowHelpCpo(	"cGetArq",;
									{"Arquivo CSV ou TXT que será importado."+STR_PULA+"Exemplo: C:\teste.CSV"},2,;
									{},2)}
			@ 010, 311 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oDlgPvt ACTION (dtPegArq()) PIXEL
			
			//Tipo de Importação
			@ 028, 006 SAY        oSayTip PROMPT "Tipo Importação:"          SIZE 060, 007 OF oDlgPvt PIXEL
			@ 025, 070 MSCOMBOBOX oCmbTip VAR    cCmbTip ITEMS aIteTip       SIZE 100, 010 OF oDlgPvt PIXEL
			oCmbTip:bHelp := {||	ShowHelpCpo(	"cCmpTip",;
									{"Tipo de Importação que será processada."+STR_PULA+"Exemplo: 1 = Bancos"},2,;
									{},2)}
			
			//Caracter de Separação do CSV
			@ 043, 006 SAY        oSayCar PROMPT "Carac.Sep.:"               SIZE 060, 007 OF oDlgPvt PIXEL
			@ 040, 070 MSGET      oGetCar VAR    cGetCar                     SIZE 030, 010 OF oDlgPvt PIXEL //VALID fVldCarac()
			oGetArq:bHelp := {||	ShowHelpCpo(	"cGetCar",;
									{"Caracter de separação no arquivo."+STR_PULA+"Exemplo: ';'"},2,;
									{},2)}
			
		//Grupo Ações
		@ 063, 003 	GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2) 	PROMPT "Ações: " 		OF oDlgPvt COLOR 0, 16777215 PIXEL
		
			//Botões
			@ 070, (nJanLarg/2)-(63*1)  BUTTON oBtnSair PROMPT "Sair"          SIZE 60, 014 OF oDlgPvt ACTION (oDlgPvt:End()) PIXEL
			@ 070, (nJanLarg/2)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"      SIZE 60, 014 OF oDlgPvt ACTION (Processa({|| u_dtLeCSV() }, "Aguarde...")) PIXEL
			//@ 070, (nJanLarg/2)-(63*3)  BUTTON oBtnObri PROMPT "LayOut"   SIZE 60, 014 OF oDlgPvt ACTION (Processa({|| fConfirm(2) }, "Aguarde...")) PIXEL
	ACTIVATE MSDIALOG oDlgPvt CENTERED
	
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
	
	RpcSetEnv('99','01')
	
    aAdd(aParamBox,{1,"Tabela",Space(TamSX3("X3_ARQUIVO")[01]),"@!","","SX3","",60,.T.})
    
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
    
	RpcClearEnv()

    RestArea(aArea)
Return

//
Static Function dtPegArq()
//
	Local cArq := ""
	cArq := cGetFile( "Arquivo | *.*",;				//Máscara
					"Arquivo LayOut ",;				//Título
							,;						//Número da máscara
							,;						//Diretório Inicial
							.F.,;					//.F. == Abrir; .T. == Salvar
							GETF_LOCALHARD,;		//Unidade do disco localDiretório full. Ex.: 'C:\TOTVS\arquivo.xlsx'
							.F.)									//Não exibe diretório do servidor
								
	/*//Caso o arquivo não exista ou estiver em branco ou não for a extensão txt
	If Empty(cArqAux) .Or. !File(cArqAux) .Or. (SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "txt" .And. SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "csv")
		MsgStop("Arquivo <b>inválido</b>!", "Atenção")
		
	//Senão, define o get
	Else
		cGetArq := PadR(cArqAux, 99)
		oGetArq:Refresh()
	EndIf*/

Return cArq

//********************************************************************************
User Function fSelUser()
//********************************************************************************
	Local oModel 	:= FWModelActive()
	Local oResp		:= Nil
	Local oZAC  	:= oModel:GetModel("ZACMASTER")
	Local aRet 		:= {}
	Local aUsers	:= {}
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
		
	ASort( aUsers,,, {|x,y| x[4] < y[4] })
		
	Define MsDialog oDlg Title "Selecione os Responsáveis" From 00,00 To 27,95 Of oMainWnd Style 128
	oDlg:lEscClose := .F.
	
	Aadd( aButtons, {"PESQUISA", {|| PesqUser(oResp) }, "Pesquisa...", "Pesquisa" , {|| .T.}} )

	@ 035,005 ListBox oResp Var cVarQ Fields Header "","Codigo","Usuário","Nome" ColSizes 20,50,50,50 Size 365,170 Of oDlg Pixel
	oResp:SetArray(aUsers)
	oResp:bLDblClick:= { || aUsers[oResp:nAt,1] := !aUsers[oResp:nAt,1] }
	oResp:bLine 	:= { || {	iif(aUsers[oResp:nAt,01],oOk,oNo),aUsers[oResp:nAt,02],aUsers[oResp:nAt,03],aUsers[oResp:nAt,04]} }
	Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,bOk,bCancel,,@aButtons)
	   		
	If lOk
		For nI := 1 to Len(aUsers)
			If aUsers[nI,01]
				_cZACUsuarios += Alltrim(aUsers[nI,03])+"/"
			Endif
		Next
	Endif
	 
Return .T.


    /*If ParamBox(aParamBox,"Importa Produtos",,,,,,,,"NovosProdutos",.T.,.T.)
		cArquivo := Alltrim(MV_PAR01)
		If File(cArquivo)
			Processa({|| readArquivo(cArquivo, @aVetor, @aDupPlan, @aDupBase) }, "Importando....")
			If Len(aDupPlan) > 0 .or. Len(aDupBase) > 0
				Tela(aVetor, aDupPlan, aDupBase)
			Endif
        Else
            Alert("Arquivo '"+ cArquivo +"' inválido!")    
		Endif
	Endif*/
/*
Return Nil
   Local nCont         := 0
    Local aTransfere    := {}
    Private lMsErroAuto := .F.

    For nCont:=1 to Len(aTitulos)

        If aTitulos[nCont,1]

            lMsErroAuto := .F.
            aTransfere  := {}

            //--- Chave do título:
            aAdd(aTransfere, {"E1_PREFIXO"  , aTitulos[nCont,03]    , Nil })
            aAdd(aTransfere, {"E1_NUM"      , aTitulos[nCont,04]    , Nil })
            aAdd(aTransfere, {"E1_PARCELA"  , aTitulos[nCont,05]    , Nil })
            aAdd(aTransfere, {"E1_TIPO"     , aTitulos[nCont,06]    , Nil })
        
            //--- Informações bancárias:
            aAdd(aTransfere, {"AUTDATAMOV"  , dDataBase             , Nil })
            aAdd(aTransfere, {"AUTBANCO"    , aTitulos[nCont,13]    , Nil })
            aAdd(aTransfere, {"AUTAGENCIA"  , aTitulos[nCont,14]    , Nil })
            aAdd(aTransfere, {"AUTCONTA"    , aTitulos[nCont,15]    , Nil })
            aAdd(aTransfere, {"AUTSITUACA"  , "2"                   , Nil })
            aAdd(aTransfere, {"AUTNUMBCO"   , aTitulos[nCont,17]    , Nil })
            aAdd(aTransfere, {"AUTGRVFI2"   , .T.                   , Nil })
        
            //--- Carteira descontada deve ser encaminhado o valor de crédito, desconto e IOF já calculados:
            If cSituaca $ "2|7"
                aAdd(aTransfere, {"AUTDESCONT",   0                 ,    Nil })
                aAdd(aTransfere, {"AUTCREDIT",    aTitulos[nCont,10],    Nil })
                aAdd(aTransfere, {"AUTIOF",       0                 ,    Nil })
            EndIf

            MsExecAuto({|x,y| FINA060()}, 2, aTransfere)
        
            If lMsErroAuto
                MostraErro()
            EndIf

        Endif

    Next nCont

    oDlg:End()

Return Nil
*/
