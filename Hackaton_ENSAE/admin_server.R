observeEvent(input$create_election, {
  election_id <- dbExecute(con, "
    INSERT INTO elections (name, type, start_date, end_date)
    VALUES (?, ?, ?, ?)
  ", list(input$election_name, input$election_type,
          input$election_dates[1], input$election_dates[2]))
  
  # Assigner automatiquement les postes par défaut
  default_positions <- dbGetQuery(con, "SELECT id FROM positions")
  lapply(default_positions$id, function(pos_id) {
    dbExecute(con, "
      INSERT INTO election_positions (election_id, position_id)
      VALUES (?, ?)
    ", list(election_id, pos_id))
  })
}) 