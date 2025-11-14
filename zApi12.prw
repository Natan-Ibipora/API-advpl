#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
/*
    Este fonte usa a tabela CTT(centro de custos)  e SR6(turnos)
*/

WSRESTFUL zWCc Description "API para o vagas rh Centro de custo"       

    WSMETHOD GET DESCRIPTION "Retorna os centro de custos" WSSYNTAX "zWCc/" PATH "/zWCc"      
    
END WSRESTFUL

WSRESTFUL zWTurn Description "API para o vagas rh turnos"    

    WSMETHOD GET DESCRIPTION "Retorna os turnos  " WSSYNTAX "zWTurn/" PATH "/zWTurn" 

END WSRESTFUL
//Pega todos os registros da tabela CTT;
WSMETHOD GET  WSSERVICE zWCc
    Local lPost := .T.   
    Local cQuery 
    Local aTasks:={}    
    
    ::SetContentType("application/json")

    cAlias := GetNextAlias()
    cQuery:=" SELECT "
    cQuery+="  CTT_CUSTO, "
    cQuery+="   CTT_DESC01 "    
    cQuery+=" FROM "+RetSQLNAME('CTT')+" CTT "
    cQuery+=" WHERE "
    cQuery+="   CTT.CTT_FILIAL=' ' "
    cQuery+="   AND CTT.D_E_L_E_T_= ' ' "
    cQuery+="   AND CTT.CTT_BLOQ = '2' "

    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()
            oTask['CENTRO DE CUSTO']:=(cAlias)->CTT_CUSTO
            oTask['DESCRICAO']:=alltrim((cAlias)->CTT_DESC01)            
            aAdd(aTasks,oTask)
            (cAlias)->(DbSkip())

        End    
        cResponse:=FWJsonSerialize(aTasks,.F.,.F.,.T.)
        ::SetResponse(cResponse)        
    ELSE
        cResponse :=FWJsonSerialize(aTasks,.F.,.F., .T.)         
        SetRestFault(400,"Erro ao listar os centros de custo")
        (cAlias)->(DbCloseArea())
        Return .F.
    ENDIF
    (cAlias)->(DbCloseArea())

Return lPost


WSMETHOD GET  WSSERVICE zWTurn
    Local lPost := .T.   
    Local cQuery 
    Local aTasks:={}    
    
    ::SetContentType("application/json")

    cAlias := GetNextAlias()
    cQuery:=" SELECT "
    cQuery+="  SR6.R6_TURNO, "
    cQuery+="  SR6.R6_DESC "      
    cQuery+=" FROM "+RetSQLNAME('SR6')+" SR6 "
    cQuery+=" WHERE "
    cQuery+="   SR6.R6_FILIAL=' ' "
    cQuery+="   AND SR6.D_E_L_E_T_= ' ' "
    cQuery+="   AND SR6.R6_MSBLQL= '2' "
    cQuery+="   OR SR6.R6_MSBLQL= ' ' "

    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()      
            oTask['CODIGO']:=alltrim((cAlias)->R6_TURNO)            
            oTask['DESCRICAO']:=alltrim((cAlias)->R6_DESC)            
            aAdd(aTasks,oTask)
            (cAlias)->(DbSkip())

        End    
        cResponse:=FWJsonSerialize(aTasks,.F.,.F.,.T.)
        ::SetResponse(cResponse)        
    ELSE
        cResponse :=FWJsonSerialize(aTasks,.F.,.F., .T.)         
        SetRestFault(400,"Erro ao listar os turnos")
        (cAlias)->(DbCloseArea())
        Return .F.
    ENDIF
    (cAlias)->(DbCloseArea())

Return lPost
