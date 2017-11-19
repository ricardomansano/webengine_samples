#include "totvs.ch"

/*/	-----------------------------------------------------------------/
Exemplo para montagem de um componente hibrido AdvPL/HTML
/-------------------------------------------------------------------*/
function u_thf()
local i, oDlg, cFile, nHandle, globalLink
local oFont1 := TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
private oWebChannel, oMultGet, oMobile

oDlg := TWindow():New(10, 10, 800, 600, "WebEngine - THF")
oDlg:setCss("QPushButton{borderDummy: 1px solid black;}")

    // TWebChannel eh responsavel pelo trafego SmartClient/HTML
    oWebChannel := TWebChannel():New()
    oWebChannel:connect()
    if !oWebChannel:lConnected
    	msgStop("Erro na conexao com o WebSocket")
    	return
    endif
    
    // IMPORTANTE: Aqui definimos a porta WebSocket que sera utilizada
    globalLink := "https://thf.totvs.com.br/#/documentation/api/totvsDateRange/object/totvsDateRangeConstant"
    conout(globalLink)

    // Toda acao JavaScript enviada atraves do comando dialog.jsToAdvpl()
    // serah recebida/tratada por esta bloco de codigo
	oWebChannel:bJsToAdvpl := {|self,codeType,codeContent|;
	   jsToAdvpl(self,codeType,codeContent) } 
	
	// Componente que sera utilizado como Navegador embutido
	oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100)
	oWebEngine:navigate(globalLink)
    
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    
oDlg:Activate("MAXIMIZED")
Return

/*/	-----------------------------------------------------------------/
Bloco de codigo que recebera as chamadas JavaScript
/-------------------------------------------------------------------*/
static function jsToAdvpl(self,codeType,codeContent)
	// Exibe mensagens trocadas
	conout("",;
		   ": " + codeType,;
		   ": " + codeContent)
			
	// Termino da carga da pagina HTML
	if codeType == "pageStarted"
	endif
	
return
