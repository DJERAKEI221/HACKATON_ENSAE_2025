# global.R - Configuration globale simplifiée

# Installation et chargement des packages nécessaires
if (!require("pacman")) {
  cat("Installation de pacman pour la gestion des packages...\n")
  install.packages("pacman", repos = "https://cloud.r-project.org")
}

cat("Chargement des packages nécessaires...\n")

# Charger tous les packages requis avec pacman
# p_load installe automatiquement les packages manquants
pacman::p_load(
  # Packages Shiny et interface
  shiny,          # Framework principal
  bslib,          # Bootstrap pour Shiny
  shinyjs,        # JavaScript pour Shiny
  fontawesome,    # Icônes
  
  # Base de données
  DBI,            # Interface base de données
  RSQLite,        # SQLite pour R
  
  # Visualisation
  ggplot2,        # Graphiques
  DT,             # Tables interactives
  
  # Manipulation de données
  dplyr,          # Manipulation de données
  
  # Utilitaires
  digest,         # Hachage cryptographique
  
  # Génération de rapports
  rmarkdown,      # Documents R Markdown
  knitr,          # Moteur de rapport
  kableExtra      # Tables améliorées
)

# Vérifier l'installation de TinyTeX pour la génération de PDF
if (requireNamespace("tinytex", quietly = TRUE)) {
    if (!tinytex::is_tinytex()) {
      cat("Installation de TinyTeX pour la génération de PDF...\n")
      tryCatch({
        tinytex::install_tinytex()
        cat("TinyTeX installé avec succès.\n")
      }, error = function(e) {
      cat("Avertissement: TinyTeX n'a pas pu être installé. La génération de PDF pourrait ne pas fonctionner.\n")
      cat("Erreur:", e$message, "\n")
      })
    } else {
      cat("TinyTeX est déjà installé.\n")
    }
} else {
  # Installer tinytex si nécessaire
  pacman::p_load(tinytex)
}

cat("Tous les packages ont été chargés avec succès.\n\n")

# Charger les modules de notification et mises à jour en temps réel
source("modules/notification_module.R")
source("modules/realtime_updates.R")
source("modules/gamification_module.R")
source("modules/announcement_system.R")
source("modules/push_notification_service.R")

# Charger les modules d'interface UI
source("ui/ui_admin.R")

# Création du dossier data s'il n'existe pas
if (!dir.exists("data")) {
  dir.create("data", showWarnings = FALSE, recursive = TRUE)
}

# Chargement des données étudiants depuis le fichier CSV
# Le séparateur est le point-virgule comme spécifié
# Utiliser read.table avec des paramètres plus robustes pour gérer l'encodage
students_df <- tryCatch({
  # Essayer d'abord avec read.table et latin1 (plus robuste)
  read.table(file = "data/base_eleves.csv", sep = ";", header = TRUE,
             stringsAsFactors = FALSE, fileEncoding = "latin1",
             quote = "\"", fill = TRUE, comment.char = "")
}, error = function(e1) {
  cat("Erreur avec read.table latin1:", e1$message, "\n")
  tryCatch({
    # Si ça échoue, essayer avec UTF-8
    read.table(file = "data/base_eleves.csv", sep = ";", header = TRUE,
               stringsAsFactors = FALSE, fileEncoding = "UTF-8",
               quote = "\"", fill = TRUE, comment.char = "")
  }, error = function(e2) {
    cat("Erreur avec read.table UTF-8:", e2$message, "\n")
    # En dernier recours, utiliser read.csv standard
    read.csv(file = "data/base_eleves.csv", sep = ";", stringsAsFactors = FALSE)
  })
})

# Nettoyer les données - supprimer les lignes avec des valeurs manquantes importantes
students_df <- students_df[!is.na(students_df$Identifiant) & 
                          !is.na(students_df$Nom) & 
                          !is.na(students_df$Prenom) &
                          students_df$Identifiant != "" &
                          students_df$Nom != "" &
                          students_df$Prenom != "", ]

# Afficher un message de débogage pour vérifier le chargement
cat("CSV chargé avec", nrow(students_df), "étudiants\n")
if (nrow(students_df) > 0) {
  cat("Exemple d'étudiant:", students_df$Prenom[1], students_df$Nom[1], "\n")
}

