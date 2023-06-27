#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} CadObrigacoes
	Cadastro de Obrigacoes Fiscais
	@Author 	Cassandra J. Silva
	@Since 		13/07/2018
	@Version 	1.0	
/*/
//********************************************************************************
User Function AE_Cadastro()
//********************************************************************************
	Local cAutorizados := Alltrim(GetNewPar("ZZ_AVISO", "viviane.fantinati/damata/cassandra_jacinto/cassandra_silva"))
	
	If cEmpAnt == "01"	
		If Upper(Alltrim(cUserName)) $ Upper(cAutorizados)
			oBrowse:= FWMBrowse():New()
			oBrowse:SetAlias('ZAC')
			oBrowse:SetLocate()
			oBrowse:SetDescription('Cadastro de Obrigações Fiscais')
			oBrowse:Activate()
		Else
			Aviso("Atenção","Usuário "+ Upper(Alltrim(cUserName)) +" não autorizado [Parâmetro ZZ_AVISO].",{"OK"},,"Parâmetro ZZ_AVISO")	
		Endif
	Endif

Return Nil


//********************************************************************************
Static Function MenuDef()
//********************************************************************************
	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.AE_Cadastro' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'		Action 'VIEWDEF.AE_Cadastro'	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'		Action 'VIEWDEF.AE_Cadastro'	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'		Action 'VIEWDEF.AE_Cadastro' 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Avisos'		Action 'U_AvisoFiscal()' 		OPERATION 5 ACCESS 0

Return aRotina


//********************************************************************************
Static Function ModelDef()
//********************************************************************************
	Local oModel 	:= Nil
	Local oStruZAC 	:= FWFormStruct( 1, 'ZAC' )
	Local oStruZAD 	:= FWFormStruct( 1, 'ZAD', { |cCampo| AllTrim(cCampo)+"|" $ "|ZAD_EMP|ZAD_FIL|ZAD_NOME|ZAD_DIA|ZAD_UF|ZAD_CGC|ZAD_IE|ZAD_IM|ZAD_INFO|ZAD_SITE|ZAD_UKEY1|ZAD_UKEY2|ZAD_USUARI|"} )

	oModel := MPFormModel():New( 'COMPZAC' )
	oModel:AddFields( 'ZACMASTER', /*cOwner*/ , oStruZAC )
	oModel:AddGrid( 'ZADDETAIL'  , 'ZACMASTER', oStruZAD )
	oModel:SetDescription( 'Cadastro de Obrigações Fiscais' )
	oModel:SetRelation( 'ZADDETAIL', { { 'ZAD_FILIAL', 'xFilial( "ZAD" )' }, { 'ZAD_ID', 'ZAC_ID' } }, ZAD->( IndexKey(1) ))
	oModel:GetModel( 'ZADDETAIL' ):SetUniqueLine( {'ZAD_EMP', 'ZAD_FIL'} )
	oModel:GetModel( 'ZACMASTER' ):SetDescription( 'Cadastro de Obrigações Fiscais' )
	oModel:GetModel( 'ZADDETAIL' ):SetDescription( 'Entregas' )
	oModel:SetPrimaryKey({})

Return oModel


//********************************************************************************
Static Function ViewDef()
//********************************************************************************
	Local oModel 	:= FWLoadModel( 'AE_Cadastro' )
	Local oStruZAC 	:= FWFormStruct( 2, 'ZAC' )
	Local oStruZAD  := FWFormStruct( 2, 'ZAD',{ |cCampo| AllTrim(cCampo)+"|" $ "|ZAD_EMP|ZAD_FIL|ZAD_NOME|ZAD_DIA|ZAD_UF|ZAD_CGC|ZAD_IE|ZAD_IM|ZAD_INFO|ZAD_SITE|ZAD_UKEY1|ZAD_UKEY2|ZAD_USUARI|"} )

	oView:= FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZAC', oStruZAC, 'ZACMASTER' )
	oView:AddGrid( 'VIEW_ZAD', oStruZAD, 'ZADDETAIL' )
	oView:CreateHorizontalBox( 'CABEC', 40 )
	oView:CreateHorizontalBox( 'ITENS', 60 )
	oView:SetOwnerView( 'VIEW_ZAC', 'CABEC' )
	oView:SetOwnerView( 'VIEW_ZAD', 'ITENS' )
	
Return oView


//********************************************************************************
User Function NEmpFil(nOpt, _cCodEmp, _cCodFil)
//********************************************************************************
	Local cRetorno 	:= Space(Len(ZAD->ZAD_NOME))
	Local aAreaSM0	:= SM0->(GetArea())

	SM0->(dbSetOrder(1))
	If SM0->(dbSeek( _cCodEmp + _cCodFil ))
		If nOpt == 1
			cRetorno := Upper(SM0->M0_FILIAL)
		ElseIf nOpt == 2
			cRetorno := SM0->M0_CGC
		ElseIf nOpt == 3
			cRetorno := SM0->M0_INSC
		ElseIf nOpt == 4
			cRetorno := SM0->M0_ESTCOB
		ElseIf nOpt == 5
			cRetorno := SM0->M0_INSCM
		Endif
	Endif

	RestArea(aAreaSM0)

Return cRetorno


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


//********************************************************************************
Static Function PesqUser(oResp)
//********************************************************************************
	Local cNome := Space(30)
	Local nBusca:= 0
	Local oFont1, oDlg1, oGrp1, oGet1, oBtn1

	oFont1 := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )
	oDlg1:= MSDialog():New( 096,232,244,724,"Pesquisa Usuário",,,.F.,,,,,,.T.,,,.T. )
	oGrp1:= TGroup():New( 004,008,036,228,"Nome do Usuário:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGet1:= TGet():New( 016,016,{|u| If(PCount()>0,cNome:=u,cNome)},oGrp1,200,010,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNome",,)
	oBtn1:= TButton():New( 044,188,"Ok",oDlg1,{|| oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )
	oDlg1:Activate(,,,.T.)

	nBusca := Ascan(oResp:aArray, { |x| Upper(Alltrim(cNome)) $ Upper(Alltrim(x[2])) .or. Upper(Alltrim(cNome)) $ Upper(Alltrim(x[3])) })
	If nBusca > 0
		oResp:nAT := nBusca 		
		oResp:Refresh()
	Endif
		
Return Nil

	