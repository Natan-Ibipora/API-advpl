#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL zWSB1 Description "Exemplo de Rest"   
    
   
    WSMETHOD POST  DESCRIPTION "Realiza uma postagem dos dados no SB1" WSSYNTAX "zWSB1/" PATH "/zWSB1"
   

END WSRESTFUL
/*
B1_GRUPO, B1_USGRUPO, B1_DESC,B1_UDESCNF,B1_TIPO,B1_UM,B1_UNATURE,B1_ORIGEM,B1_LOCPAD
*/

WSMETHOD POST   WSSERVICE zWSB1
    Local aArea := GetArea()
    Local lPost:=.T.
    Local y
    Local x
    Local aVetor := {}
    Local cResponse
    Local oRequest:=JsonObject():New()
    private lMsErroAuto := .F.
    
    ::SetContentType("application/json")
    oRequest:fromJson(::GetContent())
    DBSelectArea('SB1')         
    aVetor:= { {"B1_GRUPO" ,oRequest['B1_GRUPO'] ,NIL},;
    {"B1_USGRUPO" ,oRequest['B1_USGRUPO'] ,NIL},;
    {"B1_DESC" ,substr(oRequest['B1_DESC'],1,TamSx3("B1_DESC")[1]) ,Nil},;
    {"B1_UDESCNF" ,substr(oRequest['B1_UDESCNF'],1,TamSx3("B1_UDESCNF")[1]) ,Nil},;
    {"B1_TIPO" ,oRequest['B1_TIPO'] ,Nil},;
    {"B1_UM" ,oRequest['B1_UM'] ,Nil},;
    {"B1_UNATURE" ,oRequest['B1_UNATURE'] ,Nil},;
    {"B1_ORIGEM" ,oRequest['B1_ORIGEM'],Nil},;
    {"B1_LOCPAD" ,oRequest['B1_LOCPAD'] ,Nil},;
    {"B1_POSIPI",oRequest['B1_POSIPI'],NIL}}
    
    MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
    
    If !lMsErroAuto
        lPost:=.T.
        cResponse:="Produto inserido com sucesso"
        ::SetResponse(cResponse)
    Else
    cArqLog :=  "ERRO - " + SubStr( Time(),1,5 ) + ".log"
        
 //         MostraErro("\logs\",cArqLog)
  
        lPost:=.F.
        cResponse:="Falha ao inserir produto"
        ::SetResponse(cResponse)
    Endif
    restArea(aArea)
Return lPost


 

 /*
B1_GRUPO, B1_USGRUPO, B1_DESC,B1_UDESCNF,B1_TIPO,B1_UM,B1_UNATURE,B1_ORIGEM,B1_LOCPAD
*/
//--- Exemplo: Inclusao --- //
// aVetor:= { {"B1_GRUPO" ,oResponse['B1_GRUPO'] ,NIL},;
//  {"B1_USHRUPO" ,oResponse['B1_USGRUPO'] ,NIL},;
//  {"B1_DESC" ,oResponse['B1_DESC'] ,Nil},;
//  {"B1_UDESCNF" ,oResponse['B1_UDESCNF'] ,Nil},;
//  {"B1_TIPO" ,oResponse['B1_TIPO'] ,Nil},;
//  {"B1_UM" ,oResponse['B1_UM'] ,Nil},;
//  {"B1_UNATURE" ,oResponse['B1_UNATURE'] ,Nil},;
//  {"B1_ORIGEM" ,oResponse['B1_ORIGEM'],Nil},;
//  {"B1_LOCAPAD" ,oResponse['B1_LOCAPAD'] ,Nil}}
  
// MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
 
// If lMsErroAuto
 
// Else
 
// Endif
 