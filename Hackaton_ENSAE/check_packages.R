#!/usr/bin/env Rscript

# Script pour vérifier et installer les packages nécessaires
# Ceci est particulièrement utile pour les fonctionnalités de génération de PDF

# Liste des packages requis pour l'application
required_packages <- c(
  "shiny", "bslib", "DBI", "RSQLite", "shinyjs", "ggplot2", "DT", 
  "digest", "fontawesome", "rmarkdown", "knitr", "kableExtra", "tinytex"
)

# Fonction pour vérifier et installer les packages manquants
check_and_install <- function(packages) {
  cat("Vérification des packages nécessaires...\n")
  
  # Vérifier quels packages sont déjà installés
  installed_packages <- packages %in% rownames(installed.packages())
  
  # Installer les packages manquants
  if (any(!installed_packages)) {
    missing_packages <- packages[!installed_packages]
    cat("Installation des packages manquants:", paste(missing_packages, collapse = ", "), "\n")
    
    for (pkg in missing_packages) {
      cat("Installation de", pkg, "... ")
      tryCatch({
        install.packages(pkg, dependencies = TRUE, repos = "https://cloud.r-project.org")
        cat("terminé\n")
      }, error = function(e) {
        cat("ERREUR: ", e$message, "\n")
      })
    }
  } else {
    cat("Tous les packages requis sont déjà installés.\n")
  }
  
  # Vérifier que TinyTeX est installé pour la génération de PDF
  if ("tinytex" %in% packages) {
    if (!tinytex::is_tinytex()) {
      cat("Installation de TinyTeX pour la génération de PDF...\n")
      tinytex::install_tinytex()
      cat("TinyTeX installé avec succès.\n")
    } else {
      cat("TinyTeX est déjà installé.\n")
    }
  }
}

# Exécuter la vérification
check_and_install(required_packages)

cat("Vérification des packages terminée. L'application devrait maintenant pouvoir générer des PDF correctement.\n") 