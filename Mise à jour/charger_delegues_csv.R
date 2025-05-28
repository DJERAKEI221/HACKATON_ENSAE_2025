# Script pour charger les délégués depuis delegues.csv
# À exécuter pour mettre à jour les délégués

# Installation et chargement des packages nécessaires
if (!require("pacman")) {
  cat("Installation de pacman pour la gestion des packages...\n")
  install.packages("pacman", repos = "https://cloud.r-project.org")
}

# Charger les packages requis
pacman::p_load(
  DBI,      # Interface base de données
  RSQLite,  # SQLite pour R
  readr,    # Pour une meilleure lecture des CSV
  stringi   # Pour la gestion des caractères spéciaux
)

# Chargement des délégués
cat("\n3. Chargement des délégués...\n")

# Chemins relatifs
db_path <- "data/elections.db"
delegues_file <- "data/delegues.csv"

# Vérifier si le fichier existe
if (!file.exists(db_path)) {
  stop(sprintf("Le fichier de base de données n'existe pas à l'emplacement : %s", db_path))
}

# Connexion à la base de données avec gestion d'erreur
tryCatch({
  con <- dbConnect(RSQLite::SQLite(), db_path)
  cat("Connexion à la base de données réussie!\n")
}, error = function(e) {
  stop(sprintf("Erreur de connexion à la base de données : %s", e$message))
})

# Vérifier si la connexion est valide
if (!dbIsValid(con)) {
  stop("La connexion à la base de données n'est pas valide")
}

# Créer la table voters si elle n'existe pas
if (!dbExistsTable(con, "voters")) {
  cat("Création de la table voters...\n")
  dbExecute(con, "
    CREATE TABLE voters (
      identifiant TEXT PRIMARY KEY,
      nom TEXT NOT NULL,
      prenom TEXT NOT NULL,
      classe TEXT NOT NULL
    )
  ")
}

# Créer la table delegues si elle n'existe pas
if (!dbExistsTable(con, "delegues")) {
  cat("Création de la table delegues...\n")
  dbExecute(con, "
    CREATE TABLE delegues (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      identifiant TEXT NOT NULL,
      nom TEXT NOT NULL,
      prenom TEXT NOT NULL,
      classe TEXT NOT NULL,
      type TEXT NOT NULL,
      FOREIGN KEY (identifiant) REFERENCES voters(identifiant)
    )
  ")
}

# Créer la table candidates si elle n'existe pas
if (!dbExistsTable(con, "candidates")) {
  cat("Création de la table candidates...\n")
  dbExecute(con, "
    CREATE TABLE candidates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      identifiant TEXT NOT NULL,
      nom TEXT NOT NULL,
      prenom TEXT NOT NULL,
      classe TEXT NOT NULL,
      type TEXT NOT NULL,
      FOREIGN KEY (identifiant) REFERENCES voters(identifiant)
    )
  ")
}

# Vérifier si le fichier existe
if (!file.exists(delegues_file)) {
  stop(sprintf("Le fichier delegues.csv n'existe pas à l'emplacement : %s", delegues_file))
}

# Lecture du fichier CSV avec gestion d'erreur
tryCatch({
  # Lire le fichier avec readr qui gère mieux les encodages
  delegues <- readr::read_delim(delegues_file, 
                              delim = ";",
                              locale = locale(encoding = "UTF-8"),
                              show_col_types = FALSE,
                              na = c("", "NA", "N/A"),
                              trim_ws = TRUE)
  
  # Supprimer les colonnes vides
  delegues <- delegues[, !grepl("^\\.\\.\\.", names(delegues))]
  
  cat("Lecture du fichier delegues.csv réussie!\n")
}, error = function(e) {
  stop(sprintf("Erreur lors de la lecture du fichier delegues.csv : %s", e$message))
})

# Renommer les colonnes si nécessaire
if ("numero_etudiant" %in% names(delegues)) {
  names(delegues)[names(delegues) == "numero_etudiant"] <- "identifiant"
}

# Vérifier les colonnes requises
required_cols <- c("identifiant", "nom", "prenom", "classe", "type")
missing_cols <- setdiff(required_cols, names(delegues))
if (length(missing_cols) > 0) {
  stop(sprintf("Colonnes manquantes dans delegues.csv : %s", paste(missing_cols, collapse = ", ")))
}

# Vider la table delegues
dbExecute(con, "DELETE FROM delegues")

# Insertion des données avec gestion d'erreur
tryCatch({
  # Préparer les données
  delegues$identifiant <- as.character(delegues$identifiant)
  delegues$nom <- stringi::stri_trans_toupper(delegues$nom, locale = "fr_FR.UTF-8")
  delegues$prenom <- stringi::stri_trans_totitle(delegues$prenom, locale = "fr_FR.UTF-8")
  delegues$classe <- stringi::stri_trans_toupper(delegues$classe, locale = "fr_FR.UTF-8")
  delegues$type <- stringi::stri_trans_tolower(delegues$type, locale = "fr_FR.UTF-8")
  
  # Nettoyer les données
  delegues$classe <- stringi::stri_trim_both(delegues$classe)  # Enlever les espaces
  delegues$classe[delegues$classe == ""] <- NA  # Remplacer les chaînes vides par NA
  
  # Supprimer les lignes avec classe manquante
  delegues <- delegues[!is.na(delegues$classe), ]
  
  # Insérer les données
  dbWriteTable(con, "delegues", delegues, append = TRUE)
  cat(sprintf("%d délégués chargés avec succès!\n", nrow(delegues)))
}, error = function(e) {
  stop(sprintf("Erreur lors de l'insertion des données : %s", e$message))
})

# Statistiques finales
cat("\nRESUME:\n")
cat("   Délégués ajoutés:", nrow(delegues), "\n")

# Vérification finale
total_delegues <- dbGetQuery(con, "SELECT COUNT(*) as count FROM delegues")$count
cat("   Total délégués en base:", total_delegues, "\n")

# Statistiques par classe et type
if (total_delegues > 0) {
  stats <- dbGetQuery(con, "
    SELECT classe, type, COUNT(*) as nb
    FROM delegues
    GROUP BY classe, type
    ORDER BY classe, type
  ")
  
  cat("\nSTATISTIQUES PAR CLASSE:\n")
  for (i in 1:nrow(stats)) {
    cat("  -", stats$classe[i], ":", stats$nb[i], stats$type[i], "\n")
  }
  
  # Afficher quelques exemples
  exemples <- dbGetQuery(con, "
    SELECT nom, prenom, classe, type
    FROM delegues
    ORDER BY classe, type
    LIMIT 10
  ")
  
  cat("\nEXEMPLES DE DELEGUES CHARGES:\n")
  for (i in 1:nrow(exemples)) {
    cat("  -", exemples$nom[i], exemples$prenom[i], "->", exemples$type[i], "de", exemples$classe[i], "\n")
  }
}

# Fermer la connexion
dbDisconnect(con)
cat("\nTERMINE! Les delegues ont ete charges depuis delegues.csv\n")
cat("   Vous pouvez maintenant relancer l'application Shiny.\n") 