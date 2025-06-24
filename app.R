# app.R - Point d'entrée de l'application électorale ENSAE

# Charger les dépendances globales
source("global.R")

# Charger l'interface utilisateur et le serveur
ui <- source("ui/ui_main.R")$value
server <- source("server/server_main.R")$value


# Configuration des options Shiny
options(
  shiny.maxRequestSize = 100*1024^2,  # Permettre l'upload de fichiers jusqu'à 100MB
  timeout = 300,  # Timeout de 5 minutes
  shiny.reactlog = TRUE  # Activer le journal de réactivité pour le débogage
)

# Lancer l'application

shinyApp(ui = ui, server = server)






