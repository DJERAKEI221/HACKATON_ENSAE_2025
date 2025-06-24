---
editor_options: 
  markdown: 
    wrap: 72
---

# Application électorale AES-ENSAE 2025

## Présentation

L'Application Électorale AES-ENSAE 2025 est une plateforme de vote en
ligne innovante, développée dans le cadre du Hackathon ENSAE 2025. Ce
projet, réalisé en équipe, vise à moderniser le processus électoral de
l'Association des Élèves et Stagiaires de l'ENSAE. Cette solution
numérique, construite avec R Shiny, offre une expérience de vote
sécurisée et intuitive pour tous les membres de la communauté ENSAE.

## Objectifs

Notre plateforme vise à :

 - Simplifier le processus électoral pour tous les étudiants et
stagiaires

 - Garantir la transparence et la sécurité des élections

 - Faciliter l'accès aux informations sur les candidats

 - Fournir des résultats en temps réel - Moderniser l'expérience de vote

## Fonctionnalités détaillées

### 1. Système d'Authentification dual sécurisé

-   **Connexion étudiants** : Authentification via numéro étudiant avec
    vérification automatique dans la base
-   **Connexion administrateurs** : Comptes sécurisés (admin1, admin2,
    admin3) avec mot de passe
-   **Vérification croisée** d'éligibilité et validation continue des
    sessions
-   **Protection anti-fraude** avec hachage cryptographique des votes
-   **Gestion des droits** : Interface adaptée selon le type
    d'utilisateur (étudiant/admin)
-   **Session sécurisée** avec timeout automatique et traçabilité
    complète
-   **Détection automatique** du type d'utilisateur pour adaptation de
    l'interface

### 2. Interface de vote intuitive

-   Navigation fluide entre les différentes catégories d'élections
-   Présentation claire des candidats avec photos et programmes
-   Processus de vote simplifié en quelques clics
-   Confirmation visuelle des choix avec récapitulatif
-   Interface responsive adaptée à tous les appareils

### 3. Gestion des Candidats

-   Import automatique depuis fichier CSV (`candidats_bureau.csv`)
-   Nettoyage et validation automatique des données
-   Mapping intelligent des postes avec correction orthographique
-   Profils détaillés avec photos et biographies complètes
-   Programmes électoraux accessibles et structurés
-   Filtrage avancé par poste, catégorie et mot-clé
-   Recherche rapide et intelligente des candidats
-   Gestion des caractères spéciaux et encodage UTF-8/Latin-1

### 4. Système de délégués de classe

-   Élections par classe et promotion avec gestion hiérarchique
-   Distinction entre délégués titulaires et suppléants
-   Interface spécialisée pour chaque type d'élection
-   Gestion des candidatures multiples avec validation
-   Import depuis `delegues.csv` avec validation automatique

### 5. Page d'administration complète

-   **Zone sécurisée** : Accès exclusif aux administrateurs autorisés
    avec vérification stricte
-   **Tableau de bord centralisé** : Vue d'ensemble temps réel du
    système électoral
-   **Export des données** : Téléchargement de tous les votes au format
    CSV pour analyse externe
-   **Réinitialisation système** : Remise à zéro complète avec
    sauvegarde automatique
-   **Système d'annonces** : Diffusion de messages aux électeurs avec
    priorités (normal/important/urgent)
-   **Monitoring avancé** : Suivi en temps réel des votes, participation
    par classe/promotion
-   **Gestion des utilisateurs** : Contrôle des accès et des droits
    utilisateur
-   **Journal des activités** : Traçabilité complète avec horodatage des
    actions critiques
-   **Interface adaptative** : Contenu différencié selon le type
    d'utilisateur (étudiant/admin)

### 6. Résultats et Statistiques

-   Affichage en temps réel avec mise à jour automatique
-   Analyses détaillées par catégorie, poste et promotion
-   Export des données pour archivage

### 8. **Assistant IA - sunuAES Chatbot**

-   **Chatbot électoral intelligent** intégré directement dans
    l'interface
-   **Base de connaissances complète** : candidats, procédures de vote,
    résultats, AES
-   **Interface conversationnelle premium** avec animations fluides et
    design moderne
-   **Réponses contextuelles** automatiques basées sur l'analyse des
    mots-clés
-   **Boutons d'action rapide** pour accès direct aux sections
    principales
-   **Indicateurs visuels** : animation de saisie, statut en ligne,
    notifications
-   **Support multiplateforme** : adaptation automatique mobile/desktop
-   **Assistance 24/7** pour guider les électeurs pendant toute la
    campagne

#### Système d'authentification dual

-   **Double authentification** : Étudiants ET Administrateurs
-   **Comptes administrateurs** sécurisés (admin1, admin2, admin3)
-   **Vérification croisée** avec base étudiants pour les élèves
-   **Sessions sécurisées** avec timeout et hachage cryptographique
-   **Gestion des droits** granulaire par type d'utilisateur
-   **Protection anti-fraude** avec validation continue

