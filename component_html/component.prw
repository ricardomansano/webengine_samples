#include "totvs.ch"

/*/	-----------------------------------------------------------------/
Exemplo para montagem de um componente hibrido AdvPL/HTML
/-------------------------------------------------------------------*/
function u_CompHtml()
local i, oDlg, cFile, nHandle, globalLink
local aFiles := {"bootstrap.min.css",;
				"jquery-1.10.2.min.js",;
				"totvstec.js",;
				"style.css",;
				"component.html",;
				"img_avatar1.png",;
				"img_avatar2.png",;
				"img_avatar3.png",;
				"img_avatar4.png",;
				"img_avatar5.png",;
				"img_avatar6.png"}
local tempPath := GetTempPath()
local cOS := getOS()
local oFont1 := TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
private oWebChannel, oMultGet, oCompHTML, oMobile

oDlg := TWindow():New(10, 10, 800, 600, "TOTVS - Demonstracao de componente Hibrido")
oDlg:setCss("QPushButton{borderDummy: 1px solid black;}")

    // Nos dispositivos moveis os arquivos Web ficam na
    // pasta ASSETS e nao precisam ser baixados do RPO 
    if cOS == "ANDROID" .or. cOS == "IPHONEOS"
    	oMobile := TMobile():New()
    	oMobile:SetScreenOrientation(-1)

    	// Essa pasta sera sempre padrao, pra todos os apps gerados
    	if cOS == "ANDROID"
    		tempPath := "file:///android_asset/web/"
    	else
    		tempPath := GetPvProfString("ENVIRONMENT", "ASSETSPATH", "Erro", GetSrvIniName()) + "/web/"
    	endif
    else
	    // Baixa arquivos do RPO no TEMP
		for i := 1 to len(aFiles)
			cFile :=  + aFiles[i]
			nHandle := fCreate(tempPath+cFile)
			fWrite(nHandle, getApoRes(aFiles[i]))
	        fClose(nHandle)
		next i
	endif

	// Painel de botoes
    @ 000, 000 MSPANEL pLeft SIZE 092, 400 OF oDlg COLORS 0, 16777215 RAISED
    @ 000, 000 MSPANEL topBtn SIZE 050, 20 PROMPT "Comandos AdvPL" OF pLeft COLORS 16777215, 8342016 CENTERED RAISED FONT oFont1
    @ 000, 000 BUTTON oButton2 PROMPT "Insere Registros" SIZE 091, 020 OF pLeft FONT oFont1 PIXEL ACTION ( oCompHTML:insere() ) 
    @ 013, 000 BUTTON oButton3 PROMPT "Deleta Primeiro"  SIZE 091, 020 OF pLeft FONT oFont1 PIXEL ACTION ( oCompHTML:deleta() ) 
    @ 013, 000 BUTTON oButton4 PROMPT "Conta"  			 SIZE 091, 020 OF pLeft FONT oFont1 PIXEL ACTION ( jsAlert("Count()", cValTochar(oCompHTML:count())+" registros incluidos") ) 
       
    // Habilito o botao para captura de imagens apenas no Android
    if cOS == "ANDROID"
	    @ 013, 000 BUTTON oButton5 PROMPT "TakePicture"  SIZE 091, 012 OF pLeft PIXEL;
	       ACTION ( TakePicture() ) 
    endif
       
    // TWebChannel eh responsavel pelo trafego SmartClient/HTML
    oWebChannel := TWebChannel():New()
    oWebChannel:connect()
    if !oWebChannel:lConnected
    	msgStop("Erro na conexao com o WebSocket")
    	return
    endif
    
    // IMPORTANTE: Aqui definimos a porta WebSocket que sera utilizada
    globalLink := tempPath + "component.html?port=" + cValToChar(oWebChannel:nPort)

    // Toda acao JavaScript enviada atraves do comando dialog.jsToAdvpl()
    // serah recebida/tratada por esta bloco de codigo
	oWebChannel:bJsToAdvpl := {|self,codeType,codeContent|;
	   jsToAdvpl(self,codeType,codeContent) } 
	
	// Componente que sera utilizado como Navegador embutido
	oCompHTML := compHTML():New(oDlg, 0, 0, 100, 100)
	oCompHTML:oWebEngine:navigate(globalLink)
    
    pLeft:Align := CONTROL_ALIGN_LEFT
    topBtn:Align := CONTROL_ALIGN_TOP
    oButton2:Align := CONTROL_ALIGN_TOP
    oButton3:Align := CONTROL_ALIGN_TOP
    oButton4:Align := CONTROL_ALIGN_TOP
    if cOS == "ANDROID"
    	oButton5:Align := CONTROL_ALIGN_TOP
    endif
    oCompHTML:oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    
oDlg:Activate()//("MAXIMIZED")
Return

/*/	-----------------------------------------------------------------/
Captura imagem caso esteja executando no dispocitivo movel
Mais informacoes em: http://tdn.totvs.com/display/tec/TMobile
/-------------------------------------------------------------------*/
static function TakePicture()
	cFile := oMobile:TakePicture(0)
	conout("Imagem capturada", cFile)
	oCompHTML:oWebEngine:navigate(cFile)
return

