#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
  
//-------------------------------------------------------------------
/*/{Protheus.doc} WSCardsCustomer
    Exemplo de API de integração de Cards
   
    @author     Squad CRM & Faturamento
    @since      13/04/2022
    @version    12.1.33
/*/
//-------------------------------------------------------------------
WSRESTFUL CardsCustomer DESCRIPTION "Cards de Clientes"
    WSDATA Fields           AS STRING   OPTIONAL
    WSDATA Order            AS STRING   OPTIONAL
    WSDATA Page             AS INTEGER  OPTIONAL
    WSDATA PageSize         AS INTEGER  OPTIONAL
   
    WSMETHOD POST itemsDetails ;
        DESCRIPTION "Carrega os Itens Utilizados para Montagem do Painel" ;
        WSSYNTAX "/cards/itemsDetails/{Order, Page, PageSize, Fields}" ;
        PATH "/cards/itemsDetails";
        PRODUCES APPLICATION_JSON
   
    WSMETHOD GET cardFilter;
        DESCRIPTION "Disponibiliza os campos que poderão ser utilizados no filtro do Card" ;
        WSSYNTAX "/cards/cardFilter/" ;
        PATH "/cards/cardFilter";
        PRODUCES APPLICATION_JSON
   
    WSMETHOD GET cardInfo;
        DESCRIPTION "Carrega as informações do Painel" ;
        WSSYNTAX "/cards/cardInfo/" ;
        PATH "/cards/cardInfo";
        PRODUCES APPLICATION_JSON
   
    WSMETHOD GET fieldsInfo ;
        DESCRIPTION "Carrega os campos que podem que ser utilizados" ;
        WSSYNTAX "/cards/fieldsInfo/" ;
        PATH "/cards/fieldsInfo";
        PRODUCES APPLICATION_JSON
ENDWSRESTFUL
  
//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
    Carrega os Itens Utilizados para Montagem do Painel
   
    @author Squad CRM & Faturamento
    @since 13/04/2022
    @version 12.1.33
/*/
//-------------------------------------------------------------------
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CardsCustomer
    Local aHeader       := {}
    Local aRet          := {}
    Local cError        := "Erro na Requisição"
    Local lRet          := .T.
    Local oCoreDash     := CoreDash():New()
    Local aFilter       := {}
    Local nQtdFilter    := 0
    Local cFilter       := ""
    Local nX            := 0
    Local cBody         := DecodeUtf8(Self:GetContent())
    Local oBody         := JsonObject():New()
    Local oJDetails     := JsonObject():New()
    Local cCampos       := ""
   
    Self:SetContentType("application/json")
   
    If !Empty(cBody)
        oBody:FromJson(cBody)
        If ValType(oBody["detailFilter"]) == "A"
            oJDetails := oBody["detailFilter"]
        EndIf
    EndIf
  
    If Len(oJDetails) == 0
        aHeader := RetHeader("SA1")
        oCoreDash:SetFields(DePara("SA1"))
        oCoreDash:SetApiQstring(Self:aQueryString)
        aFilter := oCoreDash:GetApiFilter()
        nQtdFilter := Len(aFilter)
        If nQtdFilter > 0
            For nX := 1 to nQtdFilter
                cFilter += " AND " + aFilter[nX][1]
            Next
        EndIf
  
        //Chama a função responsavel por montar a Expressão SQL
        aRet := MntQuery(, cFilter + " AND (SA1.A1_RISCO = 'A' OR SA1.A1_RISCO = 'B' OR SA1.A1_RISCO = 'C')",,"SA1")
    ElseIf Len(oJDetails) == 1
        aHeader := RetHeader("SC5")
        oCoreDash:SetFields(DePara("SC5"))
        oCoreDash:SetApiQstring(Self:aQueryString)
        aFilter := oCoreDash:GetApiFilter()
        nQtdFilter := Len(aFilter)
        If nQtdFilter > 0
            For nX := 1 to nQtdFilter
                cFilter += " AND " + aFilter[nX][1]
            Next
        EndIf
  
        cFilter := " AND SC5.C5_CLIENTE = '" + oJDetails[1]['code'] + "'"
        cCampos := "SC5.C5_NUM, SC5.C5_TIPO, SC5.C5_CONDPAG, SC5.C5_EMISSAO"
        aRet    := MntQuery(cCampos, cFilter,,"SC5")
    EndIf
   
    //Define a Query padrão utilizada no Serviço
    oCoreDash:SetQuery(aRet[1])
    oCoreDash:SetWhere(aRet[2])
    If Len(aRet) >= 3
        oCoreDash:SetGroupBy(aRet[3])
    EndIf
  
    oCoreDash:BuildJson()
    lRet := ValType(oCoreDash:GetJsonObject()['items']) == "A"
   
    If lRet
        oCoreDash:SetPOHeader(aHeader)
        Self:SetResponse( oCoreDash:ToObjectJson())
    Else
        SetRestFault(500,  EncodeUtf8(cError))
    EndIf
   
    oCoreDash:Destroy()
   
    aSize(aRet, 0)
    aSize(aHeader, 0)
Return lRet
  
//-------------------------------------------------------------------
/*/{Protheus.doc} MntQuery
    Monta a query responsável por trazer os itens utilizados no Painel
   
    @param cCampos,  Caractere, Campos que serão retornados no SELECT
    @param cFiltro,  Caractere, Filtro a ser adicionado na query
    @param cGroupBy, Caractere, Expressão group by a ser adicionada na query
    @author Squad CRM & Faturamento
    @since 13/04/2022
    @version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function MntQuery(cCampos, cFiltro, cGroupBy, cTable)
    Local cQuery
    Local cWhere
    Local cGroup
  
    Default cTable := "SA1"
    Default cCampos := "SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_NREDUZ, SA1.A1_RISCO"
   
    If cTable == "SA1"
        cQuery := " SELECT " + cCampos + " FROM " + RetSqlName("SA1") + " SA1 "
        cWhere := " SA1.R_E_C_N_O_ <= 1000 AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'" + cFiltro
        cWhere += " AND SA1.D_E_L_E_T_ = ' ' "
    ElseIf cTable == "SC5"
        cQuery := " SELECT " + cCampos + " FROM " + RetSqlName("SC5") + " SC5 "
        cWhere := " SC5.C5_FILIAL = '" + xFilial("SC5") + "'" + cFiltro
        cWhere += " AND SC5.D_E_L_E_T_ = ' ' "
    EndIf
  
    If !Empty(cGroupBy)
        cGroup := cGroupBy
    EndIf
