user function zApi02()
local oRestClient as object
local aHeadOut:={}
oRestClient := FWRest():New("http://192.168.246.12:8097")
oRestClient:setPath("/rest/users/000001")

Aadd(aHeadOut, "Authorization: Basic " + Encode64('natan-santos'+':'+'1234'))
Aadd(aHeadOut, "Content-Type: application/json")
Aadd(aHeadOut, "Content-Encoding: gzip")

if oRestClient:Get(aHeadOut)
   ConOut(oRestClient:GetResult())
else
   ConOut(oRestClient:GetLastError())
endif
 
return
