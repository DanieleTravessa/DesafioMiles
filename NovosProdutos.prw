#Include 'Totvs.ch'
#Include 'TopConn.ch'

//===================================================================================================================================================
User Function NovosProdutos()
//===================================================================================================================================================
	Local cArquivo      := ""
	Local aVetor    	:= {}
	Local aDupPlan		:= {}
	Local aDupBase		:= {}
    Private aParamBox	:= {}
	
	aAdd(@aParamBox,{6,"Arquivo", Space(300), "", "", "", 90, .T., "", , GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.})

	If ParamBox(aParamBox,"Importa Produtos",,,,,,,,"NovosProdutos",.T.,.T.)
		cArquivo := Alltrim(MV_PAR01)
		If File(cArquivo)
			Processa({|| readArquivo(cArquivo, @aVetor, @aDupPlan, @aDupBase) }, "Importando....")
			If Len(aDupPlan) > 0 .or. Len(aDupBase) > 0
				Tela(aVetor, aDupPlan, aDupBase)
			Endif
        Else
            Alert("Arquivo '"+ cArquivo +"' inválido!")    
		Endif
	Endif

Return Nil

//===================================================================================================================================================
Static Function readArquivo(cArquivo, aVetor, aDupPlan, aDupBase)
//===================================================================================================================================================
	Local cCodigo   := ""
    Local cLinha    := ""
	Local cArq		:= ""
	Local cDescricao:= ""
	Local cQuery 	:= ""
	Local cIndice 	:= "CODIGO+DESCRICAO"
    Local aLinha    := {}
	Local aAuxStr 	:= {}
	Local nCont		:= 0
	Local nCont2	:= 0
    Public LPRDFILLSL := .F.

	aAdd(aAuxStr,{"MARKOK"		,"C",02,0})
	aAdd(aAuxStr,{"CODIGO"		,"C",TamSX3("B1_COD")[1]	,TamSX3("B1_COD")[2]})
	aAdd(aAuxStr,{"DESCRICAO"	,"C",TamSX3("B1_DESC")[1]	,TamSX3("B1_DESC")[2]})

	If Select("TRB") <> 0
		TRB->(dbCloseArea())
	Endif

	If Select("TRB2") <> 0
		TRB2->(dbCloseArea())
	Endif

	If Select("TRB3") <> 0
		TRB3->(dbCloseArea())
	Endif

	//--- Arquivo de trabalho 1:
	cArq := CriaTrab(aAuxStr,.T.)
	Use &cArq Alias "TRB" New
	Index on &cIndice To &cArq

	//--- Arquivo de trabalho 2:
	cArq := CriaTrab(aAuxStr,.T.)
	Use &cArq Alias "TRB2" New
	Index on &cIndice To &cArq

	//--- Arquivo de trabalho 3:
	cArq := CriaTrab(aAuxStr,.T.)
	Use &cArq Alias "TRB3" New
	Index on &cIndice To &cArq

    CT1->(dbSetOrder(1))

    FT_FUse(cArquivo)
	FT_FGoTop()
	Do While !FT_FEOF()
	
		IncProc("Leitura do Arquivo....")
		
		cLinha 	:= FT_FReadLN()
		cLinha 	:= StrTran(cLinha,";;",";X;")
		cLinha 	:= StrTran(cLinha,";;",";X;")
		cLinha 	:= StrTran(cLinha,";;",";X;")
		aLinha	:= StrTokArr(cLinha,";")
		
		If Len(aLinha) > 0
            aLinha[1]   := Substr(Alltrim(aLinha[1]),1,Len(CT1->CT1_CONTA))
            aLinha[2]   := Upper(Alltrim(aLinha[2]))+" "
            
            If !('B1_' $ aLinha[2])
                cCodigo     := aLinha[1]
				cDescricao	:= aLinha[2]
				aAdd(aVetor, { 	cCodigo,;		//--- 01- conta
				 				cDescricao,;	//--- 02- descricao
								.F.,;			//--- 03
								aLinha[3],;		//--- 04- um
								aLinha[4],;		//--- 05- cod. servico
								aLinha[5] })	//--- 06- TE

				/* Layout do Arquivo
				01- B1 CONTA	
				02- B1_DESC	
				03- B1_UM	
				04- B1_CODISS
				05- B1_TE	
				*/
            Endif
		Endif
		
		FT_FSkip()
	EndDo
	FT_FUse()
	FClose(cArquivo)

	For nCont:=1 to Len(aVetor)

		lGrava		:= .F.
		cDescricao 	:= Substr(aVetor[nCont,2],1,At(" ",aVetor[nCont,2]))
		cDescricao 	:= Alltrim(cDescricao)

		If !Empty(cDescricao)

			For nCont2:=1 to Len(aVetor)
				If cDescricao $ aVetor[nCont2,2] .and. nCont <> nCont2
					If Ascan(aDupPlan,{ |x| x[1] == aVetor[nCont,2] .and. x[3] == aVetor[nCont2,2] }) == 0
						aAdd(aDupPlan,{ aVetor[nCont,2], aVetor[nCont2,1], aVetor[nCont2,2] })
						aVetor[nCont,3] := .T.
					Endif
					lGrava := .T.
				Endif
			Next

			cQuery := " SELECT B1_COD, B1_DESC"
			cQuery += " FROM "+ RetSqlName("SB1")
			cQuery += " WHERE D_E_L_E_T_ = ' '"
			cQuery +=		" AND B1_DESC LIKE '%"+cDescricao+"%'"
			cQuery +=		" AND SUBSTRING(B1_ZZAUT,1,3) = 'AUT'"			
			cQuery += " ORDER BY B1_COD, B1_DESC"

			If Select("QRYSB1") <> 0
				QRYSB1->(dbCloseArea())
			Endif

			TcQuery cQuery Alias "QRYSB1" New 

			QRYSB1->(dbGoTop())
			While QRYSB1->(!Eof())
				aAdd(aDupBase,{ aVetor[nCont,2], QRYSB1->B1_COD, QRYSB1->B1_DESC })
				aVetor[nCont,3] := .T.
				lGrava := .T.
				QRYSB1->(dbSkip())
			Enddo
			QRYSB1->(dbCloseArea())

			If lGrava
				RecLock("TRB",.T.)
				TRB->CODIGO		:= aVetor[nCont,1]
				TRB->DESCRICAO	:= aVetor[nCont,2]
				TRB->(MsUnlock())
			Endif
		Endif

	Next

	aSort(aDupPlan,,,{ |x,y| x[1] < y[1] })

	TRB->(dbSetOrder(1))
	TRB->(dbGoTop())

	cDescricao 	:= Alltrim(TRB->DESCRICAO)
	nCont 		:= Ascan(aDupPlan,{ |x| Alltrim(x[1]) == cDescricao })
	If nCont > 0
		For nCont2:=nCont to Len(aDupPlan)
			If Alltrim(aDupPlan[nCont2,1]) == cDescricao
				RecLock("TRB2",.T.)
				TRB2->CODIGO	:= aDupPlan[nCont2,2]
				TRB2->DESCRICAO	:= aDupPlan[nCont2,3]
				TRB2->(MsUnlock())
			Else		
				Exit
			Endif
		Next
	Endif

	nCont 		:= Ascan(aDupBase,{ |x| Alltrim(x[1]) == cDescricao })
	If nCont > 0
		For nCont2:=nCont to Len(aDupPlan)
			If Alltrim(aDupBase[nCont2,1]) == cDescricao
				RecLock("TRB3",.T.)
				TRB3->CODIGO	:= aDupBase[nCont2,2]
				TRB3->DESCRICAO	:= aDupBase[nCont2,3]
				TRB3->(MsUnlock())
			Else		
				Exit
			Endif
		Next
	Endif

