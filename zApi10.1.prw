#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL zWPROD Description "Exemplo de Rest"
   
    WSDATA id AS STRING OPTIONAL    
    WSDATA preco AS Integer  OPTIONAL

    WSMETHOD GET DESCRIPTION "Retorna todos os produtos" WSSYNTAX "zWPROD/" PATH "/zWPROD"
    WSMETHOD GET GetById DESCRIPTION "Retorna o produto da tabela ZZ6  por id" WSSYNTAX "zWPROD/{id}" PATH "/zWPROD/{id}"
    WSMETHOD PUT PutID DESCRIPTION "Recebe um id e atualiza os dados do registro ZZ6" WSSYNTAX "zWPROD/{id}" PATH "/zWPROD/{id}"
    WSMETHOD POST PostId DESCRIPTION "Realiza uma postagem dos dados "
END WSRESTFUL
//http://192.168.246.12:8097/rest/zWPROD

WSMETHOD GET  WSSERVICE zWPROD
    Local lPost := .T.
    Local oResponse := JsonObject():New()
    Local cQuery
    Local aTarefas:= {}
    Local aTasks:={}    
    Local cJson := ""
    ::SetContentType("application/json")

    cAlias := GetNextAlias()
    cQuery:=" SELECT "
    cQuery+="  ZZ6_CODIGO, "
    cQuery+="   ZZ6_NOME, "
    cQuery+="   ZZ6_PRECO "
    cQuery+=" FROM "+RetSQLNAME('ZZ6')+" ZZ6 "
    cQuery+=" WHERE "
    cQuery+="   ZZ6.ZZ6_FILIAL=' ' "
    cQuery+="   AND ZZ6.D_E_L_E_T_= ' ' "

    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()
            oTask['codigo']:=(cAlias)->ZZ6_CODIGO
            oTask['nome']:=(cAlias)->ZZ6_NOME
            oTask['preco']:=(cAlias)->ZZ6_PRECO
            aAdd(aTasks,oTask)
            (cAlias)->(DbSkip())

        End    
        cResponse:=FWJsonSerialize(aTasks,.F.,.F.,.T.)
        ::SetResponse(cResponse)
    ELSE
        cResponse :=FWJsonSerialize(aTasks,.F.,.F., .T.) 
        ::SetResponse(cResponse)
    ENDIF
    (cAlias)->(DbCloseArea())

Return lPost


WSMETHOD GET GetById PATHPARAM id WSSERVICE zWPROD
    Local lPost := .T.
    Local oResponse := JsonObject():New()
    Local cQuery
    Local aTarefas :={}
    ::SetContentType("application/json")

    cAlias :=GetNextAlias()
    cQuery := " SELECT "
    cQuery+="       ZZ6.ZZ6_CODIGO, "
    cQuery+="       ZZ6.ZZ6_NOME"
    cQuery+=" FROM "+ RetSQLNAME("ZZ6")+" ZZ6 "
    cQuery+=" WHERE "
    cQuery+="           ZZ6.ZZ6_FILIAL =' ' "
    cQuery +="      AND ZZ6.ZZ6_CODIGO='" + ::id +"'"
    cQuery +="      AND ZZ6.D_E_L_E_T_=' '"

    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!EOF())
    
        lPost :=.T.
        oResponse['codigo']:=(cAlias)->ZZ6_CODIGO
        oResponse['descrição']:=(cAlias)->ZZ6_NOME
        cResponse := FWJsonSerialize(oResponse,.F.,.F.,.T.)
        ::SetResponse(cResponse)
        
    ELSE 
        lPost := .F.
        cRetorno :=" O produto não encontrado"
        SetRestFault(404,cRetorno)
    ENDIF
    (cAlias)->(DbCloseArea())
Return lPost


WSMETHOD PUT PutID PATHPARAM id WSSERVICE zWPROD
    Local aArea:=GetArea()
    Local lPost := .T.
    Local cProdCod:=alltrim(::id)
    Local oResponse := JsonObject():New()
    Local oRequest  := JsonObject():New()
    
   
    ::SetContentType("application/json")  
    oRequest:fromJson(::GetContent())
    DBSelectArea('ZZ6')
    ZZ6->(DBSetOrder(1))    
    IF ZZ6->(DBSeek(FwxFilial('ZZ6')+cProdCod))    
        lPost :=.T.     
        IF RecLock("ZZ6",.F.)                
            ZZ6->ZZ6_PRECO:= oRequest["preco"] //::preco   
            cResponse := "Preco alterado"
            ::SetResponse(cResponse)  
        ELSE
            cResponse := "Não foi possivel alterar o preco"
            ::SetResponse(cResponse)   
        ENDIF

    ELSE 
        lPost := .F.
        cRetorno :=" O produto não encontrado"
        SetRestFault(404,cRetorno)
    ENDIF
    ZZ6->(DbCloseArea())
    restArea(aArea)
Return lPost
