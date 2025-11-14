user function zApi01()
local oRestClient as object
 
oRestClient := FWRest():New("http://code.google.com")
oRestClient:setPath("/p/json-path/")
 
if oRestClient:Get()
   ConOut(oRestClient:GetResult())
else
   ConOut(oRestClient:GetLastError())
endif
 
return
