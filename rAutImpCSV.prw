#INCLUDE'TOTVS.CH'
#INCLUDE'TBICONN.CH'

/*/{Protheus.doc} LeArqCSV
 (L14Challenge. Desenvolva uma rotina que importará de forma automática os produtos de uma planilha (.csv) para o Protheus)
    @type  Function
    @author Daniele Travessa
    @since 08/05/2023
    @version version
      @see (https://terminaldeinformacao.com/2021/12/16/como-fazer-a-importacao-de-um-arquivo-csv-ou-txt-via-advpl/)
      (https://github.com/MurielZounar/exemplos-advpl-start2/blob/master/Aula%2024/LeCSV.prw)   
    /*/
User Function LeArqCSV()
    
    Local cPasta := 'C:\'
    Local cArq   := 'Produtos.csv'
    Local cDir   := (cPasta + cArq)
    Local cLinha := ''    
    Local aLinha

    Local oArq   := FwFileReader():New(cDir)

    Private cB1cod  := ''
    Private cB1desc := ''
    Private cB1tipo := ''
    Private cB1um   := ''
    Private nB1prv  := 0
    
    If oArq:Open()
        If !oArq:EOF()
            While (oArq:HasLine())
                cLinha := oArq:GetLine()
                If !('codigo' $ Lower(cLinha))
                    aLinha := StrTokArr(cLinha, ';')
                    If !('A' $ aLinha[6])
                        cB1cod  := aLinha[1]
                        cB1desc := aLinha[2]
                        cB1tipo := aLinha[3]
                        cB1um   := aLinha[4]
                        nB1prv  := val(aLinha[5])
                        rAutImpCSV()
                    EndIf
                EndIf
            EndDo
        EndIf    
    oArq:Close()
    EndIf

Return 

/*/{Protheus.doc} rAutImpCSV
    @type  Function
    @author Daniele Travessa
    @since 08/05/2023 
    /*/
Static Function rAutImpCSV()

    //Local aDado     := DadosCSV()
    Local aDados        := {}
    Local nOper         := 3
    Private lMsErroAuto := .F.

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'EST'

    aAdd(aDados, {'B1_FILIAL', xFilial('SB1'), /**/})
    aAdd(aDados, {'B1_COD'   , cB1cod        , /**/})
    aAdd(aDados, {'B1_DESC'  , cB1desc       , /**/})
    aAdd(aDados, {'B1_TIPO'  , cB1tipo       , /**/})
    aAdd(aDados, {'B1_UM'    , cB1um         , /**/})
    aAdd(aDados, {'B1_PRV1'  , nB1prv        , /**/})
    aAdd(aDados, {'B1_LOCPAD', '01'          , /**/})
              
    MsExecAuto({|x, y| MATA010(x, y), aDados, nOper})

//GETSX3CACHE()

    If lMsErroAuto
        MostraErro()
    EndIf

Return 

/*/{Protheus.doc} DadosCSV
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
    /*/
/*Function DadosCSV()
    Local aCSV := {}

Return aCSV
*/
