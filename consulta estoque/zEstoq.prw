#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
/*
    
*/
// consulta do produto
WSRESTFUL zProduto Description "Consulta produtos, sendo possivel retornar via parametros header"
   
    WsData nomeProduto as String
    WsData codigoProduto as String                 
    WsData grupoProduto as String                
    WsData grupoDesenho as String   
    WsData atualPag as Integer       
    
WSMETHOD GET DESCRIPTION "Retorno os produtos" WSSYNTAX "zProduto/" PATH "/zProduto"   

END WSRESTFUL
//recebe o produto como parametro e consulta saldo por endereco
WSRESTFUL zSaldoEndereco Description "Exemplo de Rest"  

    WsData codigoProduto as String
    WSMETHOD GET DESCRIPTION "Retorna as informacoes de saldo por endereco" WSSYNTAX "zSaldoEndereco/" PATH "/zSaldoEndereco"   

END WSRESTFUL

//Recebe produto como parametro e consulta saldo fisico
WSRESTFUL zSaldoAtual Description "Consulta de saldo fisico"  

    WsData codigoProduto as String
    WSMETHOD GET DESCRIPTION "Retorna as informacoes da tabela de saldo fisico" WSSYNTAX "zSaldoAtual/" PATH "/zSaldoAtual"   

END WSRESTFUL
WSRESTFUL zEstrutura Description "Consulta de estrutura"  

    WsData codigoProduto as String
    WSMETHOD GET DESCRIPTION "Retorna as informacoes da tabela de estrutura com base no produto" WSSYNTAX "zEstrutura/" PATH "/zEstrutura"   

END WSRESTFUL

WSRESTFUL zPdCompra Description "Consulta de informacoes do pedido de compras"  

    WsData codigoProduto as String
    WSMETHOD GET DESCRIPTION "Retorna as informacoes da tabela de pedido de compras com base no produto" WSSYNTAX "zPdCompra/" PATH "/zPdCompra"   

END WSRESTFUL

WSMETHOD GET  WSSERVICE zPdCompra
    Local lGet := .T.   
    Local cQuery 
    Local aTasks:={}    
        
    ::SetContentType("application/json")
    rpcSetType(3)

    cAlias := GetNextAlias()
   //{{{ Usada pelo Audrey no PHP }}}}
/*
$sqlX = "SELECT C7_QUANT, C7_QUJE, C7_LOCAL 
			FROM SC7010
			WHERE D_E_L_E_T_ <> '*'
			AND C7_RESIDUO = ''
			AND C7_PRODUTO = '$id'
			AND C7_QUANT > C7_QUJE ";
*/

    cQuery:=" SELECT  "
    cQuery+="   SC7.C7_QUANT, "
    cQuery+="   SC7.C7_QUJE,   "
    cQuery+="   SC7.C7_LOCAL " 
    cQuery+=" FROM "+RetSQLNAME('SC7')+" SC7 "      
    cQuery+=" WHERE "  
    cQuery+="   SC7.D_E_L_E_T_ = ' ' "
    cQuery+="   AND SC7.C7_RESIDUO = '' "
    cQuery+="   AND SC7.C7_PRODUTO ='"+AllTrim(::codigoProduto)+"'"    
    cQuery+="   AND SC7.C7_QUANT > SC7.C7_QUJE "    
    

    conout(cQuery)
    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()                     
            oTask['quantidade']             := (cAlias)-> C7_QUANT
            oTask['quantidade ja entregue'] := (cAlias)-> C7_QUJE     
            oTask['local']                  := alltrim((cAlias)-> C7_LOCAL)              
           
            aAdd(aTasks,oTask)
            (cAlias)->(DbSkip())          

        End    
        cResponse:=FWJsonSerialize(aTasks,.F.,.F.,.T.)
        ::SetResponse(cResponse)
    ELSE
        cResponse :=FWJsonSerialize(aTasks,.F.,.F., .T.) 
        ::SetResponse(cResponse)
    ENDIF
    (cAlias)->(DbCloseArea())

Return lGet