Return Nil

//===================================================================================================================================================
Static Function Tela(aVetor, aDupPlan, aDupBase)
//===================================================================================================================================================
	Local oDlgPrinc, oFWLayer, oPanelLeft
	Local aCoors 	:= FWGetDialogSize(oMainWnd)
	Local aColunas	:= {}
	Local bMudaLinha:= {|| fAtualizaTelas(aDupPlan, aDupBase) }
	Private oPanelCenter, oPanelRight

	aColunas:={	{"Produto" 			,"CODIGO" 	,"C",Len(SB1->B1_COD)	,0,"@!"},;
				{"Descrição" 		,"DESCRICAO","C",Len(SB1->B1_DESC)	,0,"@!"}}
	
	Define MsDialog oDlgPrinc Title 'Análise Novos Produtos' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	//--- Cria o conteiner onde serão colocados os browses:
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	//--- Painel:
	oFWLayer:AddLine( 'PAINEL', 100, .F. )
	oFWLayer:AddCollumn( 'LEFT' 	, 33, .T., 'PAINEL' )
	oFWLayer:AddCollumn( 'CENTER' 	, 34, .T., 'PAINEL' )
	oFWLayer:AddCollumn( 'RIGHT'	, 33, .T., 'PAINEL' )
	oPanelLeft 	:= oFWLayer:GetColPanel( 'LEFT' 	, 'PAINEL' )
	oPanelCenter:= oFWLayer:GetColPanel( 'CENTER'	, 'PAINEL' )
	oPanelRight	:= oFWLayer:GetColPanel( 'RIGHT'	, 'PAINEL' )

	//----------------------------- FWMBrowse Superior - N O V O S   P R O D U T O S:
	oBrwNovos:= FWMarkBrowse():New()
	oBrwNovos:SetOwner(oPanelLeft)
	oBrwNovos:SetDescription('Produtos Repetidos')
	oBrwNovos:SetAlias('TRB')
	oBrwNovos:SetFieldMark("MARKOK")
	oBrwNovos:SetFields(aColunas)
	oBrwNovos:SetMenuDef('')
	oBrwNovos:DisableDetails()
	oBrwNovos:SetTemporary(.T.)
	oBrwNovos:SetProfileID('1')
	oBrwNovos:SetChange(bMudaLinha)
	oBrwNovos:AddButton('Importa', {|| Processa({|| fImpProd(oDlgPrinc, aVetor, aDupPlan, aDupBase) },"Cadastrando Produtos...") },, 2, 0)
	oBrwNovos:Activate()

	//----------------------------- Lado Esquerdo - R E P E T I D O S   N A   P L A N I L H A:
	oBrwPlanilha:= FWMBrowse():New()
	oBrwPlanilha:SetOwner(oPanelCenter)
	oBrwPlanilha:SetDescription('Repetidos na Planilha')
	oBrwPlanilha:SetAlias('TRB2')
	oBrwPlanilha:SetFields(aColunas)
	oBrwPlanilha:SetMenuDef('')
	oBrwPlanilha:DisableDetails()
	oBrwPlanilha:SetTemporary(.T.)
	oBrwPlanilha:SetProfileID('2')
	oBrwPlanilha:Activate()

	//----------------------------- Lado Direito - R E P E T I D O S   N O   P R O T H E U S:
	oBrwProdutos:= FWMBrowse():New()
	oBrwProdutos:SetOwner(oPanelRight)
	oBrwProdutos:SetDescription('Repetidos no Protheus')
	oBrwProdutos:SetAlias('TRB3')
	oBrwProdutos:SetFields(aColunas)
	oBrwProdutos:SetMenuDef('')
	oBrwProdutos:DisableDetails()
	oBrwProdutos:SetTemporary(.T.)
	oBrwProdutos:SetProfileID('3')
	oBrwProdutos:Activate()

	Activate MsDialog oDlgPrinc Center

