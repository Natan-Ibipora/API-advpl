#include "totvs.ch"
#include "tbiconn.ch"
#INCLUDE "Topconn.ch"
#INCLUDE 'restful.ch'

WSRESTFUL zWSProdutos  Description 'Webservices cadastros de produtos '
    WSDATA id AS STRING 
    WSDATA updated_at AS STRING
    WSDATA limit AS INTEGER
    WSDATA page AS INTEGER 

    WSMETHOD GET ID  Description 'Retorna registros pesquisados ' WSSYNTAX '/zWSProdutos/get_id?{id}' path 'get_id' PRODUCES APPLICATION_JSON
    WSMETHOD GET ALL Description 'Retorna os dados de todos os registros' WSSYNTAX '/zWProdutos/get_all{updated_at, limit, page}' path'get_all' PRODUCES APPLICATION_JSON
    WSMETHOD POST NEW Description 'Inclusão de registros' WSSYNTAX '/zWProdutos/new' PATH 'new'PRODUCES APPLICATION_JSON
END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id WSSERVICE zWProdutos

    Local lRet:= .T.
    Local jResponse:=JsonObject():New()
    Local cAliasWS:='SB1'

    IF Empty(::id)
        Self:SetStatus(500)
        jResponse['errorId'] :='ID001'
        jResponse['erro']    :='ID vazio'
        jResponse['solution']:='Informe o ID'
    else
        DBSelectArea(cAliasWS)
        (cAliasWS)->(DBSetOrder(1))
        IF ! (cAliasWS)->(MsSeek(xFialial(cAliasWS)+ ::id))
            Self::setStatus(500)
            jResponse['errorId']:='ID002'
            jResponse['erro']:='ID não encontrado'
            jResponse['solution']:='Preencha com Id existente'
        Else
            jResponse['codigo']:=(cAliasWS)->B1_COD
            jResponse['desc']:= (cAliasWS)->B1_DESC
            jResponse['tipo']:=(cAliasWS)->B1_TIPO
            jResponse['um']:=(cAliasWS)->B1_UM
            jResponse['locpad']:=(cAliasWS)->B1_LOCPAD
            jResponse['grupo']:=(cAliasWS)->B1_GRUPO
        ENDIF
    self:conttype('application/json')
    self:setResponse(jResponse:toJson())

    ENDIF 
Return lRet

WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE zWProdutos
    Local lRet := .T.
    Local jResponse:=JsonObject():new()
    Local cQueryTab:=''
    Local nTamanho:=10
    Local nTotal :=0
    Local nPags :=0
    Local nPagina:=0
    Local nAtual :=0
    Local oRegistro:=0
    Local cAliasWS:="SB1"

    cQueryTab:="SELECT "+CRLF
    cQueryTab+="    TAB.R_E_C_N_O_ AS TABREC "+CRLF
    cQueryTab+=" FROM "+CRLF
    cQueryTab+="  "+RetSQLName(cAliasWS)+ " TAB "+CRLF
    cQueryTab+=" WHERE "+CRLF
    cQueryTab+=" TAB.D_E_L_E_T_=' ' " +CRLF

    IF !Empty(::updated_at)
        cQueryTab+=" AND ((CASE WHEN SUBSTRING(B1_USERLGA, 03, 1) !=' ' THEN"+CRLF 
        cQueryTab+="   CONVER(VARCHAR,DATEADD(DAY,(ASCII,(SUBSTRING(B1_USERLGA,1))-50 ) * 100+(ASCII,SUBSTRING(B1_USERLGA,16,1))-50),19960101),"
        cQueryTab+="   ELSE ' ' "+CRLF
        cQueryTab+="   END)>= '"+Strtran(::updated_at,'-','')+ "')"+ CRLF
    Endif
    cQueryTab+=" ORDER BY "+CRLF
    cQueryTab+=" TABREC "+CRLF

   	TCQUERY cQueryTab NEW ALIAS "QRY_TAB"

    IF QRY_TAB->(EOF())
        self:setStatus(500)
        jResponse['erroId']:='ALL003'
        jResponse['error']:="Registro não encontrado"
        jResponse['solution']:="A consulta não retornou nenhuma informação"
    ELSE
        jResponse['objects']:={}

        Count to nTotal
        QRY_TAB->(Gotop())

        if !Empty(::limit)
            nTamanho:=::limit
        Endif

        nPags:=NoRound(nTotal/nTamanho,0)
        nPags+=Iif(nTotal%nTamanho !=0 ,1,0)

        If ! Empty(::page)
            nPagina:=::page
        EndIf

        If nPagina <=0 .Or. nPagina>nPags
            nPagina:=1
        Endif
        If nPagina!=1
            QRY_TAB->(DbSkip(nPagina-1) * nTamanho)
        Endif
    
        JsonMeta:=JsonObject():New()
        JsonMeta['total']:=nTotal
        JsonMeta['current _page']:=nPagina
        JsonMeta['total_page']:=nPags
        JsonMeta['total_items']:= nTamanho
        jResponse['meta']:=JsonMeta

        While !QRY_TAB->(EOF())
        nAtual++
        
        IF nAtual > nTamanho
            Exit
        EndIf

        DBSelectArea(cAliasWS)    
        (cAliasWS)->(DBGoTop(QRY_TAB->TABREC))

        oRegistro:=JsonObject():New()
        oRegistro['cod']:=(cAliasWS)->B1_COD
        oRegistro['desc']:=(cAliasWS)->B1_DESC
        oRegistro['tipo']:=(cAliasWS)->B1_TIPO
        oRegistro['um']:=(cAliasWS)->B1_UM
        oRegistro['locpad']:=(cAliasWS)->B1_LOCPAD
        oRegistro['grupo']:=(cAliasWS)->B1_GRUPO
        aAdd(jResponse['objects'],oRegistro)

        QRY_TAB->(DbSkip())
        Enddo
    EndIf
    QRY_TAB(DBCloseArea())

    Self:conttype('application/json')
    Self:setResponse(Response:toJson())
Return lRet
