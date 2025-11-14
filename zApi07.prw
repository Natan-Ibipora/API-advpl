#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'

WSRESTFUL helloworld DESCRIPTION "Meu Primeiro serviço REST!"

WSMETHOD GET DESCRIPTION "Retornar um hello world"

END WSRESTFUL

WSMETHOD GET WSSERVICE helloworld
 ::setResponse('[{"Status":"Hello World"}]')
return .T.