Return Nil

//===================================================================================================================================================
Static Function fAtualizaTelas(aDupPlan, aDupBase)
//===================================================================================================================================================
	Local cDescricao 	:= ""
	Local cArq			:= ""
	Local cIndice		:= "CODIGO+DESCRICAO"
	Local aAuxStr		:= {}
	Local nCont 		:= 0
	Local nCont2 		:= 0

	If Type("oBrwPlanilha") == "O" .and. Type("oBrwProdutos") == "O"

		TRB2->(dbCloseArea())
		TRB3->(dbCloseArea())

		aAdd(aAuxStr,{"MARKOK"		,"C",02,0})
		aAdd(aAuxStr,{"CODIGO"		,"C",TamSX3("B1_COD")[1]	,TamSX3("B1_COD")[2]})
		aAdd(aAuxStr,{"DESCRICAO"	,"C",TamSX3("B1_DESC")[1]	,TamSX3("B1_DESC")[2]})

		//--- Arquivo de trabalho 2:
		cArq := CriaTrab(aAuxStr,.T.)
		Use &cArq Alias "TRB2" New
		Index on &cIndice To &cArq

		//--- Arquivo de trabalho 3:
		cArq := CriaTrab(aAuxStr,.T.)
		Use &cArq Alias "TRB3" New
		Index on &cIndice To &cArq

		cDescricao 	:= Alltrim(TRB->DESCRICAO)
		nCont 		:= Ascan(aDupPlan,{ |x| Alltrim(x[1]) == cDescricao })
		If nCont > 0
			For nCont2:=nCont to Len(aDupPlan)
				If Alltrim(aDupPlan[nCont2,1]) == cDescricao
					RecLock("TRB2",.T.)
					TRB2->CODIGO	:= aDupPlan[nCont2,2]
					TRB2->DESCRICAO	:= aDupPlan[nCont2,3]
					TRB2->(MsUnlock())
				Else		
					Exit
				Endif
			Next
		Endif

		cDescricao 	:= Alltrim(TRB->DESCRICAO)
		nCont 		:= Ascan(aDupBase,{ |x| Alltrim(x[1]) == cDescricao })
		If nCont > 0
			For nCont2:=nCont to Len(aDupBase)
				If Alltrim(aDupBase[nCont2,1]) == cDescricao
					RecLock("TRB3",.T.)
					TRB3->CODIGO	:= aDupBase[nCont2,2]
					TRB3->DESCRICAO	:= aDupBase[nCont2,3]
					TRB3->(MsUnlock())
				Else		
					Exit
				Endif
			Next
		Endif

		TRB2->(dbGoTop())
		If TRB2->(Eof())
			RecLock("TRB2",.T.)
			TRB2->CODIGO	:= " "
			TRB2->DESCRICAO	:= " "
			TRB2->(MsUnlock())
		Endif
		oBrwPlanilha:Refresh()

		TRB3->(dbGoTop())
		If TRB3->(Eof())
			RecLock("TRB3",.T.)
			TRB3->CODIGO	:= " "
			TRB3->DESCRICAO	:= " "
			TRB3->(MsUnlock())
		Endif		
		oBrwProdutos:Refresh()

		oPanelCenter:Refresh()
		oPanelRight:Refresh()
	Endif 

