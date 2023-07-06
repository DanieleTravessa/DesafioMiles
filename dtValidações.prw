#INCLUDE'TOTVS.CH'
/*
dtSelCamp
/   		
	If lOk
		For nI := 1 to Len(aUsers)
			If aUsers[nI,01]
				_cZACUsuarios += Alltrim(aUsers[nI,03])+"/"
			Endif
		Next
	Endif
-----------------------------------------
dtImporta
//Tipo de Importação
			//@ 028, 006 SAY        oSayTab PROMPT "Tabela de Importação:"     SIZE 060, 007 OF oDlgTin PIXEL
			//@ 025, 070 MSCOMBOBOX oCmbTab VAR    cCmbTab ITEMS aIteTab       SIZE 100, 010 OF oDlgTin PIXEL
			//oCmbTab:bHelp := {||	ShowHelpCpo(	"cCmpTip",;
			//						{"Tipo de Importação que será processada."+STR_PULA+"Exemplo: 1 = Bancos"},2,;
			//						{},2)}	
    
    
-----------------------------------------------
dtPegaArquivo
	//cGetFile([mascar],[ctitulo],[nmasc],[cdirinit],[lsalvar],[nopcoes])							
	///Caso o arquivo não exista ou estiver em branco ou não for a extensão txt
	If Empty(cArqAux) .Or. !File(cArqAux) .Or. (SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "txt" .And. SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "csv")
		MsgStop("Arquivo <b>inválido</b>!", "Atenção")
		
	//Senão, define o get
	//Else
		cGetArq := PadR(cArq, 99)
		//oGetArq:Refresh()
	//EndIf   

-----------------------------------------------
dtLeCSV
    //Local cPasta    := 'C:\InstanciasVSCode\ProjetoImportador\'
    //Local cArq      := 'Produtos.csv'
    //Local cDir      := cPasta+cArq 
    //Local aCampErr  := {}
    //Local cCampo    := "(cAliasTp)->X3_CAMPO"
    //Local n         := 0

    While &cFiltro .and. SX3->(EOF())
        For n :=1 to &cFiltro->(LastRec())
        cCampo := &(cCampo)
        aAdd(aCabec, cCampo)    
        Next
        SX3->(DbSkip())
    EndDo

     //aSize(aCabec,Len(aCampos))
				
                	For n := 1 to Len(aCampos)
                    	(Alltrim(aCampos[n]) $ aCampoSX3)
                    	//If    nPos := ASCAN(aCampoSX3, {|x|Alltrim(x)==Alltrim(aCampos[n])})
                        	//If nPos>Len(aCabec)
                            	aAdd(aCabec, aCampos[n])
                        	EndIf
                	        	aCabec[nPos] := aCampos[n]                                                            
                        	Else
                            	aAdd(aCampErr, aCampos[n])
                    	EndIf
					Next			
    /*For n := 1 to len(aCabec)
						aAdd(aRegistro, aLinha[n])						
					Next */


 */

