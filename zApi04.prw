user function zApi04()
local oRestClient as object
local aHeadOut:={}
Local cResult
Local aNomes
Local nTam
Local oParseJSON
Local ret
oRestClient := FWRest():New("http://192.168.246.12:8097/rest")
oRestClient:setPath("/api/framework/v1/genericQuery?TABLES=SED&FIELDS=ED_CODIGO,ED_DESCRIC&WHERE=SED.D_E_L_E_T_=''")

Aadd(aHeadOut, "Authorization: Basic " + Encode64('natan-santos'+':'+'1234'))
Aadd(aHeadOut, "Content-Type: application/json")
Aadd(aHeadOut, "Content-Encoding: gzip")


if oRestClient:Get(aHeadOut)
   ConOut(oRestClient:GetResult())
   cResult:=oRestClient:GetResult()
else
   ConOut(oRestClient:GetLastError())
endif

oParseJSON := JsonObject():New()
ret:=oParseJSON:FromJSon(oRestClient:GetResult())
if ValType(ret) == "U"
    Conout("JsonObject populado com sucesso")
  else
    Conout("Falha ao popular JsonObject. Erro: " + ret)
  endif
aNomes:= oParseJSON['items']
nTam:=len(aNomes)

 
return
