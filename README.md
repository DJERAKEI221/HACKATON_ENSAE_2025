# Application Électorale AES-ENSAE 2025

## Présentation

L'Application Électorale AES-ENSAE 2025 est une plateforme de vote en ligne innovante, développée dans le cadre du Hackathon ENSAE 2024. Ce projet, réalisé en équipe, vise à moderniser le processus électoral de l'Association des Élèves et Stagiaires de l'ENSAE. Cette solution numérique, construite avec R Shiny, offre une expérience de vote sécurisée et intuitive pour tous les membres de la communauté ENSAE.

## Objectifs

Notre plateforme vise à :
- Simplifier le processus électoral pour tous les étudiants et stagiaires
- Garantir la transparence et la sécurité des élections
- Faciliter l'accès aux informations sur les candidats
- Fournir des résultats en temps réel
- Moderniser l'expérience de vote

## Fonctionnalités détaillées

### 1. Système d'Authentification
- Connexion sécurisée avec numéro étudiant
- Vérification automatique de l'éligibilité
- Protection contre les votes multiples
- Traçabilité complète des actions

### 2. Interface de Vote
- Navigation intuitive entre les différentes élections
- Présentation claire des candidats et de leurs programmes
- Processus de vote en quelques clics
- Confirmation visuelle des choix
- Possibilité de modifier son vote avant validation

### 3. Gestion des Candidats
- Profils détaillés avec photos et biographies
- Programmes électoraux accessibles
- Filtrage par poste et catégorie
- Recherche rapide des candidats

### 4. Système de Délégués
- Élections par classe et promotion
- Distinction entre délégués titulaires et suppléants
- Interface adaptée à chaque type d'élection
- Gestion des candidatures multiples

### 5. Tableau de Bord Administrateur
- Suivi en temps réel des votes
- Statistiques de participation
- Gestion des utilisateurs
- Export des résultats
- Journal des activités

### 6. Résultats et Statistiques
- Affichage en temps réel des résultats
- Graphiques interactifs
- Analyses par catégorie et poste
- Export des données pour archivage

## Structure du projet

```
Hackaton_ENSAE/
├── ui/                          # Interface utilisateur
│   ├── ui_home.R               # Page d'accueil
│   ├── ui_candidates.R         # Page des candidats
│   ├── ui_vote.R              # Interface de vote
│   ├── ui_auth.R              # Authentification
│   ├── ui_results.R           # Résultats des élections
│   ├── ui_delegates.R         # Délégués de classe
│   ├── ui_stats.R             # Graphiques et statistiques
│   └── ui_main.R              # Interface principale
├── server/                     # Logique serveur
│   ├── server_candidates.R     # Gestion des candidats
│   ├── server_vote.R          # Traitement des votes
│   ├── server_stats.R         # Calculs statistiques
│   ├── server_results.R       # Traitement des résultats
│   ├── server_delegates.R     # Gestion des délégués
│   ├── server_main.R          # Serveur principal
│   └── auth_server.R          # Authentification serveur
├── data/                      # Données
│   ├── candidats_bureau.csv   # Liste des candidats
│   ├── delegues.csv          # Liste des délégués
│   └── elections.db          # Base de données SQLite
├── Mise à jour/              # Scripts de maintenance
│   ├── charger_candidats_csv.R    # Chargement des candidats
│   ├── charger_delegues_csv.R     # Chargement des délégués
│   ├── verifier_base.R            # Vérification de la base
│   ├── mise_a_jour_complete.R     # Mise à jour complète
│   ├── charger_delegues.bat       # Script batch délégués
│   ├── mise_a_jour.bat           # Script batch mise à jour
│   └── GUIDE_MISE_A_JOUR_SIMPLE.md # Guide de mise à jour
├── www/                      # Ressources web
│   ├── css/                  # Styles CSS
│   ├── images/              # Images et logos
│   └── js/                  # Scripts JavaScript
├── modules/                  # Modules réutilisables
├── sounds/                   # Sons et notifications
├── Documentation/            # Documentation
├── global.R                 # Configuration globale
└── app.R                    # Point d'entrée de l'application
```

## Guide d'Installation

### Prérequis Système
- R (version 4.3.1 ou supérieure)
- RStudio (recommandé pour le développement)
- Navigateur web moderne (Chrome, Firefox, Edge)

### Installation des Dépendances
```r
# Installation des packages R nécessaires
install.packages(c(
  "shiny",      # Framework d'application web
  "DBI",        # Interface base de données
  "RSQLite",    # Support SQLite
  "DT",         # Tableaux interactifs
  "shinydashboard", # Interface administrateur
  "ggplot2",    # Visualisation de données
  "dplyr"       # Manipulation de données
))
```

### Démarrage de l'Application
```r
# Lancer l'application
shiny::runApp()
```

## Guide de Maintenance

### Mise à Jour des Données

#### 1. Chargement des Candidats
1. Préparer le fichier `candidats_bureau.csv` selon le format standard
2. Placer le fichier dans le dossier `data/`
3. Exécuter `Mise à jour/charger_candidats_csv.R`
   - Vérification automatique du format
   - Nettoyage des données
   - Import dans la base de données

#### 2. Chargement des Délégués
1. Préparer le fichier `delegues.csv` selon le format standard
2. Placer le fichier dans le dossier `data/`
3. Exécuter `Mise à jour/charger_delegues_csv.R`
   - Validation des données
   - Mise à jour de la base

#### 3. Mise à Jour Complète
Pour une mise à jour complète du système :
1. Exécuter `Mise à jour/mise_a_jour.bat`
2. Suivre les instructions à l'écran
3. Vérifier les logs de mise à jour

### Vérification du Système

#### 1. Contrôle de la Base de Données
- Exécuter `Mise à jour/verifier_base.R`
- Vérifier les rapports générés
- Corriger les anomalies si nécessaire

#### 2. Tests de Sécurité
- Vérifier les logs d'authentification
- Tester les mécanismes anti-fraude
- Valider les sauvegardes

## Sécurité et Confidentialité

### Mesures de Protection
- Authentification à deux facteurs pour les administrateurs
- Chiffrement des données sensibles
- Journalisation des actions critiques
- Sauvegardes automatiques

### Conformité
- Protection des données personnelles des étudiants
- Collecte minimale des données nécessaires (numéro étudiant, nom, prénom)
- Conservation limitée des données de vote
- Droit d'accès et de rectification des données personnelles
- Anonymisation des votes
- Archivage sécurisé des résultats

## Support et Maintenance

### Documentation
- Guide d'utilisation détaillé
- Documentation technique
- Procédures de maintenance
- FAQ et dépannage

### Support Technique
Pour toute assistance :
1. Consulter le `GUIDE_MISE_A_JOUR_SIMPLE.md`
2. Contacter l'équipe technique de l'AES-ENSAE par email
3. Se rendre au bureau de l'AES-ENSAE aux heures de permanence

## Auteurs

Ce projet a été développé par :

- **Soma Diloma Ben Idriss**
  - Élève Ingénieur Statisticien Économiste (ISE)
  - 📧 somaben791@gmail.com
  - 📱 (+221) 77 284 02 38

- **Djerakei Mistalengar**
  - Élève Ingénieur Statisticien Économiste (ISE)
  - 📧 yvesdjerake@gmail.com
  - 📱 (+221) 70 625 73 36
  - 🔗 [LinkedIn](https://www.linkedin.com/in/djerake%C3%AF-mistalengar-086b3a21b)

## Licence et Propriété

Ce projet est la propriété exclusive de l'AES-ENSAE.