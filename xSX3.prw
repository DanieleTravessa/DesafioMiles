#INCLUDE 'totvs.ch'
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} User Function x_SX3
    (long_description)
    @type  Function
    @author user
    @since 19/06/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function xxSX3()

    Local aArea := GetArea()
    Local aCampos := {}
    Local cAliasTp := GetNextAlias() //"SX3TST"
    Local cFiltro := "X3_ARQUIVO == 'SB1'"
    //Local cCampo := "((cAliasTp)->X3_CAMPO)"

//PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'

    OpenSXs(/**/,/**/,/**/,/**/,"01",cAliasTp,"SX3",/**/,.F.)
    (cAliasTp)->(DbSetFilter({|| &(cFiltro)}, cFiltro))
    (cAliasTp)->(DbGoTop())
 
While !(cAliasTp)->(Eof())

       // If X3Obrigat()         
        Aadd(aCampos,((cAliasTp)->X3_CAMPO))                                                      
     
    (cAliasTp)->(dbSkip())
EndDo

    Alert(aCampos[1])
    
//Reset Environment    
    RestArea(aArea)
Return 
