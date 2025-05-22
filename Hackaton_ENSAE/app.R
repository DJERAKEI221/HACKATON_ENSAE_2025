# app.R - Point d'entrée de l'application électorale ENSAE

source("global.R")
ui <- source("ui/ui_main.R")$value
server <- source("server/server_main.R")$value

options(
  shiny.maxRequestSize = 100*1024^2,  # Permettre l'upload de fichiers jusqu'à 100MB
  timeout = 300  # Timeout de 5 minutes
)

shinyApp(ui, server)