Return {cQuery, cWhere, cGroup}
  
//-------------------------------------------------------------------
/*/{Protheus.doc} DePara
    Efetua o Conversão entre os atributos objetos do Json e os campos utilizados na Consulta
   
    @author Squad CRM & Faturamento
    @since 13/04/2022
    @version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function DePara(cTable)
    Local aCampos := {}
    Default cTable := "SA1"
  
    If cTable == "SA1"
        aCampos := {;
        {"code"       , "SA1.A1_COD"   },;
        {"store"      , "SA1.A1_LOJA"  },;
        {"name"       , "SA1.A1_NOME"  },;
        {"fantasyName", "SA1.A1_NREDUZ"},;
        {"risk"       , "SA1.A1_RISCO" };
        }
    ElseIf cTable == "SC5"
        aCampos := {;
        {"num"     , "SC5.C5_NUM"   },;
        {"type"    , "SC5.C5_TIPO"  },;
        {"payment" , "SC5.C5_CONDPAG"  },;
        {"emission", "SC5.C5_EMISSAO"};
        }
    EndIf
Return aCampos
  
//-------------------------------------------------------------------
/*/{Protheus.doc} GET cardInfo
    Método para retornar os dados que podem ser apresentados pelo Card
   
    @author Squad CRM & Faturamento
    @since 13/04/2022
    @version 12.1.33
/*/
//-------------------------------------------------------------------
WSMETHOD GET cardInfo WSRESTFUL CardsCustomer
    Local aFilter       := {}
    Local cWhere        := ""
    Local nFiltro       := 0
    Local oCoreDash     := CoreDash():New()
    Local oResponse     := JsonObject():New()
   
    //Converte os campos utilizados na consulta para os campos utilizados no card.
    oCoreDash:SetFields(DePara())
   
    //Converte o Filtro informado no parametro Query String.
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()
       
    For nFiltro := 1 to Len(aFilter)
        cWhere += " AND " + aFilter[nFiltro][1]
    Next
   
    RetCardInfo(@oResponse, cWhere)
   
    self:SetResponse( EncodeUtf8(FwJsonSerialize(oResponse,.T.,.T.)) )
   
    oResponse := Nil
    FreeObj( oResponse )
   
    oCoreDash:Destroy()
    FreeObj( oCoreDash )
Return .T.
  
//-------------------------------------------------------------------
/*/{Protheus.doc} RetCardInfo
    Retorna os dados que poderão ser apresentados no painel
   
    @author Squad CRM & Faturamento
    @since 13/04/2022
    @version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function RetCardInfo(oResponse, cApiFilter)
    Local oItem
    Local aItems := {}
  
    Default cApiFilter := ""
   
    oItem := JsonObject():New()
   
    oItem["risco_a"] := RetRisco(" AND SA1.A1_RISCO = 'A' " + cApiFilter)
    oItem["risco_b"] := RetRisco(" AND SA1.A1_RISCO = 'B' " + cApiFilter)
    oItem["risco_c"] := RetRisco(" AND SA1.A1_RISCO = 'C' " + cApiFilter)
    aAdd(aItems, oItem) 
   
    oResponse['hasNext'] := 'false'
    oResponse["items"] := aItems
