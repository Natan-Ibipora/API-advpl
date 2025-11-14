#INCLUDE 'totvs.ch'
#INCLUDE "restful.ch"

WSRESTFUL thewsclass DESCRIPTION "A Classe WS para testes" FORMAT APPLICATION_JSON

WSDATA pageSize AS INTEGER OPTIONAL
WSDATA page AS INTEGER OPTIONAL
WSDATA thepathparam AS CHARACTER OPTIONAL
WSDATA path1 AS CHARACTER OPTIONAL
WSDATA path2 AS CHARACTER OPTIONAL
WSDATA theheaderparam AS CHARACTER OPTIONAL


WSMETHOD GET DESCRIPTION "Get no modelo antigo WSSYNTAX que não valida agrupamentos e nem path" WSSYNTAX "/thewsclass || /thewsclass/{id}" //Não possibilita utilizar outro GET
WSMETHOD POST ROOT DESCRIPTION "Post sem parâmetro de path" PATH "" //o PATH também poderia ser "/thewsclass"
WSMETHOD POST ID DESCRIPTION "Post com parâmetro de path anonimo" PATH "/thewsclass/{id}" //o PATH poderia ser apenas "/{id}"
WSMETHOD PUT DESCRIPTION "Put com parâmetros de path nomeados" PATH "/{path1}/fixedpart/{path2}"
WSMETHOD DELETE ROOT DESCRIPTION "Delete sem parâmetro de path" PATH "/product/group/thewsclass"
WSMETHOD DELETE ID DESCRIPTION "Delete com parâmetro de path" PATH "/product/group/thewsclass/{id}"



END WSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Get no modelo antigo WSSYNTAX que não valida agrupamentos e nem path

@author Vinicius Ledesma
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE page, pageSize WSSERVICE thewsclass
Local i

// define o tipo de retorno do método
::SetContentType("application/json")

// verifica se recebeu parametro pela URL
// exemplo: http://localhost:8080/thewsclass/1
If Len(::aURLParms) > 0

::SetResponse('{"id":"' + ::aURLParms[1] + '", "name":"thewsclass", "method":"get WSSYNTAX"}')

Else
// as propriedades da classe receberão os valores enviados por querystring
// exemplo: http://localhost:8080/thewsclass?page=1&pageSize=5
DEFAULT ::page := 1, ::pageSize := 5

// exemplo de retorno de uma lista de objetos JSON
::SetResponse('[')
For i := (::pageSize * ::page - ::pageSize + 1) To ::pageSize * ::page
If i > (::pageSize * ::page - ::pageSize + 1)
::SetResponse(',')
EndIf
::SetResponse('{"id":"' + Str(i) + '", "name":"thewsclass", "method":"get WSSYNTAX"}')
Next
::SetResponse(']')
EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST ROOT
Post sem parâmetro de path

@author Vinicius Ledesma
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD POST ROOT WSSERVICE thewsclass
Local cBody

// recupera o body da requisição
cBody := ::GetContent()

::SetResponse('{"name":"thewsclass", "method":"post root"')

If !Empty(cBody)
::SetResponse(',"body":"'+cBody+'"')
Endif

::SetResponse('}')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST ID
Post com parâmetro de path anonimo

@author Vinicius Ledesma
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD POST ID WSSERVICE thewsclass

::SetResponse('{"id":"' + ::aURLParms[1] + '", "name":"thewsclass", "method":"post id"}')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT
Put com parâmetros de path nomeados

@author Vinicius Ledesma
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD PUT PATHPARAM path1, path2 WSSERVICE thewsclass

::SetResponse('{"path1":"' + ::path1 + '","path2":"' + ::path2 + '", "urlparm1":"' + ::aURLParms[1] + '","urlparm2":"' + ::aURLParms[2] + '","name":"thewsclass", "method":"put twoparms"}')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE ROOT
Delete sem parâmetro de path

@author Vinicius Ledesma
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE ROOT WSSERVICE thewsclass

::SetResponse('{"name":"thewsclass", "method":"delete root"}')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE ROOT
Delete com parâmetro de path

@author Vinicius Ledesma
@since 05/09/2018
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE ID WSSERVICE thewsclass

::SetResponse('{"id":"' + ::aURLParms[1] + '", "name":"thewsclass", "method":"delete id"}')

Return .T.
