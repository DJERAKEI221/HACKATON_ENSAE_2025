#!/usr/bin/env Rscript

# Script pour tester la génération de PDF
# Ce script vérifie si les packages nécessaires pour la génération de PDF
# sont correctement installés et fonctionnent

cat("Test de génération de PDF pour l'application électorale ENSAE\n")
cat("=========================================================\n")

# 1. Vérifier les packages requis
required_packages <- c("rmarkdown", "knitr", "ggplot2", "kableExtra", "tinytex")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("ERREUR: Les packages suivants sont manquants:", paste(missing_packages, collapse = ", "), "\n")
  cat("Veuillez exécuter 'Rscript check_packages.R' pour les installer.\n")
  quit(status = 1)
} else {
  cat("✓ Tous les packages nécessaires sont installés.\n")
}

# 2. Vérifier si TinyTeX est installé
if (!tinytex::is_tinytex()) {
  cat("ERREUR: TinyTeX n'est pas installé. Il est nécessaire pour la génération de PDF.\n")
  cat("Pour l'installer, exécutez dans R: tinytex::install_tinytex()\n")
  quit(status = 1)
} else {
  cat("✓ TinyTeX est correctement installé.\n")
}

# 3. Tester la génération d'un PDF minimal
cat("Tentative de génération d'un PDF de test...\n")

# Créer un fichier Rmd temporaire
temp_rmd <- file.path(tempdir(), "test.Rmd")
temp_pdf <- file.path(tempdir(), "test.pdf")

# Contenu minimal pour le test
writeLines('---
title: "Test PDF pour ENSAE Elections"
output: pdf_document
---

## Test de génération PDF

Si vous pouvez lire ce document, la génération de PDF fonctionne correctement.

```{r, echo=FALSE}
library(ggplot2)
ggplot(mtcars, aes(x = wt, y = mpg)) + 
  geom_point() +
  labs(title = "Graphique de test")
```
', temp_rmd)

# Essayer de générer le PDF
tryCatch({
  rmarkdown::render(temp_rmd, output_file = temp_pdf, quiet = TRUE)
  if (file.exists(temp_pdf)) {
    cat("✓ PDF généré avec succès à", temp_pdf, "\n")
    cat("  Ouvrez ce fichier pour vérifier qu'il s'affiche correctement.\n")
  } else {
    cat("ERREUR: Le fichier PDF n'a pas été créé.\n")
    quit(status = 1)
  }
}, error = function(e) {
  cat("ERREUR lors de la génération du PDF:", e$message, "\n")
  quit(status = 1)
})

cat("\nTest terminé avec succès! Les boutons de téléchargement de l'application devraient maintenant fonctionner.\n")
cat("Si les problèmes persistent, vérifiez les permissions d'écriture dans les dossiers temporaires.\n") 