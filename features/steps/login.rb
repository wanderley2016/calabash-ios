Dado(/^que vejo a tela de boas vindas$/) do
	@boasVindas = BoasVindasScreen.new(driver)
	@boasVindas.tela_boas_vindas
end

Dado(/^clico no link ja tenho uma conta$/) do
	@boasVindas.link_ja_tenho_conta
end

Dado(/^vejo a Home de login$/) do
	@whats_new = WhatsnewScreen.new(driver)
	@whats_new.tela_Whats_New
end

Dado(/^digitei a credencial "([^"]*)"$/)  do |credential_type|
	credential_type = 'de acesso rápido 0' if
	credential_type == 'de acesso rápido'
	@credential = CREDENTIALS[credential_type.gsub(' ', '_').to_sym]
	step "digitar a credencial de \"#{@credential[:agency]}\" e \"#{@credential[:account]}\""
end

Dado(/^toquei no botão acessar$/) do
	@login.botao_acessar
end

Dado(/^(?:digitei|digitar) a senha no teclado virtual$/) do
	step "digitar a \"#{@credential[:password]}\" no teclado virtual"
end

Dado(/^seleciono a opção lembrar agencia e conta$/) do
	@login.Lembrar_agencia_conta
end

Quando(/^(?:digitei|digitar) a "(.*?)" no teclado virtual$/) do |password|
	sleep(0.5)
	@login.digitar_senha password
end

Quando(/^toquei no botão OK$/) do
	@login.botao_ok
end

Quando(/^(?:digitei|digitar) a credencial de "(.*?)" e "(.*?)"$/) do |agency, account|
	@login = LoginScreen.new(driver)
	@login.preencher_agencia agency
	@login.preencher_conta account
end

Quando(/^clico no item "([^"]*)" do menu perfil do usuario$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Quando(/^devo ir para tela de senha eletrolica$/) do
  pending # Write code here that turns the phrase above into concrete actions
end


Então(/^vejo a nova home$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Então(/^acesso a conta salva no perfil novamente\.$/) do
  pending # Write code here that turns the phrase above into concrete actions
end