WSMETHOD GET  WSSERVICE zEstrutura
    Local lGet := .T.   
    Local cQuery 
    Local aTasks:={}    
    rpcSetType(3)
    ::SetContentType("application/json")


    cAlias := GetNextAlias()
   //{{{ Usada pelo Audrey no PHP }}}}
    // $sql = "SELECT SG1.G1_COMP, SB1.B1_UDESCNF, SG1.G1_QUANT, SG1.G1_PERDA
  	// 		FROM SG1010 SG1, SB1010 SB1 
	// 		WHERE SG1.D_E_L_E_T_ <> '*'
	// 		AND SG1.G1_COMP = SB1.B1_COD
    //     	AND SG1.G1_COD = '$id'
    //     	AND SG1.D_E_L_E_T_ <> '*'
    //     	AND SB1.D_E_L_E_T_ <> '*'
    //     	ORDER BY SG1.G1_COMP";

    cQuery:=" SELECT  "
    cQuery+="   SG1.G1_COMP, "
    cQuery+="   SB1.B1_UDESCNF,   "
    cQuery+="   SG1.G1_QUANT, "
    cQuery+="   SG1.G1_PERDA " 
    cQuery+=" FROM "+RetSQLNAME('SG1')+" SG1 " 
    cQuery+=" INNER JOIN "+RetSQLNAME('SB1')+" SB1 ON SB1.B1_COD = SG1.G1_COMP"   
    cQuery+=" WHERE "  
    cQuery+="   SB1.D_E_L_E_T_ = ' ' "
    cQuery+="   AND SG1.D_E_L_E_T_ = ' ' "
    cQuery+="   AND SG1.G1_COD ='"+AllTrim(::codigoProduto)+"'"    
    cQuery+=" ORDER BY  SG1.G1_COMP "

    conout(cQuery)
    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()                     
            oTask['componente']        := alltrim((cAlias)-> G1_COMP)
            oTask['descricao produto'] := AllTrim((cAlias)-> B1_UDESCNF)      
            oTask['quantidade']        := (cAlias)-> G1_QUANT
            oTask['indice de perda']   := (cAlias)->G1_PERDA      
           
            aAdd(aTasks,oTask)
            (cAlias)->(DbSkip())          

        End    
        cResponse:=FWJsonSerialize(aTasks,.F.,.F.,.T.)
        ::SetResponse(cResponse)
    ELSE
        cResponse :=FWJsonSerialize(aTasks,.F.,.F., .T.) 
        ::SetResponse(cResponse)
    ENDIF
    (cAlias)->(DbCloseArea())

Return lGet

//Retorna informacoes da tabela de saldo fisico
WSMETHOD GET  WSSERVICE zSaldoAtual
    Local lGet := .T.   
    Local cQuery 
    Local aTasks:={}    
        
    ::SetContentType("application/json")


    cAlias := GetNextAlias()
   //{{{ Usada pelo Audrey no PHP }}}}
    // $sql = "SELECT SB2.B2_LOCAL,SB2.B2_QATU,SB2.B2_QEMP,SB2.B2_QEMPPRE,SB2.B2_SALPEDI,NNR.NNR_DESCRI
	// 		FROM SB2010 SB2, NNR010 NNR
	// 		WHERE 1 = 1 
	// 		AND SB2.D_E_L_E_T_ <> '*'
	// 		AND NNR.D_E_L_E_T_ <> '*'
	// 		AND SB2.B2_LOCAL = NNR.NNR_CODIGO
	// 		AND SB2.B2_LOCAL <> ''
    //     	AND SB2.B2_COD = '$id'
	// 		ORDER BY SB2.B2_LOCAL";

    cQuery:=" SELECT  "
    cQuery+="   SB2.B2_LOCAL, "
    cQuery+="   SB2.B2_QATU,   "
    cQuery+="   SB2.B2_QEMP, "
    cQuery+="   SB2.B2_QEMPPRE, " 
    cQuery+="   SB2.B2_SALPEDI, " 
    cQuery+="   NNR.NNR_DESCRI" 
    cQuery+=" FROM "+RetSQLNAME('SB2')+" SB2 " 
    cQuery+=" INNER JOIN "+RetSQLNAME('NNR')+" NNR ON NNR.NNR_CODIGO=SB2.B2_LOCAL"   
    cQuery+=" WHERE "  
    cQuery+="   SB2.D_E_L_E_T_ = ' ' "
    cQuery+="   AND NNR.D_E_L_E_T_ =' '  "
    cQuery+="   AND SB2.B2_LOCAL <> ' ' "
    cQuery+="   AND SB2.B2_COD ='" + alltrim(::codigoProduto) +"' "
    cQuery+=" ORDER BY  SB2.B2_LOCAL "

    conout(cQuery)
    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()            
            oTask['armazem']             := alltrim((cAlias)->B2_LOCAL)         
            oTask['saldo atual']         := (cAlias)-> B2_QATU
            oTask['empenho']             := (cAlias)-> B2_QEMP           
            oTask['empenho previsto']    := (cAlias)-> B2_QEMPPRE
            oTask['quantidade prevista'] := (cAlias)-> B2_SALPEDI
            oTask['descricao armazem']   := alltrim((cAlias)->NNR_DESCRI)          
                       
           
            aAdd(aTasks,oTask)
            (cAlias)->(DbSkip())          

        End    
        cResponse:=FWJsonSerialize(aTasks,.F.,.F.,.T.)
        ::SetResponse(cResponse)
    ELSE
        cResponse :=FWJsonSerialize(aTasks,.F.,.F., .T.) 
        ::SetResponse(cResponse)
    ENDIF
    (cAlias)->(DbCloseArea())

