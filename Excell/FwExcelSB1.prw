#INCLUDE'totvs.ch'
#INCLUDE'topconn.ch'

/*/{Protheus.doc} User Function FwExcelSA2
    Rotina que gera uma planilha no Excel em resposta ao exercício2 Lista12
    @type  Function
    @author Daniele Travessa
    @since 19/04/2023
    
    @see (tdn.totvs.com/display/public/mp/FWMsExcel)
        (tdn.totvs.com/display/framework/FWMsExcelEx)
    /*/
User Function FwExcelSB1()
       
    Local cAlias := GeraConsul()

    Private cDiretorio := 'E:\STARTotvsJc\Excel\'
    Private cArquivo   := 'FwExcelSB1.xml'
    Private cCaminho   := cDiretorio + cArquivo
    Private oExcel
      
    //Criando o objeto que irá gerar o conteúdo do Excel
    oExcel := FWMSExcel():New()
                    
    oExcel:AddworkSheet("Produtos")                
    oExcel:AddTable("Produtos","Dados dos Produtos")
    
    // ESQUERDA 1 - CENTRO 2 - DIREITA 3 -|- GERAL 1 - NUMERO 2 - MONETARIO 3 - DATETIME 4
    oExcel:AddColumn("Produtos","Dados dos Produtos","Codigo",    1, 1)
    oExcel:AddColumn("Produtos","Dados dos Produtos","Descrição", 1, 1)
    oExcel:AddColumn("Produtos","Dados dos Produtos","Tipo",      2, 1)
    oExcel:AddColumn("Produtos","Dados dos Produtos","Unidade Medida", 1, 1)
    oExcel:AddColumn("Produtos","Dados dos Produtos","Preço de Venda", 1, 1)

    ImpDados(cAlias)
    GeraPlanil()

Return

Static Function ImpDados(cAlias)
       
    Local cCodigo, cDesc, cTipo, cUM, cPreVenda
    
            
    DbSelectArea(cAlias) 
    (cAlias)->(DbGoTop())      

    While !((cAlias)->(EoF()))
       
        cCodigo   := (cAlias)->(B1_COD)
        cDesc     := (cAlias)->(B1_DESC)
        cTipo     := (cAlias)->(B1_TIPO)
        cUM       := (cAlias)->(B1_UM)
        cPreVenda := (cAlias)->(B1_PRV1)
        

        If D_E_L_E_T_ <> " "
            oExcel:SetCelFrColor('#FF0000')            
        EndIf

        oExcel:AddRow("Produtos","Dados dos Produtos",{cCodigo, cDesc, cTipo, cUM, 'R$' + STR(cPreVenda,,2)})

        (cAlias)->(DbSkip())
    EndDo
      
    (cAlias)->(DbCloseArea())
   
Return

Static Function GeraPlanil()
    //Ativando o arquivo e gerando o xml
    oExcel:Activate()
    
    oExcel:GetXMLFile(cCaminho)         
    
    If ApOleClient('MsExcel')
        oExcel := MsExcel():New()        
        oExcel:WorkBooks:Open(cCaminho)  
        oExcel:SetVisible(.T.)           
        oExcel:Destroy()                 
    Else        
        If ExistDir("C:\Program Files (x86)\LibreOffice 5")
                WaitRun('C:\Program Files (x86)\LibreOffice 5\program\scalc.exe "'+cArquivo+'"', 1)       
        Else
                ShellExecute("Open", cArquivo, "", "C:\", 1)
        EndIf
    EndIf
    
    FwAlertSuccess('Arquivo Gerado!','Arquivo Gerado com Sucesso!!')     
  
    oExcel:DeActivate()

Return  

Static Function GeraConsul()

    Local aArea := GetArea()
    Local cQuery := ''
    Local cAlias := GetNextAlias()
    
    cQuery += ' SELECT B1_COD, B1_DESC, B1_TIPO, B1_UM, B1_PRV1 ' + CRLF
    cQuery += ' FROM ' + RetSqlName('SB1') + ' SB1 '    

    TCQUERY cQuery ALIAS (cAlias) NEW 

    (cAlias)->(DbGoTop())

    RestArea(aArea)

Return cAlias
