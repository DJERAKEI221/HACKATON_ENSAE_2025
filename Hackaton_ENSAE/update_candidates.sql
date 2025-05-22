-- Script pour mettre à jour les candidats Ben et Berete

-- Vérifier si les candidats existent déjà
-- Si oui, mettre à jour, sinon insérer

-- Candidat 1: Idriss SOMA BEN
INSERT OR REPLACE INTO candidates 
(id, name, position_id, program, bio, photo_url)
VALUES 
(1, 'Idriss SOMA BEN', 1, 
'Mon programme s''articule autour de 3 axes majeurs:
1. Moderniser les infrastructures de l''école
2. Organiser plus d''activités culturelles et sportives
3. Renforcer les liens avec les entreprises pour faciliter l''insertion professionnelle

Je m''engage à être à l''écoute de tous les étudiants et à représenter leurs intérêts.',

'Étudiant en 3ème année à l''ENSAE, Idriss SOMA BEN est connu pour son leadership et son implication dans les activités associatives. Il a organisé plusieurs événements majeurs dont la Journée Portes Ouvertes 2023.',

'images/pr_BEN.jpg'
);

-- Candidat 2: Mamady BERETE I
INSERT OR REPLACE INTO candidates 
(id, name, position_id, program, bio, photo_url)
VALUES 
(2, 'Mamady BERETE I', 1, 
'Je souhaite dynamiser la vie étudiante avec:
- Des week-ends d''intégration plus inclusifs
- Un calendrier d''événements diversifiés
- Des partenariats avec d''autres écoles pour élargir notre réseau

Mon objectif est d''améliorer votre qualité de vie pendant vos études.',

'Étudiant en 2ème année, Mamady BERETE I est très impliqué dans la vie associative de l''école. Il a déjà été secrétaire du club de débat et est reconnu pour son esprit d''équipe et sa rigueur.',

'images/pr_Berete.jpg'
);

-- Vérifier la mise à jour
SELECT id, name, position_id, photo_url FROM candidates ORDER BY id LIMIT 5; 