Return lGet

WSMETHOD GET  WSSERVICE zSaldoEndereco
    Local lGet := .T.   
    Local cQuery 
    Local aTasks:={}    
        
    ::SetContentType("application/json")


    cAlias := GetNextAlias()
    //{{{ Usada pelo Audrey no PHP }}}}
    // $sql = "SELECT SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_QUANT
// 					  FROM SBF010 SBF
// 					  WHERE D_E_L_E_T_ <> '*'
// 					  AND SBF.BF_PRODUTO = '$id'
// 					  ORDER BY SBF.BF_LOCALIZ ";

    cQuery:=" SELECT  "
    cQuery+="   SBF.BF_PRODUTO, "
    cQuery+="   SBF.BF_LOCAL,   "
    cQuery+="   SBF.BF_LOCALIZ, "
    cQuery+="   SBF.BF_QUANT    " 
    cQuery+=" FROM "+RetSQLNAME('SBF')+" SBF "    
    cQuery+=" WHERE "   
    cQuery+="   SBF.BF_FILIAL='01' "
    cQuery+="   AND SBF.D_E_L_E_T_= ' ' "
    cQuery+="   AND SBF.BF_PRODUTO ='" + alltrim(::codigoProduto) +"' "
    cQuery+=" ORDER BY  SBF.BF_LOCALIZ "

    conout(cQuery)
    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()
            oTask['codigo']     :=alltrim((cAlias)-> BF_PRODUTO)           
            oTask['armazem']    := alltrim((cAlias)-> BF_LOCAL)
            oTask['endereco']   := alltrim((cAlias)-> BF_LOCALIZ)            
            oTask['quantidade'] :=(cAlias)-> BF_QUANT
           
                       
           
            aAdd(aTasks,oTask)
            (cAlias)->(DbSkip())          

        End    
        cResponse:=FWJsonSerialize(aTasks,.F.,.F.,.T.)
        ::SetResponse(cResponse)
    ELSE
        cResponse :=FWJsonSerialize(aTasks,.F.,.F., .T.) 
        ::SetResponse(cResponse)
    ENDIF
    (cAlias)->(DbCloseArea())

Return lGet

WSMETHOD GET  WSSERVICE zProduto
    Local lGet := .T.   
    Local cQuery 
    Local aTasks:={}  
    rpcSetType(3)
    ::SetContentType("application/json")
    //{{{ Usada pelo Audrey no PHP }}}}
