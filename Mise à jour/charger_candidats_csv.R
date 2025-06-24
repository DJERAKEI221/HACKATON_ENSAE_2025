# Script pour charger les candidats depuis candidats_bureau.csv
# À exécuter pour mettre à jour les candidats

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

cat("CHARGEMENT DES CANDIDATS\n")
cat("------------------------\n\n")

# Connexion à la base de données
db_path <- "data/elections.db"
cat("Connexion à la base de données:", db_path, "\n")
if (!file.exists(db_path)) {
  stop(sprintf("ERREUR: La base de données %s n'existe pas", db_path))
}

con <- dbConnect(RSQLite::SQLite(), db_path)
cat("Connexion à la base de données établie\n")

# Définir le chemin du fichier CSV
csv_path <- "data/candidats_bureau.csv"
cat("Recherche du fichier CSV:", csv_path, "\n")
if (!file.exists(csv_path)) {
  stop(sprintf("ERREUR: Le fichier %s n'existe pas", csv_path))
}
cat("Fichier CSV trouvé\n")

# Lecture du fichier CSV avec gestion d'erreur
tryCatch({
  # Lire le fichier avec readr qui gère mieux les encodages
  candidats <- readr::read_delim(csv_path, 
                               delim = ";",
                               locale = locale(encoding = "latin1"),  # Utiliser latin1 pour les caractères spéciaux
                               show_col_types = FALSE,
                               na = c("", "NA", "N/A"),
                               trim_ws = TRUE)
  
  # Supprimer les colonnes vides
  candidats <- candidats[, !grepl("^\\.\\.\\.", names(candidats))]
  
  # Nettoyer les noms de colonnes
  names(candidats) <- tolower(names(candidats))
  names(candidats) <- gsub(" ", "_", names(candidats))
  
  cat("Lecture du fichier candidats_bureau.csv réussie!\n")
}, error = function(e) {
  stop(sprintf("Erreur lors de la lecture du fichier candidats_bureau.csv : %s", e$message))
})

# Renommer les colonnes si nécessaire
if ("numero_etudiant" %in% names(candidats)) {
  names(candidats)[names(candidats) == "numero_etudiant"] <- "identifiant"
}

# Vérifier les colonnes requises
required_cols <- c("identifiant", "nom", "prenom", "poste", "categorie")
missing_cols <- setdiff(required_cols, names(candidats))
if (length(missing_cols) > 0) {
  stop(sprintf("Colonnes manquantes dans candidats_bureau.csv : %s", paste(missing_cols, collapse = ", ")))
}

# Nettoyer les données
candidats$nom <- stringi::stri_trans_general(candidats$nom, "Latin-ASCII")
candidats$prenom <- stringi::stri_trans_general(candidats$prenom, "Latin-ASCII")
candidats$poste <- stringi::stri_trans_general(candidats$poste, "Latin-ASCII")
candidats$categorie <- stringi::stri_trans_general(candidats$categorie, "Latin-ASCII")

# Nettoyer les espaces
candidats$nom <- trimws(candidats$nom)
candidats$prenom <- trimws(candidats$prenom)
candidats$poste <- trimws(candidats$poste)
candidats$categorie <- trimws(candidats$categorie)

# Supprimer les espaces multiples dans les postes
candidats$poste <- gsub("\\s+", " ", candidats$poste)

# Mapping des postes
poste_mapping <- c(
  "President(e)" = "Président(e)",
  "Secretaire general(e)" = "Secrétaire général(e)",
  "Secretaire a la communication" = "Secrétaire à la communication",
  "Secretaire a l'organisation" = "Secrétaire à l'organisation",
  "Secretaire a l organisation" = "Secrétaire à l'organisation",
  "Secretaire organisation" = "Secrétaire à l'organisation",
  "Secretaire aux affaires sociales" = "Secrétaire aux affaires sociales",
  "Secretaire aux relations exterieures" = "Secrétaire aux relations extérieures",
  "Secretaire aux affaires culturelles et sportives" = "Secrétaire aux affaires culturelles et sportives",
  "Tesorier(e)" = "Tésorier(e)",
  "Tresorier(e) adjoint(e)" = "Tésorier(e) adjoint(e)",
  "Commissaire au compte" = "Commisaire aux comptes",
  "Commisaire au compte adjoint" = "Commisaire aux comptes adjoint",
  "President (e) de la Junior Entreprise (JE)" = "Président(e) de la Junior Entreprise (JE)",
  "1er Conseiller a la Junion Entreprise" = "1er Conseiller à la Junior Entreprise",
  "2eme Conseiller a la Junion Entreprise" = "2ème Conseiller à la Junior Entreprise",
  "President(e) du club presse" = "Président(e) du club presse",
  "President(e) du club informatique" = "Président(e) du club informatique",
  "President(e) du club leadership" = "Président(e) du club leadership",
  "President(e) du club d'anglais" = "Président(e) du club d'anglais",
  "President(e) du club d anglais" = "Président(e) du club d'anglais",
  "President(e) du club anglais" = "Président(e) du club d'anglais",
  "Charge(e) affaires sociales" = "Chargé(e) affaires sociales",
  "Charge(e) des affaires culturelles et sportives" = "Chargé(e) des affaires culturelles et sportives"
)

