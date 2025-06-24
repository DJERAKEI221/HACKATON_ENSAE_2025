# Guide Simple de Mise à Jour des Données

## Objectif
Mettre à jour rapidement les candidats et délégués pour les élections ENSAE 2025.

## Fichiers à modifier

### 1. Base des étudiants (`../data/base_eleves.csv`)
```csv
Identifiant;Nom;Prenom;Sexe;Classe;
2025001;DIOP;Aminata;Féminin;AS1;
2025002;BA;Ousmane;Masculin;ISE3;
2025003;NDIAYE;Moussa;Masculin;Masters
```

**Colonnes importantes :**
- `Identifiant` : Numéro unique de l'étudiant
- `Nom` : Nom de famille
- `Prenom` : Prénom
- `Sexe` : "Masculin" ou "Féminin"
- `Classe` : Classe (AS1, AS2, AS3, ISEP1, ISEP2, ISEP3, ISE1 Maths, ISE1 Eco, ISE3, Masters)

### 2. Candidats bureau (`../data/candidats_bureau.csv`)
```csv
identifiant;nom;prenom;poste;categorie;biographie;programme
2025001;DIOP;Aminata;Président(e);Bureau exécutif;Biographie...;Programme...
```

**Colonnes dans l'ordre :**
- `identifiant` : Numéro étudiant (doit correspondre à un identifiant dans base_eleves.csv)
- `nom` : Nom de famille
- `prenom` : Prénom
- `poste` : Nom exact du poste (voir liste des postes valides)
- `categorie` : "Bureau exécutif" ou "Départements permanents"
- `biographie` : Biographie du candidat
- `programme` : Programme électoral

### 3. Délégués (`../data/delegues.csv`)
```csv
identifiant;nom;prenom;classe;type
2025002;BA;Ousmane;ISE3;delegue
```

**Colonnes dans l'ordre :**
- `identifiant` : Numéro étudiant (doit correspondre à un identifiant dans base_eleves.csv)
- `nom` : Nom de famille
- `prenom` : Prénom
- `classe` : Classe de l'étudiant
- `type` : Type de délégué ("delegue" ou "adjoint")

**Types de délégués :**
- `delegue` : Délégué principal
- `adjoint` : Délégué adjoint

## Mise à jour rapide

### Méthode recommandée : Fichier batch
```bash
# Double-cliquez sur le fichier :
mise_a_jour.bat
```

### Méthode alternative : R
```r
# Charger les packages nécessaires
if (!require("pacman")) install.packages("pacman")
pacman::p_load(DBI, RSQLite)

# Définir le répertoire de travail sur le dossier racine du projet
setwd("C:/Users/yvesd/Desktop/Hackaton_ENSAE")

# Créer la connexion à la base de données
con <- dbConnect(RSQLite::SQLite(), "data/elections.db")

# Vérifier que la connexion fonctionne
if (dbIsValid(con)) {
  cat("Connexion à la base de données réussie!\n")
  
  # Exécuter les scripts dans l'ordre
  source("Mise à jour/creer_table_voters.R")
  source("Mise à jour/charger_candidats_csv.R")
  source("Mise à jour/charger_delegues_csv.R")
  source("Mise à jour/verifier_base.R")
} else {
  stop("Impossible de se connecter à la base de données")
}

# Fermer la connexion à la fin
dbDisconnect(con)
```

## Classes valides

**Classes actuelles :**
- AS1, AS2, AS3 (Analyste Statisticien)
- ISEP1, ISEP2, ISEP3 (Ingénieur Statisticien Économiste Cycle long)
- ISE1 Maths, ISE1 Eco, ISE3 (Ingénieur Statisticien Économiste Cycle court)
- Masters

## Points importants

1. **Exécution** : Toujours exécuter les scripts depuis le dossier "Mise à jour"
2. **Encodage** : Fichiers CSV en UTF-8 ou Latin1
3. **Séparateur** : Point-virgule (`;`)
4. **Sauvegarde** : Toujours sauvegarder avant modification
5. **Test** : Tester après chaque mise à jour

## Dépannage

### Problème : "Chemin d'accès introuvable"
- **Solution** : Exécutez les scripts depuis le dossier "Mise à jour"
- Utilisez `mise_a_jour.bat` qui gère automatiquement les chemins

### Problème : Candidats non chargés
- Vérifiez le format CSV
- Vérifiez les noms de postes
- Relancez `verifier_base.R`

### Problème : Classes non reconnues
- Utilisez uniquement les classes valides
- Vérifiez l'orthographe exacte
- Pas d'espaces en trop

## Structure des chemins

Les scripts utilisent maintenant les chemins relatifs corrects :
- `../data/` pour accéder aux fichiers de données
- Tous les scripts fonctionnent depuis le dossier "Mise à jour"

---

**Dernière mise à jour** : 28/05/2025  
**Version** : 2.1 - Structure candidats_bureau.csv mise à jour