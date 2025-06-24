# Installation et chargement des packages nécessaires
if (!require("pacman")) {
  cat("Installation de pacman pour la gestion des packages...\n")
  install.packages("pacman", repos = "https://cloud.r-project.org")
}

# Charger les packages requis
pacman::p_load(
  DBI,      # Interface base de données
  RSQLite   # SQLite pour R
)

# Connexion à la base de données
con <- dbConnect(RSQLite::SQLite(), "data/elections.db")

cat("VERIFICATION DE LA BASE DE DONNEES\n")
cat("--------------------------------\n\n")

# Vérifier les tables existantes
tables <- dbListTables(con)
cat("Tables dans la base de données:\n")
for (table in tables) {
  cat("  -", table, "\n")
}

# Vérifier les candidats
tryCatch({
  candidats_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM candidates")$count
  cat("\nCANDIDATS BUREAU:\n")
  cat("   Total:", candidats_count, "candidats\n")

  if (candidats_count > 0) {
    # Statistiques par catégorie
    stats_candidats <- dbGetQuery(con, "
      SELECT p.category, COUNT(*) as nb
      FROM candidates c
      JOIN positions p ON c.position_id = p.id
      GROUP BY p.category
    ")
    
    for (i in 1:nrow(stats_candidats)) {
      cat("   -", stats_candidats$category[i], ":", stats_candidats$nb[i], "candidats\n")
    }
    
    # Afficher quelques exemples
    exemples_candidats <- dbGetQuery(con, "
      SELECT c.name, p.name as poste
      FROM candidates c
      JOIN positions p ON c.position_id = p.id
      LIMIT 5
    ")
    
    cat("\nExemples de candidats:\n")
    for (i in 1:nrow(exemples_candidats)) {
      cat("   -", exemples_candidats$name[i], "->", exemples_candidats$poste[i], "\n")
    }
  }
}, error = function(e) {
  cat("\nCANDIDATS BUREAU:\n")
  cat("   Aucun candidat enregistré\n")
})

# Vérifier les délégués
tryCatch({
  delegues_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM delegate_candidates")$count
  cat("\nDELEGUES:\n")
  cat("   Total:", delegues_count, "délégués\n")

  if (delegues_count > 0) {
    # Statistiques par classe et type
    stats_delegues <- dbGetQuery(con, "
      SELECT classe, position_type, COUNT(*) as nb
      FROM delegate_candidates
      GROUP BY classe, position_type
      ORDER BY classe, position_type
    ")
    
    for (i in 1:nrow(stats_delegues)) {
      cat("   -", stats_delegues$classe[i], ":", stats_delegues$nb[i], stats_delegues$position_type[i], "\n")
    }
    
    # Afficher quelques exemples
    exemples_delegues <- dbGetQuery(con, "
      SELECT name, classe, position_type
      FROM delegate_candidates
      LIMIT 5
    ")
    
    cat("\nExemples de délégués:\n")
    for (i in 1:nrow(exemples_delegues)) {
      cat("   -", exemples_delegues$name[i], "->", exemples_delegues$position_type[i], "de", exemples_delegues$classe[i], "\n")
    }
  }
}, error = function(e) {
  cat("\nDELEGUES:\n")
  cat("   Aucun délégué enregistré\n")
})

# Vérifier les électeurs
tryCatch({
  voters_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM voters")$count
  cat("\nELECTEURS:\n")
  cat("   Total:", voters_count, "électeurs\n")

  if (voters_count > 0) {
    # Statistiques par classe
    stats_voters <- dbGetQuery(con, "
      SELECT classe, COUNT(*) as nb
      FROM voters
      GROUP BY classe
      ORDER BY classe
    ")
    
    for (i in 1:nrow(stats_voters)) {
      cat("   -", stats_voters$classe[i], ":", stats_voters$nb[i], "électeurs\n")
    }
  }
}, error = function(e) {
  cat("\nELECTEURS:\n")
  cat("   Aucun électeur enregistré\n")
})

cat("\nVERIFICATION TERMINEE!\n")

dbDisconnect(con) 