# Vérifier si le fichier de base de données existe
db_file <- "data/elections.db"
db_exists <- file.exists(db_file)

# Connexion à la base de données
con <- dbConnect(RSQLite::SQLite(), db_file)
# Si la connexion est fermée (pour une raison quelconque), la rouvrir
onStop(function() {
  if (dbIsValid(con)) {
    dbDisconnect(con)
  }
})

# Utiliser une réactive pour les données partagées
values <- reactiveValues(
  con = con,
  positions = NULL,
  candidates = NULL,
  votes = NULL
)

# Création des tables nécessaires si elles n'existent pas
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    category TEXT,
    order_priority INTEGER DEFAULT 0,
    max_votes INTEGER DEFAULT 1
  )")

# Ajouter les colonnes manquantes si elles n'existent pas (pour les bases existantes)
tryCatch({
  dbExecute(con, "ALTER TABLE positions ADD COLUMN category TEXT")
  cat("OK: Colonne 'category' ajoutée à la table positions\n")
}, error = function(e) {
  if (grepl("duplicate column name", e$message, ignore.case = TRUE)) {
    # La colonne existe déjà, c'est normal
  } else {
    cat("ATTENTION: Erreur lors de l'ajout de la colonne category:", e$message, "\n")
  }
})

tryCatch({
  dbExecute(con, "ALTER TABLE positions ADD COLUMN order_priority INTEGER DEFAULT 0")
  cat("OK: Colonne 'order_priority' ajoutée à la table positions\n")
}, error = function(e) {
  if (grepl("duplicate column name", e$message, ignore.case = TRUE)) {
    # La colonne existe déjà, c'est normal
  } else {
    cat("ATTENTION: Erreur lors de l'ajout de la colonne order_priority:", e$message, "\n")
  }
})

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS candidates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    position_id INTEGER NOT NULL,
    program TEXT,
    bio TEXT,
    photo_url TEXT,
    FOREIGN KEY(position_id) REFERENCES positions(id),
    UNIQUE(name, position_id)
  )")

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS votes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    voter_id TEXT NOT NULL,
    candidate_id INTEGER NOT NULL,
    position_id INTEGER NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    hash TEXT UNIQUE
  )")

# Création de la table voters pour stocker les informations des électeurs
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS voters (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    classe TEXT,
    has_voted INTEGER DEFAULT 0,
    vote_timestamp DATETIME,
    year INTEGER DEFAULT 2025
  )")

# Peupler la table voters avec les étudiants si elle est vide
voters_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM voters")$count
if (voters_count == 0 && nrow(students_df) > 0) {
  cat("Peuplement de la table voters avec les étudiants...\n")
  
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
    }, error = function(e) {
      # Ignorer les erreurs d'insertion (doublons, etc.)
    })
  }
  
  voters_added <- dbGetQuery(con, "SELECT COUNT(*) as count FROM voters")$count
  cat("OK: ", voters_added, " électeurs ajoutés à la base de données\n")
}

