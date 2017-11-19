#include "TOTVS.CH"

/*/	-----------------------------------------------------------------/
Exemplo para montagem de formulario HTML manipulado via AdvPL
/-------------------------------------------------------------------*/
function u_FormHtml()
local i, oDlg, cFile, nHandle, globalLink
local aFiles := {"bootstrap.min.css",;
				"jquery-1.10.2.min.js",;
				"style.css",;
				"totvstec.js",;
				"validator.min.js",;
				"form.html";
				}
local tempPath := GetTempPath()
local cOS := getOS()
private oWebEngine, oWebChannel

oDlg := TWindow():New(10, 10, 800, 600, "TOTVS - Formulario Bootstrap")

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

    // TWebChannel eh responsavel pelo trafego SmartClient/HTML
    oWebChannel := TWebChannel():New()
    oWebChannel:connect()
    if !oWebChannel:lConnected
    	msgStop("Erro na conexao com o WebSocket")
    	return
    endif
    
    // IMPORTANTE: Aqui definimos a porta WebSocket que sera utilizada
    globalLink := tempPath + "form.html?port=" + cValToChar(oWebChannel:nPort)
    //globalLink := "http://andregp.com/totvs.labs/carol-assist/client-app/baseForm.html"
    //globalLink := "http://127.0.0.1:8080/client-app/baseForm.html?port=" + cValToChar(oWebChannel:nPort)
    conout(globalLink)
    
    // Toda acao JavaScript enviada atraves do comando dialog.jsToAdvpl()
    // sera recebida/tratada por este bloco de codigo
	oWebChannel:bJsToAdvpl := {|self,codeType,codeContent|; 
	   jsToAdvpl(self,codeType,codeContent) } 
		
    // Navegador embutido
    oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100)	
	oWebEngine:navigate(globalLink)
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

oDlg:Activate()//("MAXIMIZED")
Return

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

	// Termino da carga da pagina HTML
	if codeType == "pageStarted"
		loadForm()
	endif

	// Recebendo dados vindos do formulario HTML
	if codeType == "receiveData" .and. codeContent != "Invalid fill"
		conout(": Dados recebidos, efetuar tratamento.")
	endif
	
	// Fecha aplicacao
	if codeType == "closeApp"
		__Quit()
	endif
return

/*/	-----------------------------------------------------------------/
Carrega o formulario HTML
/-------------------------------------------------------------------*/
static function loadForm()

/*
       <div class="form-group">
          <label for="inputName" class="control-label">Nome</label>
          <input type="text" class="form-control" id="inputName" placeholder="Nome" required="">
          <div class="help-block with-errors"></div>
        </div>

        <div class="form-group">
          <label for="inputNasc" class="control-label">Nascimento</label>
          <input type="date" class="form-control" id="inputNasc" placeholder="Nascimento" required="">
          <div class="help-block with-errors"></div>
        </div>

        <div class="form-group">
          <label for="inputEmail" class="control-label">Email</label>
          <input type="email" class="form-control" id="inputEmail" placeholder="Email"
                 data-error="Email inv&aacute;lido" required="">
          <div class="help-block with-errors"></div>
        </div>

        <div class="form-group">
          <label for="inputPassword" class="control-label">Senha</label>

          <div class="form-inline row">
            <div class="form-group col-sm-6">
              <input type="password" data-minlength="6" class="form-control" id="inputPassword" 
                     placeholder="Senha" required="">
              <div class="help-block">Minimo 6 caracteres</div>
            </div>

            <div class="form-group col-sm-6">
              <input type="password" class="form-control" id="inputPasswordConfirm" 
                    data-match="#inputPassword" 
                    data-match-error="Senhas n&atilde;o conferem" 
                    placeholder="Confirme" required="">
              <div class="help-block with-errors"></div>
            </div>
          </div>

        </div>

        <div class="form-group">
          <div class="checkbox">
            <label>
              <input type="checkbox" id="terms" data-error="Favor selecionar" required="">
              N&atilde;o sou um rob&ocirc;
            </label>
            <div class="help-block with-errors"></div>
          </div>
        </div>

        <div class="form-group">
          <button type="submit" class="btn btn-primary disabled">Confirma</button>
        </div>
*/

