#include "totvs.ch"
#include "tbiconn.ch"
//Utilifazand o pfwrest do odair
User function zApi03 ()
 Local oRest:= pfwRest():New()
 Local cResult
 Local oParseJSON
 Local cNome
 Local nLenJson
 Local i
 oRest:SetEndPoint("http://192.168.246.12:8097/rest/users/000001")
 oRest:AddHeader("Authorization: Basic " + Encode64('natan-santos'+':'+'1234'))
 oRest:AddHeader("Content-Type: application/json")
 oRest:AddHeader("Content-Encoding: gzip")
cResult:= oRest:Get()

oParseJSON := JsonObject():New()
oParseJSON:FromJSon(cResult)
nLenJson:=len(oParseJSON)
IF nLenJson>0
 for i:=1 to nLenJson
 next
ENDIF
//colocar o codigo aqui
        //cAux :=1
IF valtype(oParseJSON['displayName']) == "C"
  cNome:=oParseJSON['displayName']
ELSE
   cNome:=cValToChar(oParseJSON['displayName'])
ENDIF
alert(cNome)

 
return 