# Insertion des postes électoraux avec hiérarchie exacte
positions_data <- data.frame(
  name = c(
    # Bureau exécutif - ordre hiérarchique exact
    "Président(e)",
    "Secrétaire général(e)",
    "Secrétaire à la communication",
    "Secrétaire à l'organisation",
    "Secrétaire aux affaires sociales",
    "Secrétaire aux relations extérieures",
    "Secrétaire aux affaires culturelles et sportives",
    "Tésorier(e)",
    "Tésorier(e) adjoint(e)",
    "Commisaire aux comptes",
    "Commisaire aux comptes adjoint",
    
    # Départements permanents - ordre hiérarchique exact
    "Président(e) de la Junior Entreprise (JE)",
    "1er Conseiller à la Junior Entreprise",
    "2ème Conseiller à la Junior Entreprise",
    "Président(e) du club presse",
    "Président(e) du club informatique",
    "Président(e) du club leadership",
    "Président(e) du club d'anglais",
    "Chargé(e) affaires sociales",
    "Chargé(e) des affaires culturelles et sportives"
  ),
  description = c(
    # Bureau exécutif
    "Dirige l'association et représente les étudiants",
    "Gestion administrative et coordination générale",
    "Responsable de la communication interne et externe",
    "Coordination logistique des événements et activités",
    "Gestion des affaires sociales et du bien-être étudiant",
    "Développement des partenariats et relations externes",
    "Organisation des activités culturelles et sportives",
    "Gestion financière et budgétaire de l'association",
    "Assistance au tésorier dans la gestion financière",
    "Contrôle et vérification des comptes de l'association",
    "Assistance au commisaire aux comptes",
    
    # Départements permanents
    "Direction de la Junior Entreprise et projets étudiants",
    "Premier conseiller pour les projets de la Junior Entreprise",
    "Deuxième conseiller pour les projets de la Junior Entreprise",
    "Direction du club presse et publications",
    "Direction du club informatique et projets tech",
    "Direction du club leadership et développement personnel",
    "Direction du club d'anglais et activités linguistiques",
    "Responsable des affaires sociales étudiantes",
    "Responsable des activités culturelles et sportives"
  ),
  category = c(
    # Bureau exécutif
    rep("Bureau exécutif", 11),
    
    # Départements permanents
    rep("Départements permanents", 9)
  ),
  order_priority = c(
    # Bureau exécutif - ordre hiérarchique (1 = plus important)
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    
    # Départements permanents - ordre hiérarchique (12 = début des départements)
    12, 13, 14, 15, 16, 17, 18, 19, 20
  ),
  max_votes = rep(1, 20)
)

# Vérifier si nous avons déjà les nouveaux postes
existing_positions <- dbGetQuery(con, "SELECT COUNT(*) as count FROM positions")$count

if (existing_positions < 20) {
  cat("Mise à jour vers les nouveaux postes hiérarchiques...\n")
  
  # Supprimer les anciens postes pour faire place aux nouveaux
  dbExecute(con, "DELETE FROM votes")
  dbExecute(con, "DELETE FROM candidates") 
  dbExecute(con, "DELETE FROM positions")
  
  # Insérer les postes
  for (i in 1:nrow(positions_data)) {
    dbExecute(con, 
      "INSERT OR IGNORE INTO positions (name, description, category, order_priority, max_votes) VALUES (?, ?, ?, ?, ?)",
      params = list(positions_data$name[i], positions_data$description[i], positions_data$category[i], positions_data$order_priority[i], positions_data$max_votes[i])
    )
  }
  
  cat("OK: Nouveaux postes hiérarchiques installés\n")
} else {
  # Mettre à jour les catégories des postes existants si elles sont manquantes
  positions_without_category <- dbGetQuery(con, "SELECT COUNT(*) as count FROM positions WHERE category IS NULL")$count
  
  if (positions_without_category > 0) {
    cat("Mise à jour des catégories manquantes...\n")
    
    # Mettre à jour les catégories basées sur les noms
    dbExecute(con, "UPDATE positions SET category = 'Bureau exécutif' WHERE name LIKE '%Président%' OR name LIKE '%Secrétaire%' OR name LIKE '%Tésorier%' OR name LIKE '%Commisaire%'")
    dbExecute(con, "UPDATE positions SET category = 'Départements permanents' WHERE name LIKE '%Junior Entreprise%' OR name LIKE '%JE%' OR name LIKE '%Conseiller%' OR name LIKE '%club%' OR name LIKE '%Chargé%'")
    
    cat("OK: Catégories mises à jour\n")
  }
  
  cat("INFO: Postes existants conservés\n")
}


 
  



# Fonction pour obtenir automatiquement le nom complet d'un utilisateur
get_full_name <- function(user_id) {
  # Recherche dans les données étudiants
  if (!is.null(user_id) && user_id != "") {
    # Vérifier si c'est un admin
    if (user_id %in% c("admin1", "admin2", "admin3")) {
      return("Administrateur Système")
    }
    
    # Chercher dans la base des étudiants
    student_info <- students_df[students_df$Identifiant == user_id, ]
    if (nrow(student_info) > 0) {
      return(paste(student_info$Prenom[1], student_info$Nom[1]))
    }
  }
  
  # Valeur par défaut si aucune correspondance n'est trouvée
  return("Utilisateur Inconnu")
}

