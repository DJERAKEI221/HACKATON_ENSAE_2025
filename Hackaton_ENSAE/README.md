# Application des élections ENSAE

Cette application Shiny permet de gérer le processus électoral des membres du bureau de l'Association des Étudiants Statisticiens (AES) de l'ENSAE.

## Installation et configuration

1. Assurez-vous d'avoir R installé sur votre système
2. Exécutez le script `check_packages.R` pour installer les dépendances nécessaires:
```r
Rscript check_packages.R
```

## Résolution des problèmes courants

### Boutons de téléchargement inactifs

Si les boutons de téléchargement des rapports et procès-verbaux ne fonctionnent pas:

1. Assurez-vous que tous les packages requis sont installés:
   ```r
   Rscript check_packages.R
   ```

2. Vérifiez que TinyTeX est correctement installé pour la génération de PDF:
   ```r
   if (!requireNamespace("tinytex", quietly = TRUE)) {
     install.packages("tinytex")
   }
   tinytex::install_tinytex()
   ```

3. Exécutez le script de test pour vérifier si la génération de PDF fonctionne correctement:
   ```r
   Rscript test_pdf_generation.R
   ```

4. Si les problèmes persistent, vérifiez la connexion à la base de données:
   ```r
   Rscript db_connection_fix.R
   ```

### Base de données corrompue ou manquante

Si l'application ne se charge pas correctement ou affiche des erreurs liées à la base de données:

1. Recréez la base de données:
   ```r
   Rscript recreate_database.R
   ```

## Démarrage de l'application

Pour lancer l'application:

```r
shiny::runApp()
```

## Fonctionnalités principales

- Authentification des électeurs
- Présentation des candidats et de leurs programmes
- Interface de vote intuitive
- Statistiques de participation en temps réel
- Génération de procès-verbaux et rapports électoraux