Return .T.

//===================================================================================================================================================
Static Function fImpProd(oDlgPrinc, aVetor, aDupPlan, aDupBase)
//===================================================================================================================================================
	Local aSB1 			:= {}
	Local nCont			:= 0
	Local lGera			:= .F.
	Local cMarca		:= oBrwNovos:cMark
	Local cCodigo		:= ""
	Local cLog			:= ""
	Private lMsErroAuto := .F.
                
	For nCont:=1 to Len(aVetor)

		lGera := .F.

		If !aVetor[nCont,3]
			lGera := .T.
		Else
			cCodigo := PADR(aVetor[nCont,1],Len(TRB->CODIGO))
			If TRB->(dbSeek( cCodigo + aVetor[nCont,2] ))
				If TRB->MARKOK == cMarca 
					lGera := .T.
				Endif 
			Endif
		Endif

    	If lGera
			CT1->(dbSeek( xFilial("CT1") + aVetor[nCont,1] ))

			cCodigo := nProxNumProd(aVetor[nCont,1])
			cDescri	:= Alltrim(aVetor[nCont,2])
			cDescri	:= Substr(cDescri,1,Len(SB1->B1_DESC))
			cDescri	:= NoAcento(cDescri)
			cLog 	:= "AUT - "+ DTOC(Date()) +" - "+ Time() +" - "+ Alltrim(cUserName)
			//aVetor[nCont,6] := StrZero(Val(aVetor[nCont,6]),3)
			//aVetor[nCont,6] := aVetor[nCont,6]

			aSB1:= {}

			If !Empty(aVetor[nCont,5]) .and. aVetor[nCont,5] <> "X" .and. aVetor[nCont,5] <> "XX"
				aSB1:= { 	{"B1_COD" 		, cCodigo		        , Nil},;
							{"B1_DESC" 		, cDescri       		, Nil},;
							{"B1_TIPO" 		, "GG" 			        , Nil},;
							{"B1_UM" 		, aVetor[nCont,4]       , Nil},;
							{"B1_LOCPAD" 	, "01" 			        , Nil},;
							{"B1_POSIPI" 	, "00000000" 			, Nil},;
							{"B1_ZZTPALC" 	, "Z" 			        , Nil},;
							{"B1_ZZLOC" 	, "A000"	        	, Nil},;
							{"B1_CONTA" 	, aVetor[nCont,1]       , Nil},;
							{"B1_ZZDESCT" 	, CT1->CT1_DESC01       , Nil},;
							{"B1_LOCALIZ" 	, "N" 			        , Nil},;
							{"B1_RASTRO" 	, "N" 			        , Nil},;
							{"B1_TE" 		, aVetor[nCont,6]       , Nil},;
							{"B1_MSBLQL" 	, "2" 			        , Nil},;
							{"B1_ORIGEM" 	, "0" 			        , Nil},;
							{"B1_ZZAUT" 	, cLog 			        , Nil},;
							{"B1_GARANT" 	, "2" 			        , Nil},;
							{"B1_CODISS"	, aVetor[nCont,5]		, Nil}}
			Else		
				aSB1:= { 	{"B1_COD" 		, cCodigo		        , Nil},;
							{"B1_DESC" 		, cDescri       		, Nil},;
							{"B1_TIPO" 		, "GG" 			        , Nil},;
							{"B1_UM" 		, aVetor[nCont,4]       , Nil},;
							{"B1_LOCPAD" 	, "01" 			        , Nil},;
							{"B1_POSIPI" 	, "00000000" 			, Nil},;
							{"B1_ZZTPALC" 	, "Z" 			        , Nil},;
							{"B1_ZZLOC" 	, "A000"	        	, Nil},;
							{"B1_CONTA" 	, aVetor[nCont,1]       , Nil},;
							{"B1_ZZDESCT" 	, CT1->CT1_DESC01       , Nil},;
							{"B1_LOCALIZ" 	, "N" 			        , Nil},;
							{"B1_RASTRO" 	, "N" 			        , Nil},;
							{"B1_TE" 		, aVetor[nCont,6]       , Nil},;
							{"B1_MSBLQL" 	, "2" 			        , Nil},;
							{"B1_ORIGEM" 	, "0" 			        , Nil},;
							{"B1_ZZAUT" 	, cLog 			        , Nil},;
							{"B1_GARANT" 	, "2" 			        , Nil}}
			Endif
			
			lMsErroAuto := .F.
			MSExecAuto({|x,y| Mata010(x,y)},aSB1,3)
			
			If lMsErroAuto
				MostraErro()
			Endif 
		Endif
	Next 

	oDlgPrinc:End()

Return .T.

//===================================================================================================================================================
Static Function nProxNumProd(cCodConta)
//===================================================================================================================================================
    Local cContaContab  := Alltrim(cCodConta)
	Local cProximo	    := StrZero(1,6)
    Local cProximoNumero:= cContaContab + cProximo
    Local cQuery        := ""

	cQuery := " SELECT MAX(B1_COD) NUMAX"
	cQuery += " FROM " + RetSqlName("SB1")
	cQuery += " WHERE "
	cQuery += 		" D_E_L_E_T_ = ' ' AND "
	cQuery += 		" B1_COD LIKE '"+ Alltrim(cCodConta) +"%' "

    If Select("QRY") <> 0
        QRY->(dbCloseArea())
    Endif

    TcQuery cQuery Alias "QRY" New

    QRY->(dbGoTop())
    cProximo        := Soma1( Substr(QRY->NUMAX,Len(cContaContab)+1,6) ) 
    cProximoNumero  := cContaContab + cProximo
    QRY->(dbCloseArea())

Return cProximoNumero