/*
        <div class="form-group">
            <div class="col-sm-8">
            	<label>First name</label><input type="text" class="form-control" id="First" data-error="Preencha nome" required="">
            	<div class="help-block with-errors"></div>
            </div>
        </div>
            
        <div class="form-group">
            <div class="col-sm-8"><label>Last name</label><input type="text" class="form-control" id="Last"></div>
        </div>

        <div class="col-sm-12"><!--Break line--></div>
        <div class="form-group">
            <div class="col-sm-4">
                <label>Email</label><input type="email" class="form-control" id="Email" data-error="Email invalido" required="">
                <div class="help-block with-errors"></div>
            </div>
        </div>

        <div class="form-group">
            <div class="col-sm-2">
                <label>Pass</label><input type="password" class="form-control" id="Pass" data-minlength="6" data-error="Minimo 6 caracteres" required="">
                <div class="help-block with-errors"></div>
            </div>
        </div>
        
        <div class="form-group">
            <div class="col-sm-2"><label>Born</label><input type="date" class="form-control" id="Born"></div>
        </div>
        
        <div class="col-sm-12"><!--Break line--></div>
        <div class="col-sm-8"><button type="submit" class="btn btn-info pull-right">Submit</button></div>
        
*/

	// Insere campos no formulario HTML
	BeginContent var cField
       <div class="form-group">
          <label for="inputName" class="control-label">Nome</label>
          <input type="text" class="form-control" id="inputName" placeholder="Nome" required="">
          <div class="help-block with-errors"></div>
        </div>

        <div class="form-group">
          <label for="inputNasc" class="control-label">Nascimento</label>
          <input type="date" class="form-control" id="inputNasc" placeholder="Nascimento" required="">
          <div class="help-block with-errors"></div>
        </div>

        <div class="form-group">
          <label for="inputEmail" class="control-label">Email</label>
          <input type="email" class="form-control" id="inputEmail" placeholder="Email"
                 data-error="Email inv&aacute;lido" required="">
          <div class="help-block with-errors"></div>
        </div>

        <div class="form-group">
          <label for="inputPassword" class="control-label">Senha</label>

          <div class="form-inline row">
            <div class="form-group col-sm-6">
              <input type="password" data-minlength="6" class="form-control" id="inputPassword" 
                     placeholder="Senha" required="">
              <div class="help-block">Minimo 6 caracteres</div>
            </div>

            <div class="form-group col-sm-6">
              <input type="password" class="form-control" id="inputPasswordConfirm" 
                    data-match="#inputPassword" 
                    data-match-error="Senhas n&atilde;o conferem" 
                    placeholder="Confirme" required="">
              <div class="help-block with-errors"></div>
            </div>
          </div>

        </div>

        <div class="form-group">
          <div class="checkbox">
            <label>
              <input type="checkbox" id="terms" data-error="Favor selecionar" required="">
              N&atilde;o sou um rob&ocirc;
            </label>
            <div class="help-block with-errors"></div>
          </div>
        </div>

        <div class="form-group">
          <button type="submit" class="btn btn-primary disabled">Confirma</button>
        </div>
    endContent
	oWebChannel:advplToJs("insertField", cField)
	
	// Insere itens no menu HTML
	BeginContent var cMenu
      <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&#9754;&nbsp;</a>
      <a href="#" onclick="dialog.jsToAdvpl('server_message', 'Pressionado botao Novo');">Novo</a>
      <a href="#" onclick="dialog.jsToAdvpl('server_message', 'Pressionado botao Edita');">Edita</a>
      <a href="#" onclick="dialog.jsToAdvpl('server_message', 'Pressionado botao Apaga');">Apaga</a>
      <a href="#" onclick="dialog.jsToAdvpl('closeApp', 'Aplicacao sera fechada');">Sair</a>
	endContent
	oWebChannel:advplToJs("lateralMenu", cMenu)
	
	// Insere as funcoes JavaScript pra validacao
    // IMPORTANTE: Nao utilize comentarios ao inserir o codigo JavaScript
    BeginContent var cValid
        function myValid(){
            var countFields = $("#mainForm")[0].childElementCount;
            var fields = {fields:[]}; 
            
            for (i=0; i<countFields; i++){
            
            	console.log(i);
            
                fields.fields.push({id: $("#mainForm")[0][i].id,
                                    value: $("#mainForm")[0][i].value});
                
                if ($("#mainForm")[0][i].validity.valid == false){
                    dialog.jsToAdvpl('receiveData', "Invalid fill");
                    return;
                }
            }

            var jsonStr = JSON.stringify(fields);
            dialog.jsToAdvpl('receiveData', jsonStr);
        } 
    endContent
	oWebChannel:advplToJs("js", cValid)
return

