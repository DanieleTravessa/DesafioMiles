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
