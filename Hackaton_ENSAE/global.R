# global.R - Configuration globale simplifiée
library(shiny)
library(bslib)
library(DBI)
library(RSQLite)
library(shinyjs)
library(ggplot2)
library(DT)
library(digest)
library(fontawesome)
library(rmarkdown)
# Packages nécessaires pour la génération de PDF
library(knitr)
if(!requireNamespace("kableExtra", quietly = TRUE)) {
  install.packages("kableExtra", repos = "https://cloud.r-project.org")
}
library(kableExtra)
if(requireNamespace("tinytex", quietly = TRUE)) {
  library(tinytex)
  if(!tinytex::is_tinytex()) {
    message("TinyTeX n'est pas installé. Certaines fonctionnalités PDF pourraient ne pas fonctionner.")
    message("Exécutez le script check_packages.R pour installer les dépendances manquantes.")
  }
}

# Création du dossier data s'il n'existe pas
if (!dir.exists("data")) {
  dir.create("data", showWarnings = FALSE, recursive = TRUE)
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
    max_votes INTEGER DEFAULT 1
  )")

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
    voter_id INTEGER NOT NULL,
    candidate_id INTEGER NOT NULL,
    position_id INTEGER NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    hash TEXT UNIQUE
  )")

dbExecute(con, "
  CREATE TABLE IF NOT EXISTS voters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id TEXT UNIQUE NOT NULL,
    access_code TEXT NOT NULL,
    year TEXT,
    voted INTEGER DEFAULT 0
  )")

# Insertion des postes électoraux s'ils n'existent pas
positions_data <- data.frame(
  name = c(
    "Président de l'Amicale",
    "Président de la Junior Entreprise",
    "Secrétaire Général",
    "Secrétaire chargé à l'Organisation",
    "Conseiller à la Junior Entreprise",
    "Président du Club Leadership",
    "Président du Club Anglais",
    "Président du Club Informatique",
    "Chargé de la Communication"
  ),
  description = c(
    "Représente les étudiants et coordonne les activités de l'amicale",
    "Dirige les projets et activités de la Junior Entreprise",
    "Gestion administrative et procès-verbaux des réunions",
    "Coordination logistique des événements",
    "Apporte expertise et conseil aux projets de la JE",
    "Animation du club de développement personnel et leadership",
    "Coordination des activités d'apprentissage de l'anglais",
    "Organisation des projets et ateliers informatiques",
    "Gestion de la communication interne et externe"
  ),
  max_votes = rep(1, 9)
)

# Insérer les postes
for (i in 1:nrow(positions_data)) {
  dbExecute(con, 
    "INSERT OR IGNORE INTO positions (name, description, max_votes) VALUES (?, ?, ?)",
    params = list(positions_data$name[i], positions_data$description[i], positions_data$max_votes[i])
  )
}

# Exemples de candidats
candidates_data <- data.frame(
  name = c(
    "Idriss SOMA BEN", "Mamady BERETE I", 
    "Ibrahim Sow", "Aminata Traoré",
    "David Mensah", "Fatou Ndiaye"
  ),
  position_id = c(1, 1, 2, 2, 3, 3),
  program = c(
    "Modernisation des infrastructures de l'école",
    "Amélioration du cadre de vie et des activités",
    "Développement de partenariats avec les entreprises",
    "Intégration de projets innovants",
    "Digitalisation de la gestion administrative",
    "Transparence et communication efficace"
  )
)

# Insérer les candidats
for (i in 1:nrow(candidates_data)) {
  dbExecute(con, 
    "INSERT OR IGNORE INTO candidates (name, position_id, program) VALUES (?, ?, ?)",
    params = list(candidates_data$name[i], candidates_data$position_id[i], candidates_data$program[i])
  )
}

# Ajout de biographies et programmes détaillés aux candidats
candidate_updates <- list(
  list(
    id = 1, 
    bio = "Étudiant en 3ème année à l'ENSAE, Idriss SOMA BEN est connu pour son leadership et son implication dans les activités associatives. Il a organisé plusieurs événements majeurs dont la Journée Portes Ouvertes 2023.",
    program = "Mon programme s'articule autour de 3 axes majeurs:
1. Moderniser les infrastructures de l'école
2. Organiser plus d'activités culturelles et sportives
3. Renforcer les liens avec les entreprises pour faciliter l'insertion professionnelle

Je m'engage à être à l'écoute de tous les étudiants et à représenter leurs intérêts.",
    photo_url = "images/pr_BEN.jpg"
  ),
  list(
    id = 2, 
    bio = "Étudiant en 2ème année, Mamady BERETE I est très impliqué dans la vie associative de l'école. Il a déjà été secrétaire du club de débat et est reconnu pour son esprit d'équipe et sa rigueur.",
    program = "Je souhaite dynamiser la vie étudiante avec:
- Des week-ends d'intégration plus inclusifs
- Un calendrier d'événements diversifiés
- Des partenariats avec d'autres écoles pour élargir notre réseau

Mon objectif est d'améliorer votre qualité de vie pendant vos études.",
    photo_url = "images/pr_Berete.jpg"
  ),
  list(
    id = 3, 
    bio = "Ibrahim est un étudiant brillant en Master spécialisé en économie financière. Il a réalisé un stage dans un cabinet de conseil reconnu et possède une solide expérience en gestion de projets.",
    program = "Pour la Junior Entreprise, je propose:
- Développer de nouveaux services d'analyse de données et de conseil
- Doubler le chiffre d'affaires en un an
- Former les membres aux méthodologies professionnelles
- Créer un réseau d'alumni pour obtenir plus de contrats

Mon expérience en conseil sera un atout pour développer notre JE.",
    photo_url = "images/candidates/ibrahim_sow.jpg"
  ),
  list(
    id = 4, 
    bio = "Aminata est en dernière année du cursus ingénieur. Elle a participé à plusieurs projets innovants et a cofondé un start-up dans le domaine de la finance durable pendant ses études.",
    program = "Ma vision pour la Junior Entreprise:
- Se positionner sur des projets d'innovation et de développement durable
- Mettre en place un process de qualité certifié
- Organiser des formations techniques avancées pour les membres
- Développer les partenariats internationaux

Ensemble, faisons de notre JE une référence dans le domaine de la data science.",
    photo_url = "images/candidates/aminata_traore.jpg"
  )
)

# Mettre à jour les données des candidats
for (update in candidate_updates) {
  dbExecute(con, 
    "UPDATE candidates SET bio = ?, program = ?, photo_url = ? WHERE id = ?",
    params = list(update$bio, update$program, update$photo_url, update$id)
  )
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
APP_NAME <- "Élections ENSAE 2024"
APP_VERSION <- "1.0.0"
CURRENT_YEAR <- format(Sys.Date(), "%Y")
