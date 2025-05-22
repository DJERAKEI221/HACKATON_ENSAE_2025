# Script simplifié pour exécuter le SQL

# Charger les bibliothèques nécessaires
library(DBI)
library(RSQLite)

# Connexion à la base de données
con <- dbConnect(RSQLite::SQLite(), "data/elections.db")

# Lire le fichier SQL
sql <- readLines("update_candidates.sql")
sql <- paste(sql, collapse = "\n")

# Exécuter le SQL
result <- dbExecute(con, sql)

# Vérifier les données
candidates <- dbGetQuery(con, "SELECT id, name, position_id, photo_url FROM candidates ORDER BY id LIMIT 5")
print(candidates)

# Fermer la connexion
dbDisconnect(con)

cat("Script exécuté avec succès !\n") 