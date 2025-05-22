# Script pour recréer la base de données avec Idriss SOMA BEN et Mamady BERETE I

# Charger les bibliothèques nécessaires
library(DBI)
library(RSQLite)

# Vérifier si la base de données existe
if (file.exists("data/elections.db")) {
  # Essayer de supprimer la base de données existante
  tryCatch({
    file.remove("data/elections.db")
    cat("Base de données existante supprimée avec succès.\n")
  }, error = function(e) {
    stop("Impossible de supprimer la base de données. Elle est peut-être utilisée par l'application Shiny. Veuillez fermer l'application d'abord.\n")
  })
}

# Créer le dossier data s'il n'existe pas
if (!dir.exists("data")) {
  dir.create("data", showWarnings = FALSE)
}

# Connexion à la nouvelle base de données
con <- dbConnect(RSQLite::SQLite(), "data/elections.db")
dbExecute(con, "PRAGMA foreign_keys = ON")

cat("Création des tables...\n")

# Création de la table voters
dbExecute(con, "
CREATE TABLE IF NOT EXISTS voters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id TEXT UNIQUE NOT NULL,
  access_code TEXT NOT NULL,
  voted INTEGER DEFAULT 0
)")

# Table des postes électoraux
dbExecute(con, "
CREATE TABLE IF NOT EXISTS positions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  max_votes INTEGER DEFAULT 1
)")

# Table des candidats
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

# Table des votes
dbExecute(con, "
CREATE TABLE IF NOT EXISTS votes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  voter_id INTEGER NOT NULL,
  candidate_id INTEGER NOT NULL,
  position_id INTEGER NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(voter_id) REFERENCES voters(id),
  FOREIGN KEY(candidate_id) REFERENCES candidates(id),
  FOREIGN KEY(position_id) REFERENCES positions(id),
  UNIQUE(voter_id, position_id)
)")

cat("Insertion des postes électoraux...\n")

# Insertion des postes électoraux
positions <- data.frame(
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
for (i in 1:nrow(positions)) {
  dbExecute(con, 
    "INSERT OR IGNORE INTO positions (name, description, max_votes) VALUES (?, ?, ?)",
    params = list(positions$name[i], positions$description[i], positions$max_votes[i])
  )
}

cat("Insertion des candidats avec photos...\n")

# Insérer des candidats exemples
candidates <- data.frame(
  name = c(
    "Idriss SOMA BEN", "Mamady BERETE I", 
    "Ibrahim Sow", "Jacques ILLY",
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

for (i in 1:nrow(candidates)) {
  dbExecute(con, 
    "INSERT OR IGNORE INTO candidates (name, position_id, program) VALUES (?, ?, ?)",
    params = list(candidates$name[i], candidates$position_id[i], candidates$program[i])
  )
}

cat("Ajout des biographies et programmes détaillés...\n")

# Ajout de biographies et programmes supplémentaires aux candidats
dbExecute(con, "
  UPDATE candidates SET 
  bio = 'Étudiant en 3ème année à l''ENSAE, Idriss SOMA BEN est connu pour son leadership et son implication dans les activités associatives. Il a organisé plusieurs événements majeurs dont la Journée Portes Ouvertes 2023.',
  program = 'Mon programme s''articule autour de 3 axes majeurs:
  1. Moderniser les infrastructures de l''école
  2. Organiser plus d''activités culturelles et sportives
  3. Renforcer les liens avec les entreprises pour faciliter l''insertion professionnelle
  
  Je m''engage à être à l''écoute de tous les étudiants et à représenter leurs intérêts.'
  WHERE id = 1
")

dbExecute(con, "
  UPDATE candidates SET 
  bio = 'Étudiant en 2ème année, Mamady BERETE I est très impliqué dans la vie associative de l''école. Il a déjà été secrétaire du club de débat et est reconnu pour son esprit d''équipe et sa rigueur.',
  program = 'Je souhaite dynamiser la vie étudiante avec:
  - Des week-ends d''intégration plus inclusifs
  - Un calendrier d''événements diversifiés
  - Des partenariats avec d''autres écoles pour élargir notre réseau
  
  Mon objectif est d''améliorer votre qualité de vie pendant vos études.'
  WHERE id = 2
")

dbExecute(con, "
  UPDATE candidates SET 
  bio = 'Ibrahim est un étudiant brillant en Master spécialisé en économie financière. Il a réalisé un stage dans un cabinet de conseil reconnu et possède une solide expérience en gestion de projets.',
  program = 'Pour la Junior Entreprise, je propose:
  - Développer de nouveaux services d''analyse de données et de conseil
  - Doubler le chiffre d''affaires en un an
  - Former les membres aux méthodologies professionnelles
  - Créer un réseau d''alumni pour obtenir plus de contrats
  
  Mon expérience en conseil sera un atout pour développer notre JE.'
  WHERE id = 3
")

dbExecute(con, "
  UPDATE candidates SET 
  bio = 'Aminata est en dernière année du cursus ingénieur. Elle a participé à plusieurs projets innovants et a cofondé un start-up dans le domaine de la finance durable pendant ses études.',
  program = 'Ma vision pour la Junior Entreprise:
  - Se positionner sur des projets d''innovation et de développement durable
  - Mettre en place un process de qualité certifié
  - Organiser des formations techniques avancées pour les membres
  - Développer les partenariats internationaux
  
  Ensemble, faisons de notre JE une référence dans le domaine de la data science.'
  WHERE id = 4
")

cat("Ajout des photos des candidats...\n")

# Ajout des URLs de photos pour les candidats
dbExecute(con, "
  UPDATE candidates SET 
  photo_url = 'images/pr_BEN.jpg'
  WHERE id = 1
")

dbExecute(con, "
  UPDATE candidates SET 
  photo_url = 'images/pr_Berete.jpg'
  WHERE id = 2
")

dbExecute(con, "
  UPDATE candidates SET 
  photo_url = 'images/candidates/ibrahim_sow.jpg'
  WHERE id = 3
")

dbExecute(con, "
  UPDATE candidates SET 
  photo_url = 'images/candidates/aminata_traore.jpg'
  WHERE id = 4
")

dbExecute(con, "
  UPDATE candidates SET 
  photo_url = 'images/candidates/david_mensah.jpg'
  WHERE id = 5
")

dbExecute(con, "
  UPDATE candidates SET 
  photo_url = 'images/candidates/fatou_ndiaye.jpg'
  WHERE id = 6
")

# Vérification
tables <- dbListTables(con)
if (all(c("positions", "candidates", "votes", "voters") %in% tables)) {
  cat("Base de données créée avec succès !\n")
  
  # Vérification des postes
  pos_count <- dbGetQuery(con, "SELECT COUNT(*) FROM positions")[[1]]
  cat(sprintf("Nombre de postes électoraux: %d\n", pos_count))
  
  # Vérification des candidats
  cand_count <- dbGetQuery(con, "SELECT COUNT(*) FROM candidates")[[1]]
  cat(sprintf("Nombre de candidats: %d\n", cand_count))
  
  # Afficher les candidats
  candidates <- dbGetQuery(con, "SELECT id, name, position_id, photo_url FROM candidates ORDER BY id")
  print(candidates)
}

# Fermer la connexion
dbDisconnect(con)

cat("\nFERMEZ L'APPLICATION SHINY AVANT D'EXÉCUTER CE SCRIPT, PUIS RELANCEZ L'APPLICATION!\n") 