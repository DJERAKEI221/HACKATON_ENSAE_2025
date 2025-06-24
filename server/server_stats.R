# server/server_stats.R - Gestion des statistiques

# Vérifier si la colonne classe existe dans la table voters
has_year_column <- reactive({
  # Récupérer la structure de la table voters
  table_info <- tryCatch({
    dbGetQuery(values$con, "PRAGMA table_info(voters)")
  }, error = function(e) {
    return(data.frame())
  })
  
  # Vérifier si la colonne classe existe
  if(nrow(table_info) > 0) {
    return("classe" %in% table_info$name)
  }
  return(FALSE)
})

# Vérifier s'il y a des votes enregistrés
has_votes <- reactive({
  votes_count <- dbGetQuery(values$con, "SELECT COUNT(*) as count FROM votes")$count
  return(votes_count > 0)
})

# Rendre les graphiques réactifs aux changements de variables
observe({
  # Garantir que le connection pool est disponible
  req(values$con)
})

# Compteurs pour la participation globale
output$voted_rate <- renderText({
  # Récupérer le nombre total d'inscrits
  voters_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM voters")$total
  # Récupérer le nombre de personnes ayant voté
  voted_total <- dbGetQuery(values$con, "SELECT COUNT(DISTINCT voter_id) as total FROM votes")$total
  
  if(is.na(voters_total) || voters_total == 0) return("0%")
  if(is.na(voted_total)) voted_total <- 0
  
  rate <- round((voted_total / voters_total) * 100, 1)
  return(paste0(rate, "%"))
})

output$not_voted_rate <- renderText({
  # Récupérer le nombre total d'inscrits
  voters_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM voters")$total
  # Récupérer le nombre de personnes ayant voté
  voted_total <- dbGetQuery(values$con, "SELECT COUNT(DISTINCT voter_id) as total FROM votes")$total
  
  if(is.na(voters_total) || voters_total == 0) return("0%")
  if(is.na(voted_total)) voted_total <- 0
  
  rate <- round(((voters_total - voted_total) / voters_total) * 100, 1)
  return(paste0(rate, "%"))
})

# Compteur de votes enregistrés
output$total_votes <- renderText({
  # Récupérer le nombre total de votes
  total_votes <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM votes")$total
  if(is.na(total_votes)) total_votes <- 0
  return(total_votes)
})

