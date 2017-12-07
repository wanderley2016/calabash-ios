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
    $nome = CREDENTIALS[nome.tr(' ', '_').to_sym][:user]
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
    ocultar_teclado       
    touch("* id:'#{btn_limpar}'")
  end

  def verificar_nome_excluído
    query("* id:'labelname'",:text) ==[""]
  end

  def ocultar_teclado
    wait_for_transition("view isFirstResponder:1") 
    query("view isFirstResponder:1", :resignFirstResponder)
  end     
end