//  $sql = "SELECT B1_COD, B1_UCODDES, B1_UGRUDES, B1_GRUPO, B1_UDESCNF, B1_MSBLQL, D_E_L_E_T_ FROM "
// 				. "(SELECT B1_COD, B1_UCODDES, B1_UGRUDES, B1_GRUPO, B1_UDESCNF, B1_MSBLQL, SB1.D_E_L_E_T_, "
// 				. "ROW_NUMBER() OVER (ORDER BY B1_COD) AS ROW "
// 				. "FROM SB1010 SB1 WHERE SB1.D_E_L_E_T_ <> '*' $z) "
// 				. "a WHERE ROW > $inicio AND ROW <= $fim "
// 				. "AND D_E_L_E_T_ <> '*' $z";

    cAlias := GetNextAlias()
    IF Empty(::atualPag)
        cQuery:=" SELECT  TOP 40 "
    ELSE
        cQuery:=" SELECT  "
    ENDIF

    cQuery+="   B1_COD, "
    cQuery+="   B1_UCODDES, "
    cQuery+="   B1_UGRUDES, "
    cQuery+="   B1_GRUPO, "
    cQuery+="   B1_UDESCNF, "  
    cQuery+="   B1_MSBLQL,  " 
    //SUBQUERY PARA RETORNAR O TOTAL DE ITENS
    cQuery+="( SELECT COUNT(*) FROM "+ RetSQLNAME('SB1') + " SB1 WHERE "  
    cQuery+="   SB1.B1_FILIAL=' ' "
    cQuery+="   AND SB1.D_E_L_E_T_= ' ' "
        IF !Empty(::nomeProduto) 
            cQuery+= " AND SB1.B1_UDESCNF LIKE  '%"+ UPPER(alltrim(::nomeProduto)) +"%'"
        ENDIF
        IF !Empty(::codigoProduto) 
            cQuery+= " AND SB1.B1_COD LIKE  '%"+ UPPER(alltrim(::codigoProduto)) +"%'"
        ENDIF
        IF !Empty(::grupoProduto) 
            cQuery+= " AND SB1.B1_GRUPO LIKE  '%"+ UPPER(alltrim(::grupoProduto)) +"%'"
        ENDIF
        IF !Empty(::grupoDesenho) 
            cQuery+= " AND SB1.B1_UGRUDES LIKE  '%"+ UPPER(alltrim(::grupoDesenho)) +"%'"
        ENDIF
    cQuery+=" ) AS TOTAL_REGISTROS "
    //FIM TOTAL SUBQUERY
    cQuery+=" FROM "+RetSQLNAME('SB1')+" SB1 "    
    cQuery+=" WHERE "   
    cQuery+="   SB1.B1_FILIAL=' ' "
    cQuery+="   AND SB1.D_E_L_E_T_= ' ' "
    IF !Empty(::nomeProduto) 
        cQuery+= " AND SB1.B1_UDESCNF LIKE  '%"+ UPPER(alltrim(::nomeProduto)) +"%'"
    ENDIF
    IF !Empty(::codigoProduto) 
        cQuery+= " AND SB1.B1_COD LIKE  '%"+ UPPER(alltrim(::codigoProduto)) +"%'"
    ENDIF
    IF !Empty(::grupoProduto) 
        cQuery+= " AND SB1.B1_GRUPO LIKE  '%"+ UPPER(alltrim(::grupoProduto)) +"%'"
    ENDIF
    IF !Empty(::grupoDesenho) 
        cQuery+= " AND SB1.B1_UGRUDES LIKE  '%"+ UPPER(alltrim(::grupoDesenho)) +"%'"
    ENDIF

    cQuery+=" ORDER BY  R_E_C_N_O_ DESC "  

    
    IF !Empty(::atualPag) 
        cQuery +=" OFFSET " + cValToChar(::atualPag * 40) +" ROWS FETCH NEXT 40  ROWS ONLY "
    END
    conout(cQuery)
    cQuery:= ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAlias)

    IF (cAlias)->(!Eof())
        While (cAlias) ->(!Eof())

            oTask :=JsonObject():New()
            oTask['codigo']:=alltrim((cAlias)-> B1_COD)
            IF alltrim((cAlias)->B1_UCODDES) == ""
                oTask['desenho']:= "N/A"
            ELSE
                oTask['desenho']:= alltrim((cAlias)->B1_UCODDES)
            ENDIF
            oTask['grupo desenho'] := alltrim((cAlias)->B1_UGRUDES)
            oTask['grupo produto'] := alltrim((cAlias)->B1_GRUPO)
            oTask['descricao']     := alltrim((cAlias)->B1_UDESCNF)
            oTask['bloqueado']     := alltrim((cAlias)->B1_MSBLQL)
            oTask['total registros'] := cValToChar((cAlias)->TOTAL_REGISTROS)

            aAdd(aTasks,oTask)
            (cAlias)->(DbSkip())          

        End    
        cResponse:=FWJsonSerialize(aTasks,.F.,.F.,.T.)
        ::SetResponse(cResponse)
    ELSE
        cResponse :=FWJsonSerialize(aTasks,.F.,.F., .T.) 
        ::SetResponse(cResponse)
    ENDIF
    (cAlias)->(DbCloseArea())

Return lGet