# Créer le nom complet pour chaque étudiant en utilisant la nouvelle fonction
for (i in 1:nrow(students_df)) {
  students_df$nom_complet[i] <- get_full_name(students_df$Identifiant[i])
}

# Vérifier s'il faut générer des candidats aléatoires
existing_candidates_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM candidates")$count

# CHARGEMENT AUTOMATIQUE DES CANDIDATS DEPUIS LE CSV
# Charger les candidats depuis candidats_bureau.csv si le fichier existe et qu'il y a peu de candidats
if (existing_candidates_count < 5 && file.exists("data/candidats_bureau.csv")) {
  cat("Chargement des candidats depuis candidats_bureau.csv...\n")
  
  # Charger le fichier CSV des candidats
  candidats_csv <- tryCatch({
    read.table(file = "data/candidats_bureau.csv", sep = ";", header = TRUE,
               stringsAsFactors = FALSE, fileEncoding = "latin1",
               quote = "\"", fill = TRUE, comment.char = "")
  }, error = function(e1) {
    tryCatch({
      read.table(file = "data/candidats_bureau.csv", sep = ";", header = TRUE,
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8",
                 quote = "\"", fill = TRUE, comment.char = "")
    }, error = function(e2) {
      read.csv(file = "data/candidats_bureau.csv", sep = ";", stringsAsFactors = FALSE)
    })
  })
  
  # Vérifier les colonnes requises
  colonnes_requises <- c("identifiant", "nom", "prenom", "poste", "categorie", "biographie", "programme")
  if (all(colonnes_requises %in% names(candidats_csv))) {
    
    # Supprimer tous les votes et candidats existants
    dbExecute(con, "DELETE FROM votes")
    dbExecute(con, "DELETE FROM candidates")
    
    # Récupérer la liste des postes avec leurs IDs
    postes_db <- dbGetQuery(con, "SELECT id, name FROM positions")
    postes_mapping <- setNames(postes_db$id, postes_db$name)
    
    # Traiter chaque candidat du CSV
    candidats_ajoutes <- 0
    for (i in 1:nrow(candidats_csv)) {
      candidat <- candidats_csv[i, ]
      # Utiliser la fonction get_full_name si l'identifiant est disponible
      if ("identifiant" %in% names(candidat) && !is.na(candidat$identifiant) && candidat$identifiant != "") {
        nom_complet <- get_full_name(candidat$identifiant)
      } else {
        # Fallback à la méthode manuelle si pas d'identifiant
        nom_complet <- paste(candidat$prenom, candidat$nom)
      }
      poste_id <- postes_mapping[candidat$poste]
      
      if (!is.na(poste_id)) {
        tryCatch({
          dbExecute(con, "
            INSERT INTO candidates (name, position_id, program, bio)
            VALUES (?, ?, ?, ?)
          ", params = list(nom_complet, poste_id, candidat$programme, candidat$biographie))
          candidats_ajoutes <- candidats_ajoutes + 1
        }, error = function(e) {
          cat("ATTENTION: Erreur lors de l'ajout de", nom_complet, "\n")
        })
      }
    }
    
    cat("OK: Candidats chargés depuis CSV:", candidats_ajoutes, "\n")
  } else {
    cat("ATTENTION: Format CSV candidats invalide\n")
  }
}

# Création des tables pour les délégués de classe
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS delegate_candidates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id TEXT NOT NULL,
    name TEXT NOT NULL,
    classe TEXT NOT NULL,
    position_type TEXT NOT NULL,
    program TEXT,
    bio TEXT,
    photo_url TEXT DEFAULT 'images/default_candidate.png'
  )
")

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS delegate_votes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    voter_id TEXT NOT NULL,
    candidate_id INTEGER NOT NULL,
    classe TEXT NOT NULL,
    position_type TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(candidate_id) REFERENCES delegate_candidates(id)
  )
")

# Création de la table des administrateurs
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'admin'
  )
")