Return Nil
  
//-------------------------------------------------------------------
/*/{Protheus.doc} RetRisco
    Retorna os dados de acordo com o filtro
   
    @param cFiltro, Caractere, Filtro a ser adicionado na query
    @author Squad CRM & Faturamento
    @since 13/04/2022
    @version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function RetRisco(cFiltro)
    Local aQuery  := MntQuery("COUNT(SA1.A1_COD) TOTAL_REGISTROS", cFiltro)
    Local cQuery  := ""
    Local cTemp   := GetNextAlias()
    Local xRet 
  
    Default cWhere  := ""
    Default cInfo   := ""
  
    cQuery := aQuery[1] + " WHERE " + aQuery[2]
  
    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .T., .T. )
  
    xRet := (cTemp)->TOTAL_REGISTROS
  
    (cTemp)->( DBCloseArea() )
Return xRet
  
//-------------------------------------------------------------------
/*/{Protheus.doc} GET fieldsInfo
    Carrega os campos que podem que ser utilizados
   
    @author Squad CRM & Faturamento
    @since 13/04/2022
    @version 12.1.33
/*/
//-------------------------------------------------------------------
WSMETHOD GET fieldsInfo WSSERVICE CardsCustomer
    Local aItems        := {} 
    Local oResponse     :=  JsonObject():New()
    Local oCoreDash     := CoreDash():New()
   
    aAdd(aItems, { "risco_a"  , "Total clientes risco A: " })
    aAdd(aItems, { "risco_b"  , "Total clientes risco B: " })
    aAdd(aItems, { "risco_c"  , "Total clientes risco C: " })
   
    /*Retorna um Objeto no formato de Value e Label*/
    oResponse["items"] := oCoreDash:SetPOCombo(aItems)
   
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.
  
//-------------------------------------------------------------------
/*/{Protheus.doc} GET cardFilter
    Retorna os campos que poderão ser filtrados
   
    @author Squad CRM & Faturamento
    @since 13/04/2022
    @version 12.1.27
/*/
//-------------------------------------------------------------------
WSMETHOD GET cardFilter WSSERVICE CardsCustomer
    Local aFields       := {}
    Local oCoreDash     := CoreDash():New()
    Local oResponse     :=  JsonObject():New()
   
    aFields := {;
        {"code"       , "Código"       },;
        {"store"      , "Loja"         },;
        {"name"       , "Nome"         },;
        {"fantasyName", "Nome Fantasia"},;
        {"risk"       , "Risco"        };
        }
   
    oResponse["items"]      := oCoreDash:SetPOHeader(aFields)
   
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.
  
//-------------------------------------------------------------------
/*/{Protheus.doc} RetHeader
    Retorna os campos do cabeçalho dos detalhes
   
    @author Squad CRM & Faturamento
    @since 18/04/2022
    @version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function RetHeader(cTable)
    Local aHeader
    Default cTable := "SA1"
  
    If cTable == "SA1"
        aHeader := {;
            {"code"       , "Código"       , 'link',,,.T.},;
            {"store"      , "Loja"         ,,,,.T.},;
            {"name"       , "Nome"         ,,,,.T.},;
            {"fantasyName", "Nome Fantasia",,,,.T.},;
            {"risk"       , "Risco"        ,,,,.T.};
            }
    ElseIf cTable == "SC5"
        aHeader := {;
            {"num"     , "Número Pedido"        ,,,,.T.},;
            {"type"    , "Tipo Pedido"          ,,,,.T.},;
            {"payment" , "Condição de Pagamento",,,,.T.},;
            {"emission", "Emissão"              ,,,,.T.};
            }
    EndIf
Return aHeader
