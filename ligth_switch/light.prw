#include "totvs.ch"

/*/	-----------------------------------------------------------------/
Exemplo para montagem de um componente hibrido AdvPL/HTML
/-------------------------------------------------------------------*/
function u_light()
local i, oDlg, cFile, nHandle, globalLink
local oFont1 := TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
local aFiles := {"jquery-1.10.2.min.js",;
				"totvstec.js",;
				"sala.jpg",;
				"lightbulb.png",;
				"ligth.html";
				}
local tempPath := GetTempPath()
private oWebChannel, oMultGet, oMobile
oDlg := TWindow():New(10, 10, 200, 200, "WebEngine - Ligth")
oDlg:setCss("QPushButton{borderDummy: 1px solid black;}")

    // Baixa arquivos do RPO no TEMP
	for i := 1 to len(aFiles)
		cFile :=  + aFiles[i]
		nHandle := fCreate(tempPath+cFile)
		fWrite(nHandle, getApoRes(aFiles[i]))
        fClose(nHandle)
	next i
		
	// Painel de botoes
    @ 000, 000 MSPANEL pLeft SIZE 092, 400 OF oDlg COLORS 0, 16777215 RAISED
    
    // Botoes
    @ 000, 000 MSPANEL topBtn SIZE 050, 20 PROMPT "Comandos AdvPL" OF pLeft COLORS 16777215, 8342016 CENTERED RAISED FONT oFont1
    btnHeight := 34
    @ 000, 000 BUTTON oButton1 PROMPT "Quarto";
      SIZE btnHeight, btnHeight FONT oFont1 OF pLeft PIXEL;
      ACTION ( oWebEngine:runJavaScript("changeState('#Quarto', '#c1');") ) 
    @ 000, 000 BUTTON oButton2 PROMPT "Cozinha";
      SIZE btnHeight, btnHeight FONT oFont1 OF pLeft PIXEL;
      ACTION ( oWebEngine:runJavaScript("changeState('#Cozinha', '#c2');") ) 
    @ 000, 000 BUTTON oButton3 PROMPT "Banheiro";
      SIZE btnHeight, btnHeight FONT oFont1 OF pLeft PIXEL;
      ACTION ( oWebEngine:runJavaScript("changeState('#Banheiro', '#c3');") ) 
       
    // TWebChannel eh responsavel pelo trafego SmartClient/HTML
    oWebChannel := TWebChannel():New()
    oWebChannel:connect()
    if !oWebChannel:lConnected
    	msgStop("Erro na conexao com o WebSocket")
    	return
    endif
    
    // IMPORTANTE: Aqui definimos a porta WebSocket que sera utilizada
    //globalLink := "http://127.0.0.1:8080/ligth/ligth.html?port=" + cValToChar(oWebChannel:nPort)
    globalLink := tempPath + "ligth.html?port=" + cValToChar(oWebChannel:nPort)
    conout(globalLink)

    // Toda acao JavaScript enviada atraves do comando dialog.jsToAdvpl()
    // serah recebida/tratada por esta bloco de codigo
	oWebChannel:bJsToAdvpl := {|self,codeType,codeContent|;
	   jsToAdvpl(self,codeType,codeContent) } 
	
	// Componente que sera utilizado como Navegador embutido
	oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100)
	oWebEngine:navigate(globalLink)
    
    pLeft:Align := CONTROL_ALIGN_LEFT
    topBtn:Align := CONTROL_ALIGN_TOP
    oButton1:Align := CONTROL_ALIGN_TOP
    oButton2:Align := CONTROL_ALIGN_TOP
    oButton3:Align := CONTROL_ALIGN_TOP
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    
oDlg:Activate("MAXIMIZED")
Return

/*/	-----------------------------------------------------------------/
Bloco de codigo que recebera as chamadas JavaScript
/-------------------------------------------------------------------*/
static function jsToAdvpl(self,codeType,codeContent)
	// Exibe mensagens trocadas
	conout( ": " + codeContent )
			
	// Termino da carga da pagina HTML
	if codeType == "pageStarted"
	endif
	
return
