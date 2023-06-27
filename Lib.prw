#INCLUDE'TOTVS.CH'

/*/{Protheus.doc} dtPegArq
    (long_description)
    @type  Function
    @author user
    @since 27/06/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function dtPegArq()

	Local cArq := ""
	cArq := cGetFile( "Arquivo | *.*",;				//M�scara
					"Arquivo LayOut ",;				//T�tulo
							,;						//N�mero da m�scara
							,;						//Diret�rio Inicial
							.F.,;					//.F. == Abrir; .T. == Salvar
							GETF_LOCALHARD,;		//Unidade do disco localDiret�rio full. Ex.: 'C:\TOTVS\arquivo.xlsx'
							.F.)									//N�o exibe diret�rio do servidor
								
	/*//Caso o arquivo n�o exista ou estiver em branco ou n�o for a extens�o txt
	If Empty(cArqAux) .Or. !File(cArqAux) .Or. (SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "txt" .And. SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "csv")
		MsgStop("Arquivo <b>inv�lido</b>!", "Aten��o")
		
	//Sen�o, define o get
	Else
		cGetArq := PadR(cArqAux, 99)
		oGetArq:Refresh()
	EndIf*/

Return cArq