# Compteur de postes disputés
output$contested_positions <- renderText({
  # Récupérer le nombre de postes pour lesquels il y a eu des votes
  contested_positions <- dbGetQuery(values$con, "
    SELECT COUNT(DISTINCT position_id) as total 
    FROM votes 
    WHERE position_id IS NOT NULL
  ")$total
  if(is.na(contested_positions)) contested_positions <- 0
  return(contested_positions)
})

# Taux de participation par classe
output$class_voted_rate <- renderText({
  # Vérifier si des votes existent
  voted_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM votes")$total
  
  if(voted_total == 0) return("0%")
  
  # Correspondance entre input$class_filter et la valeur en base
  class_map <- list(
    as1 = "AS1",
    as2 = "AS2",
    as3 = "AS3",
    isep1 = "ISEP1",
    isep2 = "ISEP2",
    isep3 = "ISEP3",
    ise1_maths = "ISE1 Maths",
    ise1_eco = "ISE1 Eco",
    ise2 = "ISE2",
    ise3 = "ISE3",
    master_stats_agricoles = "Master stats agricoles",
    master_adep = "Master ADEP"
  )
  
  # Récupérer les données pour la classe sélectionnée
  if (!is.null(input$class_filter)) {
    class_value <- class_map[[tolower(input$class_filter)]]
    
    # Requête corrigée pour calculer correctement la participation
    # Compter le total d'électeurs de la classe
    total_voters_query <- "SELECT COUNT(*) as total FROM voters WHERE classe = ?"
    total_voters <- dbGetQuery(values$con, total_voters_query, params = list(class_value))$total
    
    # Compter les électeurs uniques qui ont voté dans cette classe
    voted_count_query <- "
      SELECT COUNT(DISTINCT vt.voter_id) as voted
      FROM votes vt
      INNER JOIN voters v ON vt.voter_id = v.id
      WHERE v.classe = ?
    "
    voted_count <- dbGetQuery(values$con, voted_count_query, params = list(class_value))$voted
    
    if(total_voters > 0) {
      rate <- round((voted_count * 100.0 / total_voters), 1)
      return(paste0(rate, "%"))
    }
  }
  
  return("0%")
})

output$class_not_voted_rate <- renderText({
  # Vérifier si des votes existent
  voted_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM votes")$total
  
  if(voted_total == 0) return("100%")
  
  # Correspondance entre input$class_filter et la valeur en base
  class_map <- list(
    as1 = "AS1",
    as2 = "AS2",
    as3 = "AS3",
    isep1 = "ISEP1",
    isep2 = "ISEP2",
    isep3 = "ISEP3",
    ise1_maths = "ISE1 Maths",
    ise1_eco = "ISE1 Eco",
    ise2 = "ISE2",
    ise3 = "ISE3",
    master_stats_agricoles = "Master stats agricoles",
    master_adep = "Master ADEP"
  )
  
  # Récupérer les données pour la classe sélectionnée
  if (!is.null(input$class_filter)) {
    class_value <- class_map[[tolower(input$class_filter)]]
    
    # Requête corrigée pour calculer correctement la non-participation
    # Compter le total d'électeurs de la classe
    total_voters_query <- "SELECT COUNT(*) as total FROM voters WHERE classe = ?"
    total_voters <- dbGetQuery(values$con, total_voters_query, params = list(class_value))$total
    
    # Compter les électeurs uniques qui ont voté dans cette classe
    voted_count_query <- "
      SELECT COUNT(DISTINCT vt.voter_id) as voted
      FROM votes vt
      INNER JOIN voters v ON vt.voter_id = v.id
      WHERE v.classe = ?
    "
    voted_count <- dbGetQuery(values$con, voted_count_query, params = list(class_value))$voted
    
    if(total_voters > 0) {
      rate <- round(((total_voters - voted_count) * 100.0 / total_voters), 1)
      return(paste0(rate, "%"))
    }
  }
  
  return("100%")
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
  
  # Récupérer les données de participation par classe
  class_participation <- tryCatch({
    # Correspondance entre input$class_filter et la valeur en base
    class_map <- list(
      as1 = "AS1",
      as2 = "AS2",
      as3 = "AS3",
      isep1 = "ISEP1",
      isep2 = "ISEP2",
      isep3 = "ISEP3",
      ise1_maths = "ISE1 Maths",
      ise1_eco = "ISE1 Eco",
      ise2 = "ISE2",
      ise3 = "ISE3",
      master_stats_agricoles = "Master stats agricoles",
      master_adep = "Master ADEP"
    )
    
    # Requête corrigée pour obtenir les données de participation par classe
    if (!is.null(input$class_filter)) {
      # Si une classe spécifique est sélectionnée
      class_value <- class_map[[tolower(input$class_filter)]]
      
      # Obtenir le total d'électeurs de cette classe
      total_voters_query <- "SELECT classe as year, COUNT(*) as total_voters FROM voters WHERE classe = ? GROUP BY classe"
      total_data <- dbGetQuery(values$con, total_voters_query, params = list(class_value))
      
      # Obtenir le nombre d'électeurs ayant voté dans cette classe
      voted_count_query <- "
        SELECT v.classe as year, COUNT(DISTINCT vt.voter_id) as voted_count
        FROM votes vt
        INNER JOIN voters v ON vt.voter_id = v.id
        WHERE v.classe = ?
        GROUP BY v.classe
      "
      voted_data <- dbGetQuery(values$con, voted_count_query, params = list(class_value))
      
      # Fusionner les données
      if(nrow(total_data) > 0) {
        data <- total_data
        if(nrow(voted_data) > 0) {
          data$voted_count <- voted_data$voted_count[match(data$year, voted_data$year)]
        } else {
          data$voted_count <- 0
        }
        data$voted_count[is.na(data$voted_count)] <- 0
      } else {
        data <- data.frame()
      }
    } else {
      # Toutes les classes
      # Obtenir le total d'électeurs par classe
      total_voters_query <- "SELECT classe as year, COUNT(*) as total_voters FROM voters WHERE classe IS NOT NULL GROUP BY classe ORDER BY classe"
      total_data <- dbGetQuery(values$con, total_voters_query)
      
      # Obtenir le nombre d'électeurs ayant voté par classe
      voted_count_query <- "
        SELECT v.classe as year, COUNT(DISTINCT vt.voter_id) as voted_count
        FROM votes vt
        INNER JOIN voters v ON vt.voter_id = v.id
        WHERE v.classe IS NOT NULL
        GROUP BY v.classe
      "
      voted_data <- dbGetQuery(values$con, voted_count_query)
      
      # Fusionner les données
      if(nrow(total_data) > 0) {
        data <- total_data
        if(nrow(voted_data) > 0) {
          data$voted_count <- voted_data$voted_count[match(data$year, voted_data$year)]
        } else {
          data$voted_count <- 0
        }
        data$voted_count[is.na(data$voted_count)] <- 0
      } else {
        data <- data.frame()
      }
    }
    
    # Calculer le taux de participation
    if(nrow(data) > 0) {
    data$participation_rate <- round((data$voted_count * 100.0 / data$total_voters), 1)
    }
    
    return(data)
  }, error = function(e) {
    message("Erreur lors de la récupération des données de participation par classe: ", e$message)
    return(data.frame())
  })
  
  # Si aucune donnée n'est disponible, afficher un message
  if(nrow(class_participation) == 0) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Aucune donnée disponible pour la classe sélectionnée.\nVeuillez sélectionner une autre classe.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Si personne n'a voté dans la classe sélectionnée
  if(all(class_participation$voted_count == 0)) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                label = "Aucun vote n'a encore été enregistré pour cette classe.\nLes statistiques seront disponibles après les premiers votes.", 
                size = 6, hjust = 0.5) +
        theme_void()
    )
  }
  
  # Créer le graphique
  p <- ggplot(class_participation, aes(x = year, y = participation_rate, fill = year)) +
    geom_col(width = 0.7) +
    geom_text(aes(label = paste0(participation_rate, "%")), 
              position = position_stack(vjust = 0.5),
              color = "white",
              fontface = "bold",
              size = 4) +
    scale_fill_manual(values = colorRampPalette(c("#E6F3FF", "#2171B5"))(length(class_participation$year))) +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "bold"),
      plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    labs(
      x = "Classes",
      y = "Taux de participation (%)",
      title = "Participation par classe"
    ) +
    scale_y_continuous(limits = c(0, 100))
  
  return(p)
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
    geom_line(linewidth = 1, color = "#3498db") +
    geom_point(size = 3, color = "#2c3e50") +
    scale_x_continuous(breaks = seq(min(vote_history$hour), max(vote_history$hour))) +
    scale_y_continuous(breaks = function(x) seq(floor(min(x)), ceiling(max(x)), by = 1), labels = scales::number_format(accuracy = 1)) +
    theme_minimal() +
    labs(x = "Heure", y = "Nombre de votes", 
         title = "Activité de vote durant la journée électorale") +
    theme(
      axis.title.x = element_text(size = 16, face = "bold", color = "#1976d2", margin = margin(t = 12)),
      axis.title.y = element_text(size = 16, face = "bold", color = "#1976d2", margin = margin(r = 12)),
      axis.text.x = element_text(size = 13, face = "bold", color = "#333333"),
      axis.text.y = element_text(size = 13, face = "bold", color = "#333333"),
      plot.title = element_text(size = 18, face = "bold", color = "#1976d2", hjust = 0.5)
    )
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
      WITH class_counts AS (
        SELECT 
          classe as class,
          COUNT(*) as enrolled_count
        FROM 
          voters
        WHERE classe IS NOT NULL
        GROUP BY 
          classe
      ),
      position_class_combinations AS (
        SELECT 
          p.id as position_id,
          p.name as position_name,
          v.classe as class
        FROM 
          positions p
        CROSS JOIN 
          (SELECT DISTINCT classe FROM voters WHERE classe IS NOT NULL) v
      ),
      position_votes AS (
        SELECT 
          p.id as position_id,
          p.name as position_name,
          v.classe as class,
          COUNT(DISTINCT vt.voter_id) as voted_count
        FROM 
          positions p
        INNER JOIN
          votes vt ON p.id = vt.position_id
        INNER JOIN
          voters v ON vt.voter_id = v.id
        WHERE v.classe IS NOT NULL
        GROUP BY 
          p.id, p.name, v.classe
      )
      SELECT 
        pcc.position_name as Poste,
        pcc.class as Classe,
        COALESCE(cc.enrolled_count, 0) as Inscrits,
        COALESCE(pv.voted_count, 0) as Votants,
        CASE 
          WHEN cc.enrolled_count > 0 THEN ROUND((COALESCE(pv.voted_count, 0) * 100.0 / cc.enrolled_count))
          ELSE 0
        END as Taux
      FROM 
        position_class_combinations pcc
      LEFT JOIN
        class_counts cc ON pcc.class = cc.class
      LEFT JOIN
        position_votes pv ON pcc.position_id = pv.position_id AND pcc.class = pv.class
      ORDER BY
        pcc.position_name, pcc.class
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
                backgroundPosition = 'center',
                color = styleInterval(c(50), c('#d32f2f', '#333333')))
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

