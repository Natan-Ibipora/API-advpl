
#include "TOTVS.ch"
/*

 Função que importa arquivo CSV de campos MRP e faz alteração no cadastro de produtos,
 Fonte feito para Lucas Maciel e Rafael Sorgi
 Data: 02/05/2025
/*/
User  Function MRPALT()     
    Local i 
	Local aCpos := {}
    Local nTam  := 0   

    //incluindo os campos
	aadd(aCpos,"B1_COD")   
    aadd(aCpos,"B1_DESC")
    aadd(aCpos,"B1_TIPO")
    aadd(aCpos,"B1_EMIN")
    aadd(aCpos,"B1_ESTSEG")
    aadd(aCpos,"B1_LE")
    aadd(aCpos,"B1_LM")
    aadd(aCpos,"B1_TIPODEC")
    aadd(aCpos,"B1_FANTASM")
    aadd(aCpos,"B1_MRP")    
    aadd(aCpos,"B1_EMAX")    
    aadd(aCpos,"B1_PRODSBP") 
    aadd(aCpos,"B1_UFASE")
    aadd(aCpos,"B1_UCONSPP")
    
	//Montando a tela e os campos
	aHeader := {}
	dbselectarea("SX3")
	dbsetorder(2)
	for i:=1 to len(aCpos)
		if dbseek(aCpos[i])
			aadd(aHeader,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
				"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
		endif
	next
	aCols := {array(len(aCpos) + 1)} //precisa ser o tamanho dos campos que serão utilizados mais um, pois no ultimo campo é obrigatório o valor booleano falso
	nTam  := len(aCols[1])
    for i:=1 to (nTam - 1 )
		aCols[1,i] := criavar(aHeader[i,2])
	next
	aCols[1,nTam] := .F.
	
	
    oDlg := MSDIALOG():New(0,0,600,1000,"Alterando produtos",,,,,,,,,.T.)
    oGetD := MsNewGetDados():New(10,10,300,430,,"AllwaysTrue()","AllwaysTrue()",,{},0,999,;
	"AllwaysTrue()","","AllwaysFalse",oDlg,aHeader,aCols)
	
  
    @ 030,450 BUTTON 'Importar' SIZE 040, 015 PIXEL OF oDlg ACTION (importar())
    @ 070,450 BUTTON 'Processar' SIZE 040, 015 PIXEL OF oDlg ACTION (processar())
    @ 110,450 BUTTON 'Fechar' SIZE 040, 015 PIXEL OF oDlg ACTION (oDlg:End())
    
	oDlg:lCentered := .T.

	oDlg:activate()
    
Return 
//fazendo a leitura do csv e importando para os campos
Static Function importar()
    
    Local aDados    
    Local cFileNom := cGetFile( "Arquivo TXT *.csv | *.csv", "Arquivo .csv...",,'',.T., GETF_LOCALHARD)
    Local i
    Local aArea := GetArea()
    Local cCod := ""
    Local cItem :=""
    
    aDados:= {}   
    MV_PAR01 := alltrim(cFileNom)
    If File(MV_PAR01)
        FT_FUse(MV_PAR01)
        FT_FGotop()
        cLinha := FT_FReadLn()
        FT_FSkip()//PULA O CABECALHO
        FT_FSkip() //Rotulo das colunas
        cLinha := ""
        aDados := {}
        aLinha := {}
        _CONT := 0

        procregua(FT_FLASTREC())
          
        While !FT_FEOF()
            incproc("Lendo Arquivo...")            
            _CONT++
            cLinha := FT_FReadLn() 
            
            IF cLinha==""
                Exit
            ENDIF
            cLinha := FT_FReadLn()

            cLinha := upper(cLinha)
            cLinha := noAcento(cLinha)
            cLinha += ";"

            _auxIni := 1
            _auxFim := 1
            while _auxFim<=len(cLinha)
                if substr(cLinha,_auxFim,1) == ";"
                    cItem := substr(cLinha,_auxIni,_auxFim-_auxIni)
                    aadd(aLinha,alltrim(cItem))
                    _auxFim++
                    _auxIni := _auxFim
                else
                    _auxFim++
                endif
            enddo

            cLinha := strtran(cLinha," ","")
            cLinha := strtran(cLinha,"   ","")            

           // aadd(aLinha,substr(cLinha,_auxIni,_auxFim-_auxIni))

            aadd(aDados,aLinha)

            aLinha := {}
            FT_FSkip()
            //  FT_FUse()
        EndDo

        FT_FUse()
    else
        MSGINFO("Arquivo nao encontrado. Favor verificar os parametros.")
    endif
	
    oGetd:aCols := {}
    for i := 1 to len(aDados)
        aTmp := {}
        cCod := cValToChar(ltrim(aDados[i,1]))
        // dbselectArea("SB1")
        // DbSetOrder(1)      
       
        // DbSeek(xFilial("SB1") + ALLTRIM(aDados[i,1]))
        DBSELECTAREA("SB1")
        DBSETORDER(1)
        DBSEEK(xFilial("SB1") + cCod)

        //Se o campo código for diferente de vazio e for igual ao posicionado na tabela SB1 ele tras na tela
        IF !empty(aDados[i,1]) .AND. ALLTRIM(SB1->B1_COD) == alltrim(cCod)
            aadd(aTmp,  SB1->B1_COD            )
            aadd(aTmp,  aDados[i,2]            )
            aadd(aTmp,  aDados[i,3]            )
            aadd(aTmp,  val(aDados[i,4])       )    
            aadd(aTmp,  val(aDados[i,5])       )
            aadd(aTmp,  val(aDados[i,6])       )  
            aadd(aTmp,  val(aDados[i,7])       )  
            aadd(aTmp,  UPPER(aDados[i,8])     )            
            aadd(aTmp,  UPPER(aDados[i,9])     )                
            aadd(aTmp,  UPPER(aDados[i,10])    )                
            aadd(aTmp,  val(aDados[i,11])      )                
            aadd(aTmp,  UPPER(aDados[i,12])    )                    
            aadd(aTmp,  aDados[i,13]           )                
            aadd(aTmp,  aDados[i,14]           )                
            aadd(aTmp,  .f.                    )
            aadd(oGetd:aCols,aClone(aTmp)      )
        ELSE
            fwAlertError("ERRO produto <b>" + aDados[i,1] + "</b> não encontrado ou em branco, corrija e inicie o programa novamente !!!","NAO ENCONTRADO")
            oDlg:End()// encerrando o programa pois queremos que todos os códigos de produtos estejam ok para enviar todos
            EXIT            
        ENDIF       
    Next
    oGetd:Refresh()
    RestArea(aArea)
Return 
//Fazendo o MsExecauto dos campos em tela.
Static Function processar()
    Local i
    Local aArea := GetArea()
    PRIVATE lMsErroAuto := .F.
		IF MsgNoYes("Deseja realizar a alteração em massa ? Por favor confirmar os dados antes do envio","Alterar em massa")
       
            for i:=1 to len(oGetd:aCols)	
                aVetor := {}       
                aadd(aVetor,{"B1_COD"	     ,oGetd:aCols[i, 1]         ,	Nil})
                //pulando o oGetd:aCols[i,3](tipo) e oGetd:aCols[i,2](descricacao) pois não é preciso altera-los
                aadd(aVetor,{"B1_EMIN"       ,oGetd:aCols[i, 4]         ,	Nil})  
                aadd(aVetor,{"B1_ESTSEG"     ,oGetd:aCols[i, 5]         ,	Nil})        
                aadd(aVetor,{"B1_LE"         ,oGetd:aCols[i, 6]         ,	Nil})                  
                aadd(aVetor,{"B1_LM"         ,oGetd:aCols[i, 7]         ,	Nil})  
                aadd(aVetor,{"B1_TIPODEC"    ,oGetd:aCols[i, 8]         ,	Nil})  
                aadd(aVetor,{"B1_FANTASM"    ,oGetd:aCols[i, 9]         ,	Nil})
                aadd(aVetor,{"B1_MRP"        ,oGetd:aCols[i, 10]         ,	Nil})        
                aadd(aVetor,{"B1_EMAX"       ,oGetd:aCols[i, 11]        ,	Nil})        
                aadd(aVetor,{"B1_PRODSBP"    ,oGetd:aCols[i, 12]        ,	Nil})        
                aadd(aVetor,{"B1_UFASE"      ,oGetd:aCols[i, 13]        ,	Nil})        
                aadd(aVetor,{"B1_UCONSPP"    ,oGetd:aCols[i, 14]        ,	Nil})        
                
                lMsErroAuto := .F.
                DBSelectArea("SB1")
                DBSetOrder(1)
                IF DbSeek(xFilial()+oGetd:aCols[i,1])                    
                    MsgRun("Alterando produto: " + oGetd:aCols[i, 1],  "Alterando", {|| (MSExecAuto({|x,y| MATA010(x,y)},aVetor,4)) })                    
                    if lMsErroAuto
                        mostraerro()                   
                    endif
                ENDIF            
		    next     
            FWAlertSuccess("Os produtos foram alterados com sucesso", "PRODUTOS ALTERADOS")
            oDlg:End()
        ENDIF	
    RestArea(aArea)
Return 
