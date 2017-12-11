# language: pt
Funcionalidade: Home
  Eu como usuário 
  desejo inserir meu nome no campo texto 
  para que possa visualizar mensagem de alerta 
    
  Esquema do Cenário: Adicionar nome
    Dado que estou na home do app
    E informo o <meu nome> 
    Quando toco no botão gravar
    Entao vejo mensagem de alerta com o nome inserido

    Exemplos:
    | meu nome  |
    | "jurema"  |
    | "henrique"|

  Cenário: Limpar nome inserido
    Dado que o nome esteja inserido
    Quando toco no botão limpar
    Então deve ser apagado o nome 