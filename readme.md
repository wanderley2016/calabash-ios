#  Calabash-ios x Appium-ios

## Quem tem a melhor Performance em Execução ?

Ao invés de falar, melhor mostrar, esse projeto tem como objetivo 
criar um repositorio com calabash-ios e nesse <a href="https://github.com/wanderley2016/appium-ios">appium ios</a>
para medir-mos a performance dos dois.

## Gerar o esqueleto do projeto
    
Para começar com o calabash na pasta atual digito o comando:
```
Calabash-ios gen  # cria o esqueleto do projeto

features
|_support
| |_app_installation_hooks.rb
| |_app_life_cycle_hooks.rb
| |_env.rb
| |_hooks.rb
|_step_definitions
| |_calabash_steps.rb
|_my_first.feature
|_Gemfile
```

## Gemfile

Abra o arquivo Gemfile e adicione as gems:
```
source "https://rubygems.org"

gem "calabash-cucumber", ">= 0.21.4", "< 2.0"
require "pry"
```

Abra o terminal e execute o comando abaixo :
```
bundle install      
```

## Inspecionando elementos

Para inspecionar os elementos no calabash-ios na pasta atual digito o comando:
```
bundle exec calabash-ios console
```
alguns comando utilizados:
```
start_test_server_in_background         # inicia o app
query"*"                                # exibe todos os elementos da tela
query"*",:class                         # exibe elementos tipo class na tela
query"*",:id                            # exibe elementos tipo id na tela
query"*",:text                          # exibe elementos tipo text na tela
query"*",:contentDescription            # exibe elementos tipo contDesc na tela
query("UIButton")                       # busca por classe especifica na tela
query("* id:'action_bar_root'")         # busca por id especifico na tela
query("* text:'Buscar'")                # busca por text especifico na tela
query("* contentDescription:'oi'")      # busca por contDesc na tela
query("* id:'action_bar_root'")[0]      # busca elemento por index
query("* id:'action_bar_root'").empty?  # retorna true ou false o elemento
query("* id:'action_bar_root'").size    # verifica o tamanho 
```

## Executando os testes

```
Buscar os simuladores instalados em sua maquina execute o comando xcrun simctl list
``` 
Para executar os testes basta digitar os comandos abaixo:

```
APP_BUNDLE_PATH= <<caminho do.app>> DEVICE_TARGET= <<'id device'>> bundle exec cucumber features

Observação: Para buscar id device execute o comando xcrun simctl list
```

Para executar os testes passando uma feature desejada:
```
APP_BUNDLE_PATH= <<caminho do.app>> DEVICE_TARGET= <<'id device'>> bundle exec cucumber features/<<nome da feature>>
```

## Gerando relatório de teste

Para gerar o relatório no final dos teste, basta colocar o comando:

```
APP_BUNDLE_PATH=<<caminho do.app>> DEVICE_TARGET= <<'id device'>> bundle exec cucumber features --format html --out reports.html
```
## Respostas

Respondendo então pergunta do tópico. "Até o momento a execução dos testes com o calabash ios é bem mais lenta do que o appium ios".Se ficou curioso é só olhar o "reports" nos repositorios e verificar o time.