## Élections ENSAE 2025
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
            v.classe as class, 
            COUNT(*) as total_voters,
            SUM(CASE WHEN v.id IN (SELECT DISTINCT voter_id FROM votes) THEN 1 ELSE 0 END) as voted_count,
            ROUND((SUM(CASE WHEN v.id IN (SELECT DISTINCT voter_id FROM votes) THEN 1 ELSE 0 END) * 100.0 / COUNT(*))) as participation_rate
          FROM 
            voters v
          WHERE v.classe IS NOT NULL
          GROUP BY 
            v.classe
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
              v.classe as class, 
              ROUND((SUM(CASE WHEN v.id IN (SELECT DISTINCT voter_id FROM votes) THEN 1 ELSE 0 END) * 100.0 / COUNT(*))) as participation_rate
            FROM 
              voters v
            WHERE v.classe IS NOT NULL
            GROUP BY 
              v.classe
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

## Élections ENSAE 2025
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
  geom_text(aes(label = paste0(round(count/sum(count)*100, 1), \"%\")), 
            position = position_stack(vjust = 0.5), color = \"white\", fontface = \"bold\") +
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

# Handler pour exporter le tableau de participation en CSV
output$download_csv <- downloadHandler(
  filename = function() {
    paste0("statistiques-participation-", Sys.Date(), ".csv")
  },
  content = function(file) {
    # Générer les mêmes données que dans participation_table
    voted_total <- dbGetQuery(values$con, "SELECT COUNT(*) as total FROM votes")$total
    if(voted_total == 0) {
      write.csv(data.frame(Message = "Aucun vote n'a encore été enregistré. Le tableau détaillé sera disponible après les premiers votes."), file, row.names = FALSE, fileEncoding = "UTF-8")
      return()
    }
    if(!has_year_column()) {
      write.csv(data.frame(Message = "Les données détaillées par classe ne sont pas disponibles. La structure de la base de données ne contient pas les informations nécessaires."), file, row.names = FALSE, fileEncoding = "UTF-8")
      return()
    }
    participation_details <- tryCatch({
      dbGetQuery(values$con, "
        WITH class_counts AS (
          SELECT 
            classe as class,
            COUNT(*) as enrolled_count
          FROM 
            voters
          WHERE classe IS NOT NULL
          GROUP BY 
            classe
        ),
        position_class_combinations AS (
          SELECT 
            p.id as position_id,
            p.name as position_name,
            v.classe as class
          FROM 
            positions p
          CROSS JOIN 
            (SELECT DISTINCT classe FROM voters WHERE classe IS NOT NULL) v
        ),
        position_votes AS (
          SELECT 
            p.id as position_id,
            p.name as position_name,
            v.classe as class,
            COUNT(DISTINCT vt.voter_id) as voted_count
          FROM 
            positions p
          INNER JOIN
            votes vt ON p.id = vt.position_id
          INNER JOIN
            voters v ON vt.voter_id = v.id
          WHERE v.classe IS NOT NULL
          GROUP BY 
            p.id, p.name, v.classe
        )
        SELECT 
          pcc.position_name as Poste,
          pcc.class as Classe,
          COALESCE(cc.enrolled_count, 0) as Inscrits,
          COALESCE(pv.voted_count, 0) as Votants,
          CASE 
            WHEN cc.enrolled_count > 0 THEN ROUND((COALESCE(pv.voted_count, 0) * 100.0 / cc.enrolled_count))
            ELSE 0
          END as Taux
        FROM 
          position_class_combinations pcc
        LEFT JOIN
          class_counts cc ON pcc.class = cc.class
        LEFT JOIN
          position_votes pv ON pcc.position_id = pv.position_id AND pcc.class = pv.class
        ORDER BY
          pcc.position_name, pcc.class
      ")
    }, error = function(e) {
      return(data.frame())
    })
    if(nrow(participation_details) == 0) {
      write.csv(data.frame(Message = "Impossible de récupérer les données détaillées de participation. Veuillez vérifier la structure de la base de données."), file, row.names = FALSE, fileEncoding = "UTF-8")
      return()
    }
    write.csv(participation_details, file, row.names = FALSE, fileEncoding = "UTF-8")
  }
)

# Impression des statistiques (ouvre la boîte de dialogue d'impression côté client)
observeEvent(input$print_stats, {
  session$sendCustomMessage("print_stats_section", list())
})

# Tableau de bord électoral
output$election_dashboard <- renderUI({
  # Vérifier s'il y a des votes
  if(!has_votes()) {
    return(div(
      class = "alert alert-info",
      icon("info-circle", class = "me-2"),
      "Aucun vote n'a encore été enregistré. Les statistiques seront disponibles après la clôture des votes."
    ))
  }
  
  # Récupérer le nombre total d'électeurs inscrits
  total_voters <- dbGetQuery(values$con, "SELECT COUNT(*) as count FROM voters")$count
  
  # Récupérer le nombre total de votes
  total_votes <- dbGetQuery(values$con, "SELECT COUNT(DISTINCT voter_id) as count FROM votes")$count
  
  # Calculer le taux de participation global
  global_participation <- round((total_votes / total_voters) * 100, 1)
  
  # Récupérer les statistiques par classe
  class_stats <- dbGetQuery(values$con, "
    SELECT 
      v.classe as class,
      COUNT(DISTINCT v.id) as voters_count,
      (SELECT COUNT(*) FROM voters) as total_voters
    FROM 
      voters v
    LEFT JOIN 
      votes vt ON v.id = vt.voter_id
    WHERE v.classe IS NOT NULL
    GROUP BY 
      v.classe
    ORDER BY 
      v.classe
  ")
  
  # Calculer le taux de participation par classe
  class_stats$participation_rate <- round((class_stats$voters_count / class_stats$total_voters) * 100, 1)
  
  # Récupérer les statistiques par poste
  position_stats <- dbGetQuery(values$con, "
    WITH position_votes AS (
      SELECT 
        p.id as position_id,
        p.name as position_name,
        COUNT(DISTINCT v.voter_id) as voters_count
      FROM 
        positions p
      LEFT JOIN 
        votes v ON p.id = v.position_id
      GROUP BY 
        p.id, p.name
    )
    SELECT 
      position_name,
      voters_count,
      (SELECT COUNT(*) FROM voters) as total_voters
    FROM 
      position_votes
    ORDER BY 
      position_name
  ")
  
  # Calculer le taux de participation par poste
  position_stats$participation_rate <- round((position_stats$voters_count / position_stats$total_voters) * 100, 1)
  
  # Créer le tableau de bord
  div(
    class = "dashboard-container",
    # Statistiques par poste
    div(class = "dashboard-section",
        style = "background-color: #f8f9fa; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);",
        h4(icon("award", class = "me-2 text-primary"), "Participation par poste",
           style = "color: #2c3e50; font-weight: 600; margin-bottom: 25px;"),
        div(class = "table-responsive",
            tags$table(class = "table table-hover",
                      style = "border-collapse: separate; border-spacing: 0 8px;",
                      tags$thead(
                        tags$tr(
                          tags$th("Poste", style = "color: #495057; font-weight: 600; padding: 15px; border-bottom: 2px solid #dee2e6;"),
                          tags$th("Votants", style = "color: #495057; font-weight: 600; padding: 15px; border-bottom: 2px solid #dee2e6;"),
                          tags$th("Inscrits", style = "color: #495057; font-weight: 600; padding: 15px; border-bottom: 2px solid #dee2e6;"),
                          tags$th("Taux de participation", style = "color: #495057; font-weight: 600; padding: 15px; border-bottom: 2px solid #dee2e6;")
                        )
                      ),
                      tags$tbody(
                        lapply(1:nrow(position_stats), function(i) {
                          tags$tr(
                            style = "background-color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.05); transition: all 0.3s ease;",
                            tags$td(position_stats$position_name[i], 
                                   style = "padding: 15px; border-top: 1px solid #dee2e6; border-bottom: 1px solid #dee2e6; font-weight: 500;"),
                            tags$td(position_stats$voters_count[i], 
                                   style = "padding: 15px; border-top: 1px solid #dee2e6; border-bottom: 1px solid #dee2e6;"),
                            tags$td(position_stats$total_voters[i], 
                                   style = "padding: 15px; border-top: 1px solid #dee2e6; border-bottom: 1px solid #dee2e6;"),
                            tags$td(
                              style = "padding: 15px; border-top: 1px solid #dee2e6; border-bottom: 1px solid #dee2e6;",
                              div(class = "d-flex align-items-center",
                                  span(paste0(position_stats$participation_rate[i], "%"), 
                                       style = "font-weight: 600; color: #0d6efd; min-width: 45px;"),
                                  div(class = "progress flex-grow-1 ms-2", 
                                      style = "height: 8px; background-color: #e9ecef; border-radius: 4px;",
                                      div(class = "progress-bar bg-primary", 
                                          role = "progressbar", 
                                          style = sprintf("width: %s%%; border-radius: 4px;", position_stats$participation_rate[i]),
                                          `aria-valuenow` = position_stats$participation_rate[i], 
                                          `aria-valuemin` = "0", 
                                          `aria-valuemax` = "100")
                                  )
                              )
                            )
                          )
                        })
                      )
            )
        )
    ),
    
    # Pied de page avec la date de mise à jour
    div(class = "text-end small mt-4",
        style = "color: #0d6efd; font-weight: 500;",
        icon("clock", class = "me-1"),
        "Statistiques mises à jour le ", format(Sys.time(), "%d/%m/%Y à %H:%M")
    )
  )
}) 