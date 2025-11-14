#INCLUDE 'totvs.ch'
#INCLUDE "restful.ch"

WSRESTFUL insertZZ8 DESCRIPTION "A Classe  para inserir na ZZ8" FORMAT APPLICATION_JSON

WSDATA NOME AS CHARACTER OPTIONAL
WSDATA DATA AS CHARACTER OPTIONAL
WSDATA NOMEPROD AS CHARACTER OPTIONAL
WSDATA QTD AS INTEGER OPTIONAL


WSMETHOD GET DESCRIPTION "Get " //Não possibilita utilizar outro GET
WSMETHOD POST ROOT DESCRIPTION "Post sem parâmetro de path" 
WSMETHOD PUT DESCRIPTION "Put " 
WSMETHOD DELETE ROOT DESCRIPTION "Delete " 

END  WSRESTFUL

WSMETHOD GET WSRECEIVE page, pageSize WSSERVICE insertZZ8
Local i

// define o tipo de retorno do método
::SetContentType("/rest/ZZ8")

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
