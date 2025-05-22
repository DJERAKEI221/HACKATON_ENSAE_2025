# Création du dossier data s'il n'existe pas
if (!dir.exists("data")) {
  dir.create("data", recursive = TRUE, showWarnings = FALSE)
}

# Connexion à la base de données avec chemin absolu
db_path <- normalizePath("data/elections.db", mustWork = FALSE)
con <- dbConnect(RSQLite::SQLite(), dbname = db_path)

# Création des tables avec contraintes d'intégrité
dbExecute(con, "PRAGMA foreign_keys = ON")

dbExecute(con, "
CREATE TABLE IF NOT EXISTS voters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id TEXT UNIQUE NOT NULL,
  access_code TEXT NOT NULL,
  voted INTEGER DEFAULT 0 CHECK(voted IN (0, 1))
)")

dbExecute(con, "
CREATE TABLE IF NOT EXISTS candidates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  program TEXT NOT NULL
)")

dbExecute(con, "
CREATE TABLE IF NOT EXISTS votes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  voter_id INTEGER UNIQUE NOT NULL,
  candidate_id INTEGER NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  hash TEXT UNIQUE NOT NULL,
  FOREIGN KEY(voter_id) REFERENCES voters(id),
  FOREIGN KEY(candidate_id) REFERENCES candidates(id)
)")

# Vérification de la création
tryCatch({
  tables <- dbListTables(con)
  if (length(tables) == 3) {
    message("Base de données créée avec succès !")
    message("Tables disponibles: ", paste(tables, collapse = ", "))
  }
}, error = function(e) {
  message("Erreur lors de la création: ", e$message)
})

dbDisconnect(con) 