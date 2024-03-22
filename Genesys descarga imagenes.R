#Activar libreria
library(RSelenium)
library(rvest)
library(dplyr)

# Establecer conexión --------------------------------------------------
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444, browserName = "chrome")
remDr$open()
Sys.sleep(2)


# Navegar -----------------------------------------------------------------
remDr$navigate(url = "https://www.genesys-pgr.org/")

# Maximizar ventana -----------------------------------------------------------------
remDr$maxWindowSize()

# Dar click en [I AGREE] -----------------------------------------------------
Sys.sleep(2)
remDr$findElement(using = 'xpath', "//*[ text() = 'I agree']")$clickElement()

# Dar click en [ACCESION DATA] -----------------------------------------------------
Sys.sleep(2)
remDr$findElement(using = 'xpath', "//*[ text() = 'Accession data']")$clickElement()

# Dar click en [PASSPORTDATA] -----------------------------------------------------
Sys.sleep(2)
remDr$findElement(using = 'xpath', "//*[ text() = 'Passport data']")$clickElement()
Sys.sleep(5)
## Esperar 5 seg de carga

# Dar click en [HOLDING INSTITUTE] -----------------------------------------------------
Sys.sleep(1)
remDr$findElement(using = 'xpath', "//*[ text() = 'Holding institute']")$clickElement()

# BUSCAR COL003 EN [HOLDING INSTITUTE] -----------------------------------------------------------

remDr$findElement(using = 'xpath',  "//input[@id='auto-institute.code']")$clickElement()
remDr$sendKeysToActiveElement(list("COL003", key = "enter"))


# APPLY FILTERS  ----------------------------------------------------------
remDr$findElement(using = 'xpath', "//*[ text() = 'Apply filters']")$clickElement()


# SELECT CROP ------------------------------------------------------------
Sys.sleep(20)
remDr$findElement(using = 'xpath', "//*[ text() = 'Holding institute']")$clickElement()
Sys.sleep(2)
remDr$findElement(using = 'xpath', "//*[ text() = 'Crop']")$clickElement()


# SELECT BEANS ------------------------------------------------------------
Sys.sleep(2)
remDr$findElement(using = 'xpath', "//*[ text() = 'Beans']")$clickElement()


# APPLY FILTERS  ----------------------------------------------------------
Sys.sleep(2)
remDr$findElement(using = 'xpath', "//*[ text() = 'Apply filters']")$clickElement()


# SELECT IMAGES -----------------------------------------------------------
Sys.sleep(2)
remDr$findElement(using = 'xpath', "//*[ text() = 'Images']")$clickElement()
Sys.sleep(20)


# OBTENER URL -----------------------------------------------------------
#Obtener el código fuente de la última página cargada.
page_source <- remDr$getPageSource()

#Leer codigo fuente
text_html<- read_html(page_source[[1]])

#Seleccionar la parte deseada del codigo fuente
html_node<- text_html %>% 
  #html_nodes(xpath="//*[@class='MuiGrid-root MuiGrid-item MuiGrid-grid-xs-12 MuiGrid-grid-sm-6 MuiGrid-grid-md-4 MuiGrid-grid-lg-3 css-1etv89n']") %>% 
  html_nodes(xpath="//*[starts-with(@class,'MuiGrid-root MuiGrid-item MuiGrid-grid')]")

#Extraer url
url <- html_node %>% 
  html_nodes('img') %>% 
  html_attr('src') %>% 
  data.frame("URL"=.) %>% 
  filter(!is.na(URL))

#Extraer descripciones
desc<- html_node %>% 
  html_nodes('a') %>% 
  html_text() %>% 
  .[!grepl("©",.)] %>% #Filtrar casos que contengan descripciones
  .[1:nrow(url)] %>% #Filtrar casos con URL visibles
  data.frame("DESC"=.) 
  
#Crear un dataframe
dfurl <- cbind(url, desc) %>% 
  
  #Para crear un nombre unico por descarga
  group_by(DESC) %>%
  mutate(SEC = row_number()) %>% 
  ungroup() %>% 
  mutate(DESC = gsub(" • ","_", DESC)) %>% 
  mutate(NM = paste0(DESC, SEC,".jpg"))
  

# DOWNLOAD IMAGES -----------------------------------------------------------
setwd("C:/Users/ANGEL/OneDrive/Documentos")

for (i in 1:nrow(dfurl)) {
  download.file(url = dfurl[i,"URL"]$URL, dfurl[i,"NM"]$NM, mode = "wb")
}


