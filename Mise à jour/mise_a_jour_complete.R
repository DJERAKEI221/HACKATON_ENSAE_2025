# Script de mise à jour complète
# Charge les candidats bureau ET les délégués depuis les fichiers CSV

cat("MISE A JOUR COMPLETE DES DONNEES D'ELECTIONS\n")
cat("---------------------------------------------\n\n")

# Installation et chargement des packages nécessaires
if (!require("pacman")) {
  cat("Installation de pacman pour la gestion des packages...\n")
  install.packages("pacman", repos = "https://cloud.r-project.org")
}

# Charger les packages requis pour ce script
pacman::p_load(
  DBI,      # Interface base de données
  RSQLite   # SQLite pour R
)

# 1. Charger les candidats bureau
cat("1. Chargement des candidats bureau...\n")
if (file.exists("../data/candidats_bureau.csv")) {
  source("charger_candidats_csv.R")
} else {
  cat("ATTENTION: Fichier candidats_bureau.csv non trouvé, utilisation des exemples\n")
  if (file.exists("../data/EXEMPLE_candidats_bureau.csv")) {
    file.copy("../data/EXEMPLE_candidats_bureau.csv", "../data/candidats_bureau.csv")
    cat("OK: Fichier exemple copié vers candidats_bureau.csv\n")
    source("charger_candidats_csv.R")
  } else {
    cat("ERREUR: Aucun fichier candidats trouvé\n")
  }
}

cat("\n--------------------------------------------------\n\n")

# 2. Charger les délégués
cat("2. Chargement des délégués...\n")
if (file.exists("../data/delegues.csv")) {
  source("charger_delegues_csv.R")
} else {
  cat("ATTENTION: Fichier delegues.csv non trouvé, utilisation des exemples\n")
  if (file.exists("../data/EXEMPLE_delegues.csv")) {
    file.copy("../data/EXEMPLE_delegues.csv", "../data/delegues.csv")
    cat("OK: Fichier exemple copié vers delegues.csv\n")
    source("charger_delegues_csv.R")
  } else {
    cat("ERREUR: Aucun fichier délégués trouvé\n")
  }
}

cat("\n--------------------------------------------------\n\n")

# 3. Vérifier/créer la table voters
cat("3. Verification de la table voters...\n")

# Vérifier si la table voters existe
tables <- dbListTables(con)
if (!"voters" %in% tables) {
  cat("Creation de la table voters...\n")
  
  # Créer la table voters
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS voters (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      classe TEXT,
      has_voted INTEGER DEFAULT 0,
      vote_timestamp DATETIME,
      year INTEGER DEFAULT 2025
    )")
  
  # Charger les étudiants
  students_df <- tryCatch({
    read.table(file = "../data/base_eleves.csv", sep = ";", header = TRUE,
               stringsAsFactors = FALSE, fileEncoding = "latin1",
               quote = "\"", fill = TRUE, comment.char = "")
  }, error = function(e) {
    read.csv(file = "../data/base_eleves.csv", sep = ";", stringsAsFactors = FALSE)
  })
  
  # Nettoyer et ajouter les étudiants
  students_df <- students_df[!is.na(students_df$Identifiant) & 
                            !is.na(students_df$Nom) & 
                            !is.na(students_df$Prenom), ]
  
  for (i in 1:nrow(students_df)) {
    student <- students_df[i, ]
    tryCatch({
      dbExecute(con, "
        INSERT OR IGNORE INTO voters (id, name, classe, has_voted, year)
        VALUES (?, ?, ?, 0, 2025)
      ", params = list(
        student$Identifiant,
        paste(student$Prenom, student$Nom),
        ifelse("Classe" %in% names(student), student$Classe, NA)
      ))
    }, error = function(e) {})
  }
  
  cat("OK: Table voters creee et peuplee\n")
} else {
  voters_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM voters")$count
  cat("OK: Table voters existe avec", voters_count, "electeurs\n")
}

cat("\n--------------------------------------------------\n\n")

# 4. Vérification finale
cat("4. Verification finale...\n")

con <- dbConnect(RSQLite::SQLite(), "../data/elections.db")

# Statistiques candidats
candidats_stats <- dbGetQuery(con, "
  SELECT p.category, COUNT(*) as nb_candidats
  FROM candidates c
  JOIN positions p ON c.position_id = p.id
  GROUP BY p.category
")

cat("CANDIDATS BUREAU:\n")
for (i in 1:nrow(candidats_stats)) {
  cat("   ", candidats_stats$category[i], ":", candidats_stats$nb_candidats[i], "candidats\n")
}

# Statistiques délégués
delegues_stats <- dbGetQuery(con, "
  SELECT position_type, COUNT(*) as nb_delegues
  FROM delegate_candidates
  GROUP BY position_type
")

cat("\nDELEGUES:\n")
for (i in 1:nrow(delegues_stats)) {
  cat("   ", delegues_stats$position_type[i], ":", delegues_stats$nb_delegues[i], "candidats\n")
}

# Total général
total_candidats <- dbGetQuery(con, "SELECT COUNT(*) as count FROM candidates")$count
total_delegues <- dbGetQuery(con, "SELECT COUNT(*) as count FROM delegate_candidates")$count

cat("\nTOTAL GENERAL:\n")
cat("   Candidats bureau:", total_candidats, "\n")
cat("   Candidats delegues:", total_delegues, "\n")
cat("   TOTAL:", total_candidats + total_delegues, "candidats\n")

dbDisconnect(con)

cat("\nMISE A JOUR TERMINEE!\n")
cat("   Vous pouvez maintenant lancer l'application avec: shiny::runApp()\n") 