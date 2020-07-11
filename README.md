# pluvcemaden

# Descrição

Robô que permite a coleta de dados de algumas estações pluviométricas instaladas em alguns municípios do estado do Pará. As estações são gerenciadas pelo Centro Nacional de Monitoramento e Alertas de Desastres Naturais ([CEMADEN](http://www.cemaden.gov.br/)). O CEMADEN possui um [mapa interativo](http://www.cemaden.gov.br/mapainterativo/#) que permite visualizar os dados obtidos pelas estações a cada hora. Os dados obtidos pelo robô representam dados coletados no dia presente.  Este robô pode ser modificado para obter dados de outras estações, sob a gestão do CEMADEN, localizadas em diversas regiões do país. 

# Exemplos de uso

É possível utilizar os dados obtidos por este robô para:

- Análise de dados
- Predições
- Uso em dashboards

Um exemplo de aplicação seria o uso dos dados para gerar algum tipo de alerta para a população que reside na região em que a estação está instalada. 

# Uso

É necessário instalar os pacotes:

```
install.packages('rvest')
install.packages('hms')
install.packages('lubridate')
install.packages('xlsx')
install.packages('readr')
install.packages('stringr')
install.packages(dplyr')
```
A execução do robô gera como saída um arquivo Excel (.xlsx) contendo duas planilhas:

- Coletas de cada estação:
  - Volume (mm/h)
  - Data da coleta
  - Hora da coleta
  
- Informações de cada estação
  - Nome do município
  - Código da estação estabelecido pelo CEMADEN
  - Identificador da estação definido pelo CEMADEN
  - Estado
  - Nome do local em que a estação está instalada
  - Coordenadas (Latitude e Longitude)
  - Estado da estação (Ativada ou Desativada)

Em ambas estruturas, tem-se a presença de um campo chamado Id para permitir a ligação entre elas. 

É importante destacar que é possível ajustar o robô para salvar os dados em outros formatos de arquivos. 

A figura abaixo representa  parte da estrutura final com os dados de coletas de cada estação:

![](docs/coletas-estacoes.png)

A figura abaixo representa a estrutura final com os dados sobre cada estação:

![](docs/informacoes-estacoes.png)


### Atenção!

Como se trata de dados coletados de uma página WEB, tem que se ter em mente que há a possibilidade dos responsáveis realizarem alguma modificação na estrutura da página, o que pode dificultar o funcionamento do robô. 

# Contribuições

A vida é um eterno aprendizado. Então, contribuições serão sempre bem-vindas. 

# Links:

- [Pluviômetros automáticos (CEMADEN)](http://www.cemaden.gov.br/pluviometros-automatico/)
