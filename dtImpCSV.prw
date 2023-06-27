#INCLUDE'TOTVS.CH'
#INCLUDE'TBICONN.CH'

/*/{Protheus.doc} dtLeCSV
 (L14Challenge. Desenvolva uma rotina que importarÃ¡ de forma automÃ¡tica os produtos de uma planilha (.csv) para o Protheus)
    @type  Function
    @author Daniele Travessa
    @since 08/05/2023
    @version version      
    /*/
User Function dtLeCSV()
    
    //Local cPasta    := 'C:\InstanciasVSCode\ProjetoImportador\'
    //Local cArq      := 'Produtos.csv'
    Local cDir      := u_dtPegArq(cArq)
    Local cLinha    := ''    
    
    Local aArea     := GetArea()
    
    Local aCampoSX3 := {}
    Local aCampErr  := {}
    Local aCabec    := {}
    Local cAliasTp  := GetNextAlias()
    Local cFiltro   := "X3_ARQUIVO == 'SB1'"
    //Local cCampo    := "(cAliasTp)->X3_CAMPO"
    Local n         := 0
    Local oArq      := FwFileReader():New(cDir)

    Private aLinha  := {}
    Private aCampos := {}    
    Private cB1cod  := ''
    Private cB1desc := ''
    Private cB1tipo := ''
    Private cB1um   := ''
    Private nB1prv  := 0   
 

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
                    aSize(aCabec,Len(aCampos))
                    For n := 1 to Len(aCampos)
                         //(Alltrim(aCampos[n]) $ aCampoSX3)
                        If    nPos := ASCAN(aCampoSX3, {|x|Alltrim(x)==Alltrim(aCampos[n])})
                            If nPos>Len(aCabec)
                                aAdd(aCabec, aCampos[n])
                            EndIf
                            aCabec[nPos] := aCampos[n]                                                            
                        Else
                            aAdd(aCampErr, aCampos[n])
                        EndIf
                    Next
                Else 
                    aLinha := StrTokArr(cLinha, ';')                           
                        dtImpCSV()
                    
                EndIf
            EndDo
        EndIf    
        oArq:Close()
    EndIf

    RestArea(aArea)

Reset Environment

Return 

/*Sugestão de implantação:
//checar posição do campo no array
    nB1Cod  := ASCAN(aNomeCampo, {|x|Alltrim(x)=="A1_COD"})
    nB1Desc := ASCAN(aNomeCampo, {|x|Alltrim(x)=="A1_DESC"})
    nB1tipo := ''
    nB1um   := ''
    nB1prv  := 0 
//efetuar a importação pela posição do campo
    aAdd(aDados,{Alltrim(aCampos[nB1Cod]),StrZero(Val(aDados[i,nB1cod]),6),nil})

/*{Protheus.doc} dtImpCSV
    @type  Function
    @author Daniele Travessa
    @since 08/05/2023 */
    
Static Function dtImpCSV()

    //Local aDado     := DadosCSV()
    Local aDados        := {}
    //Local nOper         := 3
    Local n := 0
    //Private lMsErroAuto := .F.

    //PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'EST'

   // aAdd(aDados, {'B1_FILIAL', xFilial('SB1') ,''})

    For n := 1 to Len(aCampos)
        aAdd(aDados, {aCampos[n], aLinha[n],''})
    Next
    Alert(ArrTokStr(aDados,"|"))
    
    //MsExecAuto({|x, y| MATA010(x, y), aDados, nOper})

   // If lMsErroAuto
        //MostraErro()
    //EndIf

Return 

/*{Protheus.doc} DadosCSV
    (long_description)
    @type  Function
    @author user
    @since 22/05/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    
Function DadosCSV()
    Local aCSV := {}

Return aCSV
*/
