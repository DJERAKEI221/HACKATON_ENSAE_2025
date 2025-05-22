# Script pour insérer/mettre à jour les candidats Idriss SOMA BEN et Mamady BERETE I

library(DBI)
library(RSQLite)

# Connexion à la base de données
con <- dbConnect(RSQLite::SQLite(), "data/elections.db")

# Vérifier si la base de données existe
if (file.exists("data/elections.db")) {
  message("Base de données trouvée, mise à jour des candidats...")
  
  # Vérifier si des candidats existent déjà
  existing_candidates <- dbGetQuery(con, "SELECT COUNT(*) as count FROM candidates")
  
  # Si pas de candidats, insérer des données de base
  if (existing_candidates$count == 0) {
    message("Aucun candidat trouvé, création des données de base...")
    
    # Insérer les positions si nécessaire
    positions <- dbGetQuery(con, "SELECT COUNT(*) as count FROM positions")
    if (positions$count == 0) {
      message("Création des postes électoraux...")
      
      # Créer les postes
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
          "INSERT INTO positions (name, description, max_votes) VALUES (?, ?, ?)",
          params = list(positions_data$name[i], positions_data$description[i], positions_data$max_votes[i])
        )
      }
    }
  }
  
  # Insérer/mettre à jour les candidats
  message("Insertion/mise à jour des candidats principaux...")
  
  # Candidat 1: Idriss SOMA BEN
  ben_exists <- dbGetQuery(con, "SELECT COUNT(*) as count FROM candidates WHERE name = 'Idriss SOMA BEN'")
  if (ben_exists$count == 0) {
    dbExecute(con, "
      INSERT INTO candidates (id, name, position_id, program, bio, photo_url) 
      VALUES (1, 'Idriss SOMA BEN', 1, 
        'Mon programme s''articule autour de 3 axes majeurs:
        1. Moderniser les infrastructures de l''école
        2. Organiser plus d''activités culturelles et sportives
        3. Renforcer les liens avec les entreprises pour faciliter l''insertion professionnelle
        
        Je m''engage à être à l''écoute de tous les étudiants et à représenter leurs intérêts.',
        
        'Étudiant en 3ème année à l''ENSAE, Idriss SOMA BEN est connu pour son leadership et son implication dans les activités associatives. Il a organisé plusieurs événements majeurs dont la Journée Portes Ouvertes 2023.',
        
        'images/pr_BEN.jpg'
      )
    ")
    message("Candidat Idriss SOMA BEN inséré.")
  } else {
    dbExecute(con, "
      UPDATE candidates 
      SET position_id = 1,
          program = 'Mon programme s''articule autour de 3 axes majeurs:
          1. Moderniser les infrastructures de l''école
          2. Organiser plus d''activités culturelles et sportives
          3. Renforcer les liens avec les entreprises pour faciliter l''insertion professionnelle
          
          Je m''engage à être à l''écoute de tous les étudiants et à représenter leurs intérêts.',
          
          bio = 'Étudiant en 3ème année à l''ENSAE, Idriss SOMA BEN est connu pour son leadership et son implication dans les activités associatives. Il a organisé plusieurs événements majeurs dont la Journée Portes Ouvertes 2023.',
          
          photo_url = 'images/pr_BEN.jpg'
      WHERE name = 'Idriss SOMA BEN'
    ")
    message("Candidat Idriss SOMA BEN mis à jour.")
  }
  
  # Candidat 2: Mamady BERETE I
  berete_exists <- dbGetQuery(con, "SELECT COUNT(*) as count FROM candidates WHERE name = 'Mamady BERETE I'")
  if (berete_exists$count == 0) {
    dbExecute(con, "
      INSERT INTO candidates (id, name, position_id, program, bio, photo_url) 
      VALUES (2, 'Mamady BERETE I', 1, 
        'Je souhaite dynamiser la vie étudiante avec:
        - Des week-ends d''intégration plus inclusifs
        - Un calendrier d''événements diversifiés
        - Des partenariats avec d''autres écoles pour élargir notre réseau
        
        Mon objectif est d''améliorer votre qualité de vie pendant vos études.',
        
        'Étudiant en 2ème année, Mamady BERETE I est très impliqué dans la vie associative de l''école. Il a déjà été secrétaire du club de débat et est reconnu pour son esprit d''équipe et sa rigueur.',
        
        'images/pr_Berete.jpg'
      )
    ")
    message("Candidat Mamady BERETE I inséré.")
  } else {
    dbExecute(con, "
      UPDATE candidates 
      SET position_id = 1,
          program = 'Je souhaite dynamiser la vie étudiante avec:
          - Des week-ends d''intégration plus inclusifs
          - Un calendrier d''événements diversifiés
          - Des partenariats avec d''autres écoles pour élargir notre réseau
          
          Mon objectif est d''améliorer votre qualité de vie pendant vos études.',
          
          bio = 'Étudiant en 2ème année, Mamady BERETE I est très impliqué dans la vie associative de l''école. Il a déjà été secrétaire du club de débat et est reconnu pour son esprit d''équipe et sa rigueur.',
          
          photo_url = 'images/pr_Berete.jpg'
      WHERE name = 'Mamady BERETE I'
    ")
    message("Candidat Mamady BERETE I mis à jour.")
  }
  
  # Vérifier les mises à jour
  candidates <- dbGetQuery(con, "SELECT id, name, position_id, photo_url FROM candidates ORDER BY id LIMIT 5")
  print(candidates)
  
  message("Opération terminée avec succès!")
} else {
  message("ERREUR: La base de données n'existe pas!")
}

# Fermer la connexion
dbDisconnect(con) 