# Application électorale AES-ENSAE 2025

## Sommaire

-   [Présentation](#présentation)
-   [Objectifs](#objectifs)
-   [Fonctionnalités détaillées](#fonctionnalités-détaillées)
-   [Structure du projet](#structure-du-projet)
-   [Guide d'installation](#guide-dinstallation)
-   [Accès à la plateforme et procédure de vote](#accès-à-la-plateforme-et-procédure-de-vote)
-   [Expérience utilisateur après connexion](#expérience-utilisateur-après-connexion)
-   [Guide de maintenance](#guide-de-maintenance)
-   [Sécurité et Sauvegarde](#sécurité-et-sauvegarde)
-   [Calendrier electoral 2025](#calendrier-electoral-2025)
-   [Contribuer](#contribuer)
-   [Contact](#contact)
-   [Équipe de développement](#équipe-de-développement)
-   [Licence](#licence)

## Aide à la navigation dans le README

Pour faciliter la navigation, vous pouvez utiliser des liens internes vers les différentes sections du document. Il suffit de cliquer sur un lien du sommaire ou d'utiliser la syntaxe suivante dans le texte :

-   `[Fonctionnalités détaillées](#fonctionnalités-détaillées)`
-   `[Guide de maintenance](#guide-de-maintenance)`
-   `[Expérience utilisateur après connexion](#expérience-utilisateur-après-connexion)`
-   `[Sécurité et Sauvegarde](#sécurité-et-sauvegarde)`

Le texte entre parenthèses correspond au titre de la section, mis en minuscules, sans accents, et avec les espaces remplacés par des tirets.

## Présentation {#présentation}

L'Application électorale AES-ENSAE 2025 est une plateforme de vote en ligne, développée dans le cadre du Hackathon ENSAE 2025. Ce projet, réalisé en équipe, vise à moderniser le processus électoral de l'Association des Élèves et Stagiaires de l'ENSAE. Cette solution numérique, construite avec R Shiny, offre une expérience de vote sécurisée et intuitive pour tous les membres de la communauté ENSAE.

## Objectifs {#objectifs}

Notre plateforme vise à :

-   Simplifier le processus électoral pour tous les étudiants et stagiaires

-   Garantir la transparence et la sécurité des élections

-   Faciliter l'accès aux informations sur les candidats

-   Fournir des résultats en temps réel

## Fonctionnalités détaillées {#fonctionnalités-détaillées}

### 1. Système d'authentification dual sécurisé

-   **Connexion étudiants** : Authentification via numéro étudiant avec vérification automatique dans la base
-   **Connexion administrateurs** : Comptes sécurisés (admin1, admin2, admin3 par défaut, **mots de passe ajustables** selon les besoins de l'organisation)
-   **Vérification croisée** d'éligibilité et validation continue des sessions
-   **Gestion des droits** : Interface adaptée selon le type d'utilisateur (étudiant/admin)
-   **Session sécurisée** avec timeout automatique et traçabilité complète
-   **Détection automatique** du type d'utilisateur pour adaptation de l'interface

### 2. Interface de vote intuitive

-   Navigation fluide entre les différentes catégories d'élections
-   Présentation des candidats avec photos et programmes
-   Processus de vote simplifié en quelques clics

### 3. Gestion des candidats

-   Import automatique depuis fichier CSV (`candidats_bureau.csv`)
-   Nettoyage et validation automatique des données
-   Mapping intelligent des postes avec correction orthographique
-   Profils détaillés avec photos et biographies complètes
-   Programmes électoraux accessibles
-   Filtrage par poste, catégorie et mot-clé
-   Recherche rapide et intelligente des candidats
-   Gestion des caractères spéciaux et encodage UTF-8/Latin-1

### 4. Système de délégués de classe

-   Élections par classe et promotion avec gestion hiérarchique
-   Distinction entre délégués titulaires et suppléants
-   Interface spécialisée pour chaque type d'élection
-   Gestion des candidatures multiples avec validation
-   Import depuis `delegues.csv` avec validation automatique

### 5. Page d'administration complète

-   **Zone sécurisée** : Accès exclusif aux administrateurs autorisés avec vérification
-   **Tableau de bord centralisé** : Vue d'ensemble temps réel du système électoral
-   **Export des données** : Téléchargement de tous les votes au format CSV pour analyse externe
-   **Réinitialisation système** : Remise à zéro complète avec sauvegarde automatique
-   **Monitoring** : Suivi en temps réel des votes, participation par classe/promotion
-   **Gestion des utilisateurs** : Contrôle des accès et des droits utilisateur
-   **Interface adaptative** : Contenu différencié selon le type d'utilisateur (étudiant/admin)

### 6. Résultats et Statistiques

-   Affichage en temps réel avec mise à jour automatique
-   Analyses par poste et promotion
-   Export des données

### 8. **Assistant IA - sunuAES Chatbot**

-   **Chatbot électoral intelligent** intégré directement dans l'interface
-   **Base de connaissances complète** : candidats, procédures de vote, résultats, AES
-   **Réponses contextuelles** automatiques basées sur l'analyse des mots-clés
-   **Boutons d'action rapide** pour accès direct aux sections principales

## Structure du projet {#structure-du-projet}

```         
Hackaton_ENSAE/
├── ui/                             # Interface utilisateur
│   ├── ui_home.R                   # Page d'accueil
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
│   ├── realtime_updates.R          # Mises à jour temps réel
│   ├── gamification_module.R       # Éléments de gamification
│   └── chatbot_module.R            # Module Chatbot IA
├── sounds/                         # Sons et notifications audio
├── Documentation/                  # Fichiers complémentaires 
├── global.R                        # Configuration globale avancée
└── app.R                           # Point d'entrée application
```

## Guide d'Installation {#guide-dinstallation}

### Prérequis système

-   **R** (version 4.3.1 ou supérieure) - [Télécharger R](https://cran.r-project.org/)
-   **RStudio** (recommandé pour le développement) - [Télécharger RStudio](https://posit.co/products/open-source/rstudio/)
-   **Navigateur web moderne** (Chrome recommandé, Firefox, Edge)
-   **Windows PowerShell** (pour les scripts de maintenance)

### Installation automatique des dépendances

Le projet utilise le gestionnaire `pacman` pour une installation automatique de toutes les dépendances :

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

## Accès à la plateforme et procédure de vote {#accès-à-la-plateforme-et-procédure-de-vote}

### Comment accéder à la plateforme ?

1.  **Accès direct par lien web**
    -   Rendez-vous sur la plateforme à l'adresse suivante : <https://djerakei.shinyapps.io/Hackaton_ENSAE/> *(Ceci est le lien officiel d'accès à la plateforme de vote)*
    -   L'application s'ouvre automatiquement dans votre navigateur.
2.  **Page d'accueil**
    -   Vous arrivez sur la page d'accueil de la plateforme AES-ENSAE.
    -   Naviguez via la barre de menu en haut de l'interface.
3.  **Authentification**
    -   Une interface d'authentification s'affiche automatiquement selon votre profil :
        -   **Étudiants** : Saisissez votre numéro étudiant pour accéder au vote.
        -   **Administrateurs** : Connectez-vous avec votre identifiant et mot de passe administrateur.
    -   Pour plus de détails sur la sécurité et la gestion des accès, voir la section [Fonctionnalités détaillées](#fonctionnalités-détaillées).
    -   Cliquez sur l'onglet **"Votes AES"** ou **"Scrutin des classes"**.

### Expérience utilisateur après connexion {#expérience-utilisateur-après-connexion}

Après authentification, l'interface s'adapte automatiquement selon votre profil :

-   **Étudiant** :
    -   Accès aux sections :
        -   Accueil
        -   Scrutin des classes
        -   Candidats au scrutin AES
        -   Votes AES
        -   Statistiques
        -   Résultats
    -   **Restrictions** :
        -   Pas d'accès à la section Administration
        -   Impossible de modifier les paramètres du système ou d'exporter les données
        -   Accès uniquement à ses propres informations et au processus de vote
-   **Administrateur** :
    -   Accès à toutes les sections, y compris :
        -   Administration (gestion des utilisateurs, annonces, export des votes, réinitialisation du système)
    -   **Attention** : Les actions d'administration sont strictement réservées aux comptes autorisés et nécessitent une authentification renforcée.
    -   **Restriction**: Un administrateur ne peut pas voter

L'interface masque automatiquement les fonctionnalités non autorisées selon le type d'utilisateur connecté.

### Comment voter ?

1.  **Accéder à l'onglet "Votes AES"**
    -   Sélectionnez l'onglet **"Votes AES"** dans la barre de navigation.
2.  **Procédure de vote simplifiée**
    -   **Étape 1 :** Sélectionnez un poste parmi la liste proposée.
    -   **Étape 2 :** Consultez les profils et programmes des candidats.
    -   **Étape 3 :** Cliquez sur le bouton de vote pour confirmer votre choix.
    -   Un message de confirmation s'affiche.
    -   Votre vote est **anonyme** et **sécurisé**.
3.  **Restrictions**
    -   Le vote n'est accessible que pendant la période officielle définie dans le fichier `global.R`.
    -   En dehors de cette période, l'interface de vote est automatiquement bloquée.

**Astuce :** Toutes les étapes sont guidées à l'écran, avec des messages d'aide et des alertes en cas d'erreur ou de tentative hors période.

## Guide de maintenance {#guide-de-maintenance}

#### 1. Chargement des candidats

**Procédure étape par étape :**

-   **Préparer le fichier** `candidats_bureau.csv` selon le format standard

-   **Placer le fichier** dans le dossier `data/`

-   **Exécuter** `Mise à jour/charger_candidats_csv.R`

-   **Vérification automatique** du format

-   **Nettoyage des données**

-   **Import dans la base de données**

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

-   Validation automatique du format

-   Nettoyage des caractères spéciaux (Latin-ASCII)

-   Mapping intelligent des noms de postes

-   Détection et correction des erreurs courantes

-   Sauvegarde automatique avant mise à jour

-   Rapport détaillé des opérations - Gestion des doublons et conflits

#### 2. Chargement des délégués

**Procédure étape par étape :**

-   **Préparer le fichier** `delegues.csv` selon le format standard

-   **Placer le fichier** dans le dossier `data/`

-   **Exécuter** `Mise à jour/charger_delegues_csv.R`

-   **Validation des données**

-   **Mise à jour de la base**

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

### Sécurité et Sauvegarde {#sécurité-et-sauvegarde}

#### Conformité au Règlement Général sur la Protection des Données (RGPD)

-   Collecte minimale des données (ID étudiant, nom, prénom uniquement)
-   Anonymisation complète des votes
-   Droit d'accès et de rectification

### Tableau de bord temps réel

-   Participation en direct avec graphiques dynamiques
-   Taux de participation par classe/promotion

#### Interface Utilisateur et IA

-   **Design** : Interface avec Bootstrap 5 et animations CSS3
-   **Chatbot IA intégré** : Assistant conversationnel intelligent **sunuAES**
-   **Accessibilité** : Support des lecteurs d'écran, navigation clavier et assistance IA
-   **Authentification duale** : Interface adaptée automatiquement (étudiant/admin)

#### Sécurité et Administration

-   **Zone d'administration sécurisée** : Accès contrôlé
-   **Gestion des droits granulaire** : Permissions spécifiques par type d'utilisateur
-   **Export et sauvegarde** : Outils d'administration pour maintenance système

## Calendrier electoral 2025 {#calendrier-electoral-2025}

### Période de vote officielle

-   **Date** : 29 mai 2025
-   **Ouverture** : 07h00 précises
-   **Fermeture** : 23h59 précises
-   **Durée totale** : 17 heures de vote ininterrompu

> **Note importante** : La période de vote est entièrement **configurable et ajustable** en modifiant simplement les paramètres dans le fichier `global.R`. Les dates et heures mentionnées ci-dessus sont des exemples et peuvent être facilement adaptées selon les besoins spécifiques de chaque élection.

### Restrictions temporelles

En dehors de la période officielle :

-   Interface de vote inaccessible

-   Tentatives de vote automatiquement bloquées

## Licence {#licence}

**© 2025 Association des Élèves et Stagiaires de l'ENSAE (AES-ENSAE)**

Ce projet est la propriété exclusive de l'AES-ENSAE. Tous droits réservés.

------------------------------------------------------------------------

## Contribuer {#contribuer}

Vous souhaitez améliorer cette application ou signaler un bug ?

-   Proposez une **pull request** ou ouvrez une **issue** sur le dépôt GitHub du projet (ou contactez directement les responsables ci-dessous).
-   Merci de détailler votre suggestion ou problème pour faciliter la prise en compte.
-   Toute contribution (code, documentation, idées) est la bienvenue !

Pour toute question, suggestion ou demande de support, contactez l'équipe de développement.

------------------------------------------------------------------------

## Équipe de développement {#équipe-de-développement}

Ce projet a été développé par :

**Soma Diloma Ben Idriss**

-   Élève Ingénieur Statisticien Économiste (ISE)
-   [somaben791\@gmail.com](mailto:somaben791@gmail.com)
-   Téléphone : (+221) 77 284 02 38
-   [Profil LinkedIn](https://www.linkedin.com/in/ben-soma-82a85a1b1)

**Djerakei Mistalengar**

-   Élève Ingénieur Statisticien Économiste (ISE)
-   [yvesdjerake\@gmail.com](mailto:yvesdjerake@gmail.com)
-   Téléphone : (+221) 70 625 73 36
-   [Profil LinkedIn](https://www.linkedin.com/in/djerake%C3%AF-mistalengar-086b3a21b)