#### Système d'annonces et notifications

-   Notifications push en temps réel
-   Système de gamification pour encourager la participation
-   Annonces administratives intégrées

## Structure du projet

```         
Hackaton_ENSAE/
├── ui/                             # Interface utilisateur
│   ├── ui_home.R                   # Page d'accueil responsive
│   ├── ui_candidates.R             # Galerie des candidats
│   ├── ui_vote.R                   # Interface de vote sécurisée
│   ├── ui_auth.R                   # Système d'authentification
│   ├── ui_results.R                # Résultats en temps réel
│   ├── ui_delegates.R              # Gestion des délégués
│   ├── ui_stats.R                  # Tableaux de bord analytics
│   ├── ui_admin.R                  # Interface administrateur
│   └── ui_main.R                   # Interface principale
├── server/                         # Logique serveur
│   ├── server_candidates.R         # API gestion candidats
│   ├── server_vote.R               # Traitement sécurisé des votes
│   ├── server_stats.R              # Moteur de calculs statistiques
│   ├── server_results.R            # Génération des résultats
│   ├── server_delegates.R          # Logique délégués de classe
│   ├── server_main.R               # Serveur principal
│   └── auth_server.R               # Service d'authentification
├── data/                           # Données et base de données
│   ├── candidats_bureau.csv        # Import candidats (format standard)
│   ├── delegues.csv                # Import délégués par classe
│   ├── base_eleves.csv             # Base des étudiants éligibles
│   └── elections.db                # Base SQLite principale
├── Mise à jour/                    # **NOUVEAU** Scripts de maintenance
│   ├── charger_candidats_csv.R     # Import automatique candidats
│   ├── charger_delegues_csv.R      # Import automatique délégués  
│   ├── verifier_base.R             # Diagnostic base de données
│   ├── mise_a_jour_complete.R      # Mise à jour système complète
│   ├── charger_delegues.bat        # Script Windows délégués
│   ├── mise_a_jour.bat             # Script Windows mise à jour
│   └── GUIDE_MISE_A_JOUR_SIMPLE.md # Guide utilisateur simple
├── www/                            # Ressources web statiques
│   ├── css/                        # Styles CSS personnalisés
│   ├── images/                     # Logos et illustrations
│   └── js/                         # Scripts JavaScript
├── modules/                        # Modules réutilisables
│   ├── notification_module.R       # Système de notifications
│   ├── realtime_updates.R          # Mises à jour temps réel
│   ├── gamification_module.R       # Éléments de gamification
│   ├── announcement_system.R       # Système d'annonces
│   ├── push_notification_service.R # Service push notifications
│   └── chatbot_module.R            # Module Chatbot IA
├── sounds/                         # Sons et notifications audio
├── Documentation/                  # Documentation technique
├── global.R                        # Configuration globale avancée
└── app.R                           # Point d'entrée application
```

## Guide d'Installation

### Prérequis système

