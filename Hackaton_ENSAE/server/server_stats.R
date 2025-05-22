# server/server_stats.R - Gestion des statistiques

# Vérifier si la colonne year existe dans la table voters
has_year_column <- reactive({
  # Récupérer la structure de la table voters
  table_info <- tryCatch({
    dbGetQuery(values$con, "PRAGMA table_info(voters)")
  }, error = function(e) {
    return(data.frame())
  })
  
  # Vérifier si la colonne year existe
  if(nrow(table_info) > 0) {
    return("year" %in% table_info$name)
  }
  return(FALSE)
})

# Rendre les graphiques réactifs aux changements de variables
observe({
  # Garantir que le connection pool est disponible
  req(values$con)
})

# Graphique de participation globale
output$participation_chart <- renderPlot({
  # Récupérer le nombre total d'inscrits
  voters_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM voters")$total
  
  # Récupérer le nombre de personnes ayant voté
  voted_total <- dbGetQuery(values$con, "SELECT COUNT(DISTINCT voter_id) as total FROM votes")$total
  
  # S'assurer que nous avons des données valides
  if(is.na(voters_total) || voters_total == 0) {
    voters_total <- 1 # Éviter les divisions par zéro
  }
  if(is.na(voted_total)) {
    voted_total <- 0
  }
  
  # Vérifier s'il y a des votes
  if(voted_total == 0) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Aucun vote n'a encore été enregistré.\nLes statistiques seront disponibles dès le début des votes.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Créer le dataframe pour le graphique
  participation_data <- data.frame(
    status = c("A voté", "N'a pas voté"),
    count = c(voted_total, max(0, voters_total - voted_total))
  )
  
  ggplot(participation_data, aes(x = "", y = count, fill = status)) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y", start = 0) +
    scale_fill_manual(values = c("#27ae60", "#e74c3c")) +
    labs(fill = "Statut") +
    theme_void() +
    geom_text(aes(label = paste0(round(count/sum(count)*100), "%")), 
              position = position_stack(vjust = 0.5)) +
    ggtitle("Taux de participation global")
})

# Graphique de participation par classe
output$participation_by_year <- renderPlot({
  # Vérifier si des votes existent
  voted_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM votes")$total
  
  if(voted_total == 0) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Aucun vote n'a encore été enregistré.\nLes statistiques par classe seront disponibles après les premiers votes.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Vérifier si la colonne year existe
  if(!has_year_column()) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Les données par classe ne sont pas disponibles.\nLa structure de la base de données ne contient pas les informations nécessaires.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Récupérer les données de participation par classe
  class_participation <- tryCatch({
    dbGetQuery(values$con, "
      SELECT 
        v.year as class, 
        COUNT(*) as total_voters,
        SUM(CASE WHEN v.id IN (SELECT DISTINCT voter_id FROM votes) THEN 1 ELSE 0 END) as voted_count
      FROM 
        voters v
      GROUP BY 
        v.year
      ORDER BY 
        v.year
    ")
  }, error = function(e) {
    return(data.frame())
  })
  
  # Si aucune donnée n'est disponible, afficher un message
  if(nrow(class_participation) == 0) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Les données de participation par classe ne sont pas disponibles.\nVeuillez vérifier la configuration de la base de données.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Calculer le taux de participation
  class_participation$participation <- round((class_participation$voted_count / 
                                             pmax(class_participation$total_voters, 1)) * 100)
  
  ggplot(class_participation, aes(x = class, y = participation, fill = class)) +
    geom_col() +
    geom_text(aes(label = paste0(participation, "%")), vjust = -0.5) +
    scale_fill_manual(values = colorRampPalette(c("#E6F3FF", "#2171B5"))(length(class_participation$class))) +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1)
    ) +
    labs(x = "Classes", y = "Taux de participation (%)")
})