/*/	-----------------------------------------------------------------/
Retorna o SO
/-------------------------------------------------------------------*/
static function getOS()
local stringOS := Upper(GetRmtInfo()[2])

	// Retorna SO em execucao
	if ("ANDROID" $ stringOS)
    	return "ANDROID" 
	elseif ("IPHONEOS" $ stringOS)
		return "IPHONEOS"
	elseif GetRemoteType() == 0 .or. GetRemoteType() == 1
		return "WINDOWS"
	elseif GetRemoteType() == 2 
		return "UNIX" // Linux ou MacOS		
	elseif GetRemoteType() == 5 
		return "HTML" // Smartclient HTML		
	endif
	
return ""

/*/	-----------------------------------------------------------------/
Bloco de codigo que recebera as chamadas JavaScript
/-------------------------------------------------------------------*/
static function jsToAdvpl(self,codeType,codeContent)
	// Exibe mensagens trocadas
	conout("",;
		   ": " + codeType,;
		   ": " + codeContent)
			
	// Apaga item via JavaScript	
	if codeType == "deleteItem"
		oCompHTML:nCount--
	endif
	
	// Termino da carga da pagina HTML
	if codeType == "pageStarted"
	    // Insere JavaScript para delecao dos Itens
	    // --------------------------------------------------------------------------------
	    // Serao 2: 1o Apaga o primeiro item via AdvPL
	    //          2o Apaga o item atraves do botao fechar via JavaSvript (pra cada item)
	    // --------------------------------------------------------------------------------
	    // *IMPORTANTE: Nao utilize comentarios ao inserir o codigo JavaScript
	    BeginContent var cFunction
	    	function removeFirstPanel() {
                var lenItems = document.getElementById("mainPanel").childNodes.length;
                for (i=0; i<lenItems; i++) {
                    if (document.getElementById("mainPanel").childNodes[i].id == "panelID") {
                        document.getElementById("mainPanel").childNodes[i].remove();
                        break;
                    }                   
                }
	    	}
	    
	    	function removePanel(obj, objDeleted) {
	    		obj.parentElement.parentElement.remove();
	    		dialog.jsToAdvpl("deleteItem", "Objeto deletado: " + objDeleted);
	    	}
	    endContent
		oWebChannel:advplToJs("js", cFunction)	
	endif
	
return

/*/	-----------------------------------------------------------------/
Alert que sera executado via JavaScript
/-------------------------------------------------------------------*/
static function jsAlert(cTitle, cText)
	oCompHTML:oWebEngine:runJavaScript('jsAlert("' +cTitle+ '", "' +cText+ '");')
return

/*/	-----------------------------------------------------------------/
Classe AdvPL para manipula��o do componente
/-------------------------------------------------------------------*/
class compHTML
	Data nCount
	Data nCountCreated
	Data oWebEngine
		
	Method new(oWnd,nRow,nCol,nWidth,nHeight,cUrl) CONSTRUCTOR
	Method count()
	Method insere()
	Method deleta()
endClass
	
/*/	-----------------------------------------------------------------/
Construtor
/-------------------------------------------------------------------*/
//Method New(oWnd,nRow,nCol,nWidth,nHeight,cUrl) class compHTML
//:New(oWnd,nRow,nCol,nWidth,nHeight,cUrl)
Method New(oWnd,nRow,nCol,nWidth,nHeight,cUrl) class compHTML
	::oWebEngine := TWebEngine():New(oWnd,nRow,nCol,nWidth,nHeight,cUrl)
	::nCount := 0
	::nCountCreated := 1
return

/*/	-----------------------------------------------------------------/
Retorna nr de registros
/-------------------------------------------------------------------*/
Method count() class compHTML
return ::nCount

/*/	-----------------------------------------------------------------/
Insere registros
/-------------------------------------------------------------------*/
Method insere() class compHTML
local cAvatar, cField, cImage, i
local imgCount := 0

	for i := ::nCountCreated to ::nCountCreated+5
		imgCount++
		cImage  := cValToChar(imgCount)
		cAvatar := cValToChar(i)

		// Insere Itens
		BeginContent var cField
			<div id="panelID" class="panel panel-default" style="border-spacing:5px;">
		       <div class="media-left"><img onclick="dialog.jsToAdvpl('selectedItem', 'Objeto selecionado: '+'%Exp:cAvatar%');" src="img_avatar%Exp:cImage%.png" class="media-object" style="width:60px"></div>
		       <div class="media-body">
		           <button class="close" onclick="removePanel(this, '%Exp:cAvatar%');">
		               <span aria-hidden="true">&times;</span></button>
		           <h4 class="media-heading">Avatar%Exp:cAvatar%</h4>
		           <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
		       </div>
		    </div>
	   	endContent
	   	
		oWebChannel:advplToJs("insertItem", cField)
		::nCount++
	next i
	::nCountCreated += 6

return

/*/	-----------------------------------------------------------------/
Deleta primeiro registro
/-------------------------------------------------------------------*/
Method deleta() class compHTML
	if ::nCount > 0
		::nCount--
		::oWebEngine:runJavaScript("removeFirstPanel()")

		conout("", ": Primeiro item deletado via AdvPL: ")
	endif
return