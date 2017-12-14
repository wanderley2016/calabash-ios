class Hellow_app < IOSScreenBase
  # Identificador da tela
  trait(:trait)                                 { "* marked:'#{layout_name}'" }
  # Declare todos os elementos da tela
  element(:layout_name)                         { 'home_meu_app'}
  element(:btn_gravar)                          { 'btnGravar' }
  element(:btn_limpar)                          { 'btnLimpar' }
  element(:lbl_name)                            { 'labelname' }
  element(:txt_name)                            { 'txtname' }
  element(:btn_ok)                             { "* marked:'OK'" }   

  def adicionar_nome(nome)
    $nome = nome
    enter_text "* id:'#{txt_name}'", $nome
  end

  def tocar_saudar
    touch("* id:'#{btn_gravar}'")
  end

  def tocar_ok
    wait_for_transition("* marked:'OK'")
    touch("#{btn_ok}")
  end
  
  def tocar_limpar
    wait_for_transition("* marked:'OK'")    
    touch("* id:'#{btn_limpar}'")
  end

  def verificar_nome_foi_apagado
    query("* id:'labelname'",:text) ==[""]
  end

  def ocultar_teclado
    wait_for_transition("view isFirstResponder:1") 
    query("view isFirstResponder:1", :resignFirstResponder)
  end
  
  def verifica_mensagem_existe
    raise 'mensagem não exibida'  unless element_exists("* text:'Adicionado com sucesso, #{$nome}'")
    tocar_ok
  end  
end