# Graphique d'activité de vote (timeline)
output$vote_timeline <- renderPlot({
  # Vérifier si des votes existent
  voted_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM votes")$total
  
  if(voted_total == 0) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Aucun vote n'a encore été enregistré.\nLe chronogramme des votes sera disponible après les premiers votes.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Récupérer l'historique des votes par heure
  vote_history <- tryCatch({
    dbGetQuery(values$con, "
      SELECT 
        strftime('%H', timestamp) as hour,
        COUNT(*) as votes
      FROM 
        votes
      GROUP BY 
        strftime('%H', timestamp)
      ORDER BY 
        hour
    ")
  }, error = function(e) {
    return(data.frame())
  })
  
  # Si aucune donnée n'est disponible, afficher un message
  if(nrow(vote_history) == 0) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Impossible de récupérer les données d'activité de vote.\nVeuillez vérifier la structure de la base de données.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Convertir l'heure en numérique pour le graphique
  vote_history$hour <- as.numeric(vote_history$hour)
  
  ggplot(vote_history, aes(x = hour, y = votes)) +
    geom_line(size = 1, color = "#3498db") +
    geom_point(size = 3, color = "#2c3e50") +
    scale_x_continuous(breaks = seq(min(vote_history$hour), max(vote_history$hour))) +
    theme_minimal() +
    labs(x = "Heure", y = "Nombre de votes", 
         title = "Activité de vote durant la journée électorale")
})

# Tableau détaillé de participation
output$participation_table <- renderDT({
  # Vérifier si des votes existent
  voted_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM votes")$total
  
  if(voted_total == 0) {
    return(
      datatable(
        data.frame(
          Message = "Aucun vote n'a encore été enregistré. Le tableau détaillé sera disponible après les premiers votes."
        ),
        options = list(dom = 't'),
        rownames = FALSE
      )
    )
  }
  
  # Vérifier si la colonne year existe
  if(!has_year_column()) {
    return(
      datatable(
        data.frame(
          Message = "Les données détaillées par classe ne sont pas disponibles. La structure de la base de données ne contient pas les informations nécessaires."
        ),
        options = list(dom = 't'),
        rownames = FALSE
      )
    )
  }
  
  # Récupérer les détails de participation par poste et classe
  participation_details <- tryCatch({
    dbGetQuery(values$con, "
      WITH position_votes AS (
        SELECT 
          p.id as position_id,
          p.name as position_name,
          v.year as class,
          COUNT(DISTINCT vt.voter_id) as voted_count
        FROM 
          positions p
        LEFT JOIN
          votes vt ON p.id = vt.position_id
        LEFT JOIN
          voters v ON vt.voter_id = v.id
        GROUP BY 
          p.id, p.name, v.year
      ),
      class_counts AS (
        SELECT 
          year as class,
          COUNT(*) as enrolled_count
        FROM 
          voters
        GROUP BY 
          year
      )
      SELECT 
        pv.position_name as Poste,
        pv.class as Classe,
        COALESCE(cc.enrolled_count, 0) as Inscrits,
        COALESCE(pv.voted_count, 0) as Votants,
        CASE 
          WHEN cc.enrolled_count > 0 THEN ROUND((COALESCE(pv.voted_count, 0) * 100.0 / cc.enrolled_count))
          ELSE 0
        END as Taux
      FROM 
        position_votes pv
      LEFT JOIN
        class_counts cc ON pv.class = cc.class
      ORDER BY
        pv.position_name, pv.class
    ")
  }, error = function(e) {
    return(data.frame())
  })
  
  # Si aucune donnée n'est disponible, créer un tableau vide avec la structure
  if(nrow(participation_details) == 0) {
    return(
      datatable(
        data.frame(
          Message = "Impossible de récupérer les données détaillées de participation. Veuillez vérifier la structure de la base de données."
        ),
        options = list(dom = 't'),
        rownames = FALSE
      )
    )
  }
  
  datatable(participation_details, 
            options = list(pageLength = 10),
            rownames = FALSE) %>%
    formatStyle('Taux',
                background = styleColorBar(c(0, 100), '#27ae60'),
                backgroundSize = '98% 88%',
                backgroundRepeat = 'no-repeat',
                backgroundPosition = 'center')
})

# Téléchargement du rapport statistique
output$downloadStats <- downloadHandler(
  filename = function() {
    paste("rapport-statistique-elections-", Sys.Date(), ".pdf", sep = "")
  },
  content = function(file) {
    # S'assurer que les packages nécessaires sont disponibles
    req(requireNamespace("rmarkdown", quietly = TRUE))
    req(requireNamespace("ggplot2", quietly = TRUE))
    
    # Vérifier si des votes existent
    voted_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM votes")$total
    
    if(voted_total == 0) {
      # Créer un rapport simple indiquant qu'aucun vote n'a été enregistré
      tempReport <- file.path(tempdir(), "statistics.Rmd")
      
      cat(file = tempReport, "---
title: \"Rapport statistique des élections ENSAE\"
output: pdf_document
---

## Élections ENSAE 2024
### Date: ", format(Sys.Date(), "%d/%m/%Y"), "

## Aucun vote enregistré

Aucun vote n'a encore été enregistré dans le système. Le rapport statistique complet sera disponible dès le début des votes.

", sep = "")
      
      # Générer le PDF
      rmarkdown::render(tempReport, output_file = file, quiet = TRUE)
      return()
    }
    
    # Récupérer les données actuelles pour le rapport
    voters_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM voters")$total
    
    participation_percentage <- 0
    if(voters_total > 0) {
      participation_percentage <- round((voted_total / voters_total) * 100, 1)
    }
    
    # Vérifier si la colonne year existe
    has_class_data <- FALSE
    best_class <- "données non disponibles"
    best_rate <- 0
    worst_classes <- "données non disponibles"
    worst_rates <- "0%"
    
    if(has_year_column()) {
      # Obtenir la classe avec la plus haute participation
      best_class_data <- tryCatch({
        dbGetQuery(values$con, "
          SELECT 
            v.year as class, 
            COUNT(*) as total_voters,
            SUM(CASE WHEN v.id IN (SELECT DISTINCT voter_id FROM votes) THEN 1 ELSE 0 END) as voted_count,
            ROUND((SUM(CASE WHEN v.id IN (SELECT DISTINCT voter_id FROM votes) THEN 1 ELSE 0 END) * 100.0 / COUNT(*))) as participation_rate
          FROM 
            voters v
          GROUP BY 
            v.year
          ORDER BY 
            participation_rate DESC
          LIMIT 1
        ")
      }, error = function(e) {
        return(data.frame())
      })
      
      if(nrow(best_class_data) > 0) {
        has_class_data <- TRUE
        best_class <- best_class_data$class[1]
        best_rate <- best_class_data$participation_rate[1]
        
        # Obtenir les classes avec la plus basse participation
        worst_class_data <- tryCatch({
          dbGetQuery(values$con, "
            SELECT 
              v.year as class, 
              ROUND((SUM(CASE WHEN v.id IN (SELECT DISTINCT voter_id FROM votes) THEN 1 ELSE 0 END) * 100.0 / COUNT(*))) as participation_rate
            FROM 
              voters v
            GROUP BY 
              v.year
            ORDER BY 
              participation_rate ASC
            LIMIT 2
          ")
        }, error = function(e) {
          return(data.frame())
        })
        
        if(nrow(worst_class_data) > 0) {
          worst_classes <- paste(worst_class_data$class, collapse = " et ")
          worst_rates <- paste(worst_class_data$participation_rate, collapse = "%-")
          worst_rates <- paste0(worst_rates, "%")
        }
      }
    }
    
    # Créer un fichier temporaire Rmd
    tempReport <- file.path(tempdir(), "statistics.Rmd")
    
    cat(file = tempReport, "---
title: \"Rapport statistique des élections ENSAE\"
output: pdf_document
---

## Élections ENSAE 2024
### Date: ", format(Sys.Date(), "%d/%m/%Y"), "

## Participation générale

```{r, echo=FALSE}
library(ggplot2)
participation_data <- data.frame(
  status = c(\"A voté\", \"N'a pas voté\"),
  count = c(", voted_total, ", ", voters_total - voted_total, ")
)
    
ggplot(participation_data, aes(x = \"\", y = count, fill = status)) +
  geom_bar(stat = \"identity\", width = 1) +
  coord_polar(\"y\", start = 0) +
  scale_fill_manual(values = c(\"#27ae60\", \"#e74c3c\")) +
  labs(fill = \"Statut\") +
  theme_void() +
  geom_text(aes(label = paste0(round(count/sum(count)*100), \"%\")), 
            position = position_stack(vjust = 0.5)) +
  ggtitle(\"Taux de participation global\")
```

## Analyses et recommandations

- Le taux de participation global s'élève à **", participation_percentage, "%**
", if(has_class_data) {
  paste("- Les étudiants de ", best_class, " ont été les plus mobilisés avec **", best_rate, "%**
- Recommandation : sensibiliser davantage les ", worst_classes, " (taux de participation le plus faible à ", worst_rates, ")")
} else {
  "- Les données de participation par classe ne sont pas disponibles dans la structure actuelle de la base de données."
}, "

", sep = "")
    
    # Essayer de générer le PDF avec gestion des erreurs
    tryCatch({
      # Knit le document en PDF
      rmarkdown::render(tempReport, output_file = file, quiet = TRUE)
    }, error = function(e) {
      # Afficher une erreur dans la console pour le débogage
      message("Erreur lors de la génération du PDF: ", e$message)
      # Créer un fichier texte d'urgence avec les informations
      writeLines(sprintf("Erreur de génération du PDF: %s\nVeuillez vérifier que tous les packages nécessaires sont installés.", e$message), file)
    })
  }
) 