library(DBI)
library(RSQLite)

# Vérifier si la base de données existe
if (!file.exists("data/elections.db")) {
  cat("ERREUR: Base de données introuvable!\n")
  cat("Emplacement recherché:", normalizePath("data/elections.db", mustWork = FALSE), "\n")
  stop()
}

# Connexion
con <- dbConnect(RSQLite::SQLite(), "data/elections.db")

# Vérification des tables
tables <- dbListTables(con)
cat("Tables trouvées:", paste(tables, collapse = ", "), "\n\n")

# Vérification des positions
positions <- dbGetQuery(con, "SELECT * FROM positions")
cat("Nombre de positions:", nrow(positions), "\n")
if (nrow(positions) > 0) {
  print(positions)
} else {
  cat("ERREUR: Aucune position trouvée!\n")
}

# Vérification des candidats
candidates <- dbGetQuery(con, "SELECT * FROM candidates")
cat("\nNombre de candidats:", nrow(candidates), "\n")
if (nrow(candidates) > 0) {
  print(candidates)
} else {
  cat("ERREUR: Aucun candidat trouvé!\n")
}

# Déconnexion
dbDisconnect(con) 