-   **R** (version 4.3.1 ou supérieure) - [Télécharger
    R](https://cran.r-project.org/)
-   **RStudio** (recommandé pour le développement) - [Télécharger
    RStudio](https://posit.co/products/open-source/rstudio/)
-   **Navigateur web moderne** (Chrome recommandé, Firefox, Edge)
-   **Windows PowerShell** (pour les scripts de maintenance)

### Installation automatique des dépendances

Le projet utilise le gestionnaire `pacman` pour une installation
automatique de toutes les dépendances :

``` r
# L'installation se fait automatiquement au premier lancement
# Les packages suivants sont installés automatiquement :

# Framework et Interface
- shiny          # Framework principal
- bslib          # Bootstrap moderne pour Shiny  
- shinyjs        # Intégration JavaScript
- fontawesome    # Bibliothèque d'icônes

# Base de données
- DBI            # Interface base de données universelle
- RSQLite        # Pilote SQLite optimisé

# Visualisation et Analytics  
- ggplot2        # Graphiques haute qualité
- DT             # Tables interactives avancées

# Traitement de données
- dplyr          # Manipulation efficace des données
- digest         # Hachage cryptographique sécurisé

# Génération de rapports
- rmarkdown      # Documents dynamiques
- knitr          # Moteur de génération
- kableExtra     # Tables professionnelles
- tinytex        # Distribution LaTeX légère
```

### Démarrage rapide

``` r
# 1. Cloner ou télécharger le projet
# 2. Ouvrir RStudio dans le dossier du projet
# 3. Installer automatiquement les dépendances (au premier lancement)
# 4. Lancer l'application
shiny::runApp()
```

## Guide de maintenance

#### 1. Chargement des Candidats

**Procédure étape par étape :**

1\. **Préparer le fichier** `candidats_bureau.csv` selon le format
standard

2\. **Placer le fichier** dans le dossier `data/`

3\. **Exécuter** `Mise à jour/charger_candidats_csv.R`

4\. **Vérification automatique** du format

5\. **Nettoyage des données**

6\. **Import dans la base de données**

**Méthodes d'exécution :**

``` powershell
# Option 1 : Script Windows (recommandé)
cd "Mise à jour"
.\charger_candidats.bat

# Option 2 : Depuis R
source("Mise à jour/charger_candidats_csv.R")
```

**Format requis pour `candidats_bureau.csv` :**

``` csv
identifiant;nom;prenom;poste;categorie
12345;Faye;Jean;Président(e);Bureau
67890;Seck;Lamine;Secrétaire général(e);Bureau
```

**Fonctionnalités automatisées :**

\- Validation automatique du format

\- Nettoyage des caractères spéciaux (Latin-ASCII)

\- Mapping intelligent des noms de postes

 - Détection et correction des erreurs courantes

\- Sauvegarde automatique avant mise à jour

\- Rapport détaillé des opérations - Gestion des doublons et conflits

#### 2. Chargement des Délégués

**Procédure étape par étape :**

1.  **Préparer le fichier** `delegues.csv` selon le format standard

2\. **Placer le fichier** dans le dossier `data/`

3\. **Exécuter** `Mise à jour/charger_delegues_csv.R`

4\. **Validation des données**

5\. **Mise à jour de la base**

**Méthodes d'exécution :**

``` powershell
# Option 1 : Script Windows (recommandé)
.\charger_delegues.bat

# Option 2 : Depuis R  
source("Mise à jour/charger_delegues_csv.R")
```

#### Vérification de la base de données

``` r
# Diagnostic complet du système
source("Mise à jour/verifier_base.R")

# Génère un rapport détaillé avec :
# - État des tables et intégrité référentielle
# - Statistiques de participation
# - Détection d'anomalies
# - Recommandations de maintenance
```

### Sécurité et Sauvegarde

#### Conformité au Règlement Général sur la Protection des Données (RGPD)

-   Collecte minimale des données (ID étudiant, nom, prénom uniquement)
-   Anonymisation complète des votes
-   Droit d'accès et de rectification
-   Conservation limitée des données personnelles

### Tableau de bord temps réel

-   Participation en direct avec graphiques dynamiques
-   Heatmap de participation par classe/promotion
-   Alertes automatiques de seuils de participation

### Système de notifications

-   Notifications push pour encourager la participation
-   Rappels automatiques avant la fermeture des votes
-   Gamification avec badges et récompenses

#### Interface Utilisateur et IA

-   **Design** : Interface moderne avec Bootstrap 5 et animations CSS3
-   **Chatbot IA intégré** : Assistant conversationnel intelligent
    **sunuAES**
-   **Responsive** : Adaptation parfaite mobile/tablette/desktop avec
    chatbot adaptatif
-   **Accessibilité** : Support des lecteurs d'écran, navigation clavier
    et assistance IA
-   **UX Guidée** : Feedback utilisateur immédiat avec assistance IA
    contextuelle
-   **Authentification duale** : Interface adaptée automatiquement
    (étudiant/admin)

#### Sécurité et Administration

-   **Zone d'administration sécurisée** : Accès contrôlé avec
    vérification stricte
-   **Gestion des droits granulaire** : Permissions spécifiques par type
    d'utilisateur
-   **Export et sauvegarde** : Outils d'administration pour maintenance
    système

## Équipe de développement

Ce projet a été développé par :

**Soma Diloma Ben Idriss**

-   Élève Ingénieur Statisticien Économiste (ISE)
-   [somaben791\@gmail.com](mailto:somaben791@gmail.com){.email}
-   (+221) 77 284 02 38
-   [LinkedIn](https://www.linkedin.com/in/ben-soma-82a85a1b1)

**Djerakei Mistalengar**

-   Élève Ingénieur Statisticien Économiste (ISE)
-   [yvesdjerake\@gmail.com](mailto:yvesdjerake@gmail.com){.email}
-   (+221) 70 625 73 36
-   [LinkedIn](https://www.linkedin.com/in/djerake%C3%AF-mistalengar-086b3a21b)

## Calendrier Electoral 2025

### Période de Vote Officielle

-   **Date** : 29 mai 2025
-   **Ouverture** : 07h00 précises
-   **Fermeture** : 23h59 précises
-   **Durée totale** : 17 heures de vote ininterrompu

> **Note importante** : La période de vote est entièrement
> **configurable et ajustable** en modifiant simplement les paramètres
> dans le fichier `global.R`. Les dates et heures mentionnées ci-dessus
> sont des exemples et peuvent être facilement adaptées selon les
> besoins spécifiques de chaque élection.

### Restrictions temporelles

En dehors de la période officielle :

\- Interface de vote inaccessible

\- Tentatives de vote automatiquement bloquées\
- Affichage du compte à rebours en temps réel - Notifications de rappel
automatiques

## Licence 

**© 2024-2025 Association des Élèves et Stagiaires de l'ENSAE
(AES-ENSAE)**

Ce projet est la propriété exclusive de l'AES-ENSAE. Tous droits
réservés.

------------------------------------------------------------------------
