#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
/*
    Este fonte usa a tabela SYS_USR (De usuários) e SYS_USR_MODULE (tabeça que mostra a relação entre usuário e menu)
    Faz um Inner JOIN e retorna um JSON para ser consumido através do Excel.
*/

WSRESTFUL zWUm Description "API para retorno de usuarios do protheus"       

    WSMETHOD GET DESCRIPTION "Retorna os usuarios" WSSYNTAX "zWUm/" PATH "/zWUm"      
    
END WSRESTFUL

L
//Pega todos os registros da tabela CTT;
WSMETHOD GET  WSSERVICE zWUm
    Local lPost := .T.   
    Local cQuery 
    Local aTasks:={}    
    
    ::SetContentType("application/json")

    cAlias := GetNextAlias()
    cQuery :="SELECT "
    cQuery +="      SYS_USR_MODULE.USR_ID,"
    cQuery +="      SYS_USR.USR_CODIGO,"    
    cQuery +="      SYS_USR.USR_DEPTO,"    
    cQuery +="      SYS_USR_MODULE.USR_MODULO,"    
    cQuery +="      SYS_USR_MODULE.USR_CODMOD,"    
    cQuery +="      SYS_USR_MODULE.USR_ACESSO"    
    cQuery +=" FROM "
    cQuery +="      SYS_USR_MODULE "
    cQuery +=" INNER JOIN "
    cQuery +="      SYS_USR  ON SYS_USR.USR_ID = SYS_USR_MODULE.USR_ID "
    cQuery +=" WHERE "
    cQuery +="      SYS_USR_MODULE.D_E_L_E_T_=' ' AND SYS_USR.D_E_L_E_T_=' ' AND SYS_USR.USR_MSBLQL='2' "

    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()
            oTask['IdUsuario']      :=    alltrim(((cAlias)->USR_ID))
            oTask['NomeUsuario']    :=    alltrim(((cAlias)->USR_CODIGO))
            oTask['Departamento']   :=    alltrim(((cAlias)->USR_DEPTO))
            oTask['IdModulo']       :=    alltrim(((cAlias)->USR_MODULO))
            oTask['NomeModulo']     :=    alltrim(((cAlias)->USR_CODMOD))
            oTask['Acesso[T/F]']    :=    alltrim(((cAlias)->USR_ACESSO))
                    
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