# Insertion des administrateurs par défaut s'ils n'existent pas déjà
admin_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM admins")$count
if (admin_count == 0) {
  cat("Création des comptes administrateurs par défaut...\n")
  
  # Insérer les trois administrateurs demandés
  dbExecute(con, "INSERT OR IGNORE INTO admins (username, password, role) VALUES ('admin1', 'admin1', 'admin')")
  dbExecute(con, "INSERT OR IGNORE INTO admins (username, password, role) VALUES ('admin2', 'admin2', 'admin')")
  dbExecute(con, "INSERT OR IGNORE INTO admins (username, password, role) VALUES ('admin3', 'admin3', 'admin')")
  
  cat("OK: Comptes administrateurs créés\n")
}

# CHARGEMENT AUTOMATIQUE DES DÉLÉGUÉS DEPUIS LE CSV
delegate_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM delegate_candidates")
if (delegate_count$count < 5 && file.exists("data/delegues.csv")) {
  cat("Chargement des délégués depuis delegues.csv...\n")
  
  # Charger le fichier CSV des délégués
  delegues_csv <- tryCatch({
    read.table(file = "data/delegues.csv", sep = ";", header = TRUE,
               stringsAsFactors = FALSE, fileEncoding = "latin1",
               quote = "\"", fill = TRUE, comment.char = "")
  }, error = function(e1) {
    tryCatch({
      read.table(file = "data/delegues.csv", sep = ";", header = TRUE,
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8",
                 quote = "\"", fill = TRUE, comment.char = "")
    }, error = function(e2) {
      read.csv(file = "data/delegues.csv", sep = ";", stringsAsFactors = FALSE)
    })
  })
  
  # Vérifier les colonnes requises
  colonnes_requises <- c("identifiant", "nom", "prenom", "classe", "type")
  if (all(colonnes_requises %in% names(delegues_csv))) {
    
    # Supprimer tous les votes et délégués existants
    dbExecute(con, "DELETE FROM delegate_votes")
    dbExecute(con, "DELETE FROM delegate_candidates")
    
    # Traiter chaque délégué du CSV
    delegues_ajoutes <- 0
    for (i in 1:nrow(delegues_csv)) {
      delegue <- delegues_csv[i, ]
      # Utiliser la fonction get_full_name pour récupérer le nom complet
      nom_complet <- get_full_name(delegue$identifiant)
      
      if (delegue$type %in% c("delegue", "adjoint")) {
        # Générer une biographie et un programme par défaut
        bio_default <- paste0("Étudiant(e) en ", delegue$classe, " à l'ENSAE, ", 
                             nom_complet, " est reconnu(e) pour son engagement et son sérieux. ",
                             "Il/Elle souhaite représenter sa classe en tant que ",
                             ifelse(delegue$type == "delegue", "délégué principal", "délégué adjoint"), ".")
        
        programme_default <- ifelse(delegue$type == "delegue",
          "Assurer une communication efficace entre les étudiants et l'administration, organiser des activités de classe et défendre les intérêts des étudiants.",
          "Soutenir le délégué principal dans ses missions et assurer la continuité en cas d'absence.")
        
        tryCatch({
        dbExecute(con, "
          INSERT INTO delegate_candidates (student_id, name, classe, position_type, program, bio)
          VALUES (?, ?, ?, ?, ?, ?)
          ", params = list(delegue$identifiant, nom_complet, delegue$classe, 
                          delegue$type, programme_default, bio_default))
          delegues_ajoutes <- delegues_ajoutes + 1
        }, error = function(e) {
          cat("ATTENTION: Erreur lors de l'ajout de", nom_complet, "\n")
        })
      }
    }
    
    cat("OK: Délégués chargés depuis CSV:", delegues_ajoutes, "\n")
  } else {
    cat("ATTENTION: Format CSV délégués invalide\n")
  }
}

# Récupération des positions pour l'interface
positions <- dbGetQuery(con, "SELECT * FROM positions ORDER BY name")

# Fonctions utilitaires globales
format_date <- function(date) {
  format(date, "%d/%m/%Y %H:%M")
}

get_colors <- function(n) {
  colorRampPalette(c("#2c3e50", "#3498db", "#1abc9c"))(n)
}

generate_hash <- function(data) {
  digest::digest(paste0(data, Sys.time()), algo = "sha256")
}

# Définition des constantes globales
APP_NAME <- "Élections ENSAE 2025"
APP_VERSION <- "1.0.0"
CURRENT_YEAR <- format(Sys.Date(), "%Y")
