####################################################################################################################################
#COLETA DE DADOS DE ESTACOES PLUVIOMETRICAS - CEMADEN                                                                              #
#                                                                                                                                  #
#AUTOR: Rodrigo Medeiros Costa                                                                                                     #
#DATA: 10/07/2020                                                                                                                  #
####################################################################################################################################

#Bibliotecas
library(rvest)
library(hms)
library(lubridate)
library(xlsx)
library(stringr)
library(dplyr)

#Obtem dados da pagina do Cemaden referente a cada estacao
#id_station -> codigo identificador de uma estacao instalada em um municipio
get.data.station <- function(id_station){
  #Pagina fonte dos dados das estacoes
  url <- paste0('http://sjc.salvar.cemaden.gov.br/resources/graficos/interativo/consulta_dados.php?idpcd=', id_station)
  page <- read_html(url)
  table_html <- page %>%
    html_nodes('table') %>%
    html_table(fill = TRUE)
  return(data.frame(table_html, stringsAsFactors = FALSE))
}

#Obtem dados sobre cada estacao
#loc -> Parametro para escolher um ou todos os municipios monitorados
get.info.stations <- function(loc = 'all'){
  #Arquivo com dados dos municipios incluindo dados espaciais
  fileName <- 'data/dados.estacoes.pa.csv'
  data <- read.csv(fileName, 
                   sep = ";")
  #Validacao 
  if(!str_to_lower(loc) %in% str_to_lower(data$Municipio) & str_to_lower(loc) != 'all'){
    stop('Municipio nao encontrado na base!')
  }
  #Dados para um determinado municipio
  if(str_to_lower(loc) != 'all'){
    data <- data %>%
     filter(str_to_lower(data$Municipio) %in% str_to_lower(loc))
  }
  return (as.data.frame(data))
}

#Grava arquivo final com dados de coleta e sobre as estacoes
save.pluv.data <- function(to_save){
  fileName = 'dados-pluviometros-cemaden.xlsx'
  if(file.exists(fileName)){
    file.remove(fileName) 
  }
  write.xlsx(to_save$data_st, 
             file = fileName, 
             sheetName = 'Coleta', 
             append = TRUE)
  write.xlsx(to_save$info_st, 
             file = fileName, 
             sheetName = 'Estacoes', 
             append = TRUE)
}

#Processa e retorna os dados obtidos da pagina do Cemaden
#location -> Parametro para escolher um ou todos os municipios monitorados
cemaden.pluv.data <- function(location = 'all'){
  data_df <- data.frame()
  ifelse(str_to_lower(location) != 'all', 
         info_stations_df <- get.info.stations(location), #municipio especifico
         info_stations_df <- get.info.stations()) # todos os municipios
  for(i in 1:nrow(info_stations_df)){
    
    dstation_df <- get.data.station(info_stations_df$IdEstacao[i])
    info_stations_df[i, 'EstadoEstacao'] <- 'Ativada' 
    
    #Flag de controle. Estacao sem coleta gera campo de data/hora vazio e que influencia no processamento 
    is_time_var_empty <- FALSE 
    
    #Detecta estacao que possivelmente esteja desabilitada
    if(nrow(dstation_df) < 3){
      dstation_df$Chuva..mm. <- '0,00'
      dstation_df$Data...Hora <- Sys.time()
      info_stations_df[i, 'EstadoEstacao'] <- 'Desativada' 
      is_time_var_empty <- TRUE
    }
    
    dstation_df$Id <- i
    info_stations_df[i, 'Id'] <- i
    
    if(is_time_var_empty == FALSE) {
      dstation_df <- dstation_df[dstation_df$Data...Hora != 'Total', ]
    }
    #Tratamento do fuso-horario, pois os dados brutos estao com +3 horas em relacao ao horario local
    if(is_time_var_empty == FALSE){
      dstation_df$Data...Hora <- dmy_hms(dstation_df$Data...Hora, 
                                         tz='UTC')
      dstation_df$Data...Hora <- with_tz(dstation_df$Data...Hora, 
                                         'America/Belem')
    }
    
    dstation_df$DataColeta <- format(as.POSIXct(strptime(dstation_df$Data...Hora, 
                                                         '%Y-%m-%d %H:%M:%S', 
                                                         tz='')), 
                                     format = '%d/%m/%Y')
    dstation_df$HoraColeta <- format(as.POSIXct(strptime(dstation_df$Data...Hora, 
                                                         '%Y-%m-%d %H:%M:%S', 
                                                         tz='')), 
                                     format = '%H:%M:%S')
    dstation_df$Data...Hora <- NULL
    dstation_df <- dstation_df[complete.cases(dstation_df), ]
    dstation_df$IndHora <- 1:length(dstation_df$HoraColeta)
    data_df <- as.data.frame(rbind(data_df, dstation_df))
    
    #Exibicao em console para depuracao
    cat('Municipio: ', info_stations_df$Municipio[i],
        ' Estacao: ', info_stations_df$NomeEstacao[i],
        ' - ', info_stations_df$IdEstacao[i], '\n') 
    Sys.sleep(3) 
  }
  return(list(data_st = data_df, 
              info_st = info_stations_df))
}

#Execucao para as estacoes de todos os municipios (loc = 'all')
data <- cemaden.pluv.data() 

View(data$data_st)
View(data$info_st)



  