# Corriger les postes
candidats$poste <- poste_mapping[candidats$poste]

# Supprimer tous les votes et candidats existants
dbExecute(con, "DELETE FROM votes")
dbExecute(con, "DELETE FROM candidates")

# Récupérer la liste des postes avec leurs IDs
postes_db <- dbGetQuery(con, "SELECT id, name FROM positions")
postes_mapping <- setNames(postes_db$id, postes_db$name)

# Afficher les postes uniques pour debug
cat("\nPostes uniques dans le CSV:\n")
print(unique(candidats$poste))
cat("\nPostes disponibles dans la base:\n")
print(names(postes_mapping))

# Traiter chaque candidat du CSV
candidats_ajoutes <- 0
for (i in 1:nrow(candidats)) {
  candidat <- candidats[i, ]
  nom_complet <- paste(candidat$prenom, candidat$nom)
  poste_id <- postes_mapping[candidat$poste]
  
  if (!is.na(poste_id)) {
  tryCatch({
    dbExecute(con, "
      INSERT INTO candidates (name, position_id, program, bio)
        VALUES (?, ?, ?, '')
      ", params = list(nom_complet, poste_id, "Programme à venir"))
    candidats_ajoutes <- candidats_ajoutes + 1
      cat("OK:", nom_complet, "ajouté comme candidat pour", candidat$poste, "\n")
  }, error = function(e) {
      cat("ATTENTION: Erreur lors de l'ajout de", nom_complet, ":", e$message, "\n")
  })
  } else {
    cat("ATTENTION: Poste invalide pour", nom_complet, ":", candidat$poste, "\n")
    cat("   Postes disponibles:", paste(names(postes_mapping), collapse = ", "), "\n")
  }
}

# Statistiques finales
cat("\nRESUME:\n")
cat("   Candidats ajoutés:", candidats_ajoutes, "\n")

# Vérification finale
total_candidats <- dbGetQuery(con, "SELECT COUNT(*) as count FROM candidates")$count
cat("   Total candidats en base:", total_candidats, "\n")

# Statistiques par catégorie
if (total_candidats > 0) {
  stats <- dbGetQuery(con, "
    SELECT p.category, COUNT(*) as nb
    FROM candidates c
    JOIN positions p ON c.position_id = p.id
    GROUP BY p.category
  ")
  
  cat("\nSTATISTIQUES PAR CATEGORIE:\n")
  for (i in 1:nrow(stats)) {
    cat("  -", stats$category[i], ":", stats$nb[i], "candidats\n")
  }
}

# Afficher quelques exemples
if (total_candidats > 0) {
  exemples <- dbGetQuery(con, "
    SELECT c.name, p.name as poste, p.category
    FROM candidates c
    JOIN positions p ON c.position_id = p.id
    ORDER BY p.order_priority
    LIMIT 10
  ")
  
  cat("\nEXEMPLES DE CANDIDATS CHARGES:\n")
  for (i in 1:nrow(exemples)) {
    cat("  -", exemples$name[i], "->", exemples$poste[i], "(", exemples$category[i], ")\n")
  }
}

# Fermer la connexion à la base de données
dbDisconnect(con)
cat("\nTERMINE! Les candidats ont ete charges depuis candidats_bureau.csv\n")
cat("   Vous pouvez maintenant relancer l'application Shiny.\n") 