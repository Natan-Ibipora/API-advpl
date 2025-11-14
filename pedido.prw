#include 'totvs.ch'
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"
/// SOMENTE TESTES NAO FOI APLICADO
USER FUNCTION MT120FIL ()
    Local cRet :=""
    Local cQuery := ""   
   
    
    montaTela()
   	// IF RetCodUsr() =="000000"
			
	// ENDIF

    cQuery := "SELECT A2_COD FROM " + RetSQLNAME("SA2") + " SA2 WHERE SA2.D_E_L_E_T_= ' ' AND SA2.A2_CGC='33886983000164' "

    TCQUERY cQuery NEW ALIAS "TEMP"
    dbSelectArea("TEMP")    
    TEMP-> (dbGoTop())
    WHILE !TEMP->(EOF())
        cRet := " C7_FORNECE = " + TEMP->A2_COD
        TEMP->(dbSkip())
    ENDDO
    TEMP->(DbCloseArea())

    IF cRet == ""
        ALERT("NAO FOI ENCONTRADO PEDIDOS PARA O CNPJ INFORMADO")
    ENDIF

Return cRet  

Static Function montaTela()
    Local nJanAltu   := 300
    Local nJanLarg   := 3
    Local lDimPixels := .T.
    Local lCentraliz := .T.
    Local bBlocoIni  := {||}  

    Private oDlg  
    Private oGetObj 
    Private xGetObj := Space(11)
    Private cFontNome   := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)

    oDlg := TDialog():New(0,0,nJanLarg,nJanAltu,'Filtro Pedido de compras',,,,,CLR_BLACK,CLR_WHITE,,,.T.)

    nJanAltu := 12
    nJanLarg := 100

    oGetObj  := TGet():New(30, 20, {|u| Iif(PCount() > 0 , xGetObj := u, xGetObj)}, oDlg, nJanLarg, nJanAltu, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
    oGetObj:cPlaceHold := 'Digite o CNPJ'
    //continuar amanha
    //oTButton1 := TButton():New( nObjLinha+35, nObjColun+20, "Filtrar",oDlg,{||alert("Olá "+xGetObj1+" da empresa "+ xGetObj2)}, 40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oDlg:Activate(, , , lCentraliz, , , bBlocoIni)
Return 
