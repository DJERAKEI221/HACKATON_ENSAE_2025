Base de données créée avec succès ! 

// Initialisation des graphiques
function initResultsChart(data) {
  const ctx = document.getElementById('resultsChart').getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.labels,
      datasets: [{
        label: 'Votes',
        data: data.values,
        backgroundColor: 'rgba(44, 62, 80, 0.7)'
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: false },
        tooltip: { mode: 'index' }
      }
    }
  });
} 

// Initialisation
document.addEventListener('DOMContentLoaded', function() {
  // Gestion des tooltips
  tippy('[data-tippy-content]', {
    arrow: true,
    animation: 'scale'
  });

  // Gestion des soumissions de formulaire
  document.querySelectorAll('.shiny-form').forEach(form => {
    form.addEventListener('submit', function(e) {
      e.preventDefault();
      this.classList.add('loading');
      // Simuler une requête Shiny
      setTimeout(() => this.classList.remove('loading'), 2000);
    });
  });
});

// Fonction pour les notifications
function showNotification(message, type = 'success') {
  const notification = document.createElement('div');
  notification.className = `notification notification-${type} fade-in`;
  notification.textContent = message;
  
  document.body.appendChild(notification);
  setTimeout(() => notification.remove(), 3000);
} 

# Créer les dossiers nécessaires
dir.create("www/css", recursive = TRUE, showWarnings = FALSE)
dir.create("www/js", recursive = TRUE, showWarnings = FALSE)
dir.create("data", showWarnings = FALSE)

# Connexion à la base de données
con <- DBI::dbConnect(RSQLite::SQLite(), "data/elections.db")
DBI::dbExecute(con, "PRAGMA foreign_keys = ON")

# Table des postes électoraux
DBI::dbExecute(con, "
CREATE TABLE IF NOT EXISTS positions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  max_votes INTEGER DEFAULT 1
)")

# Table des candidats modifiée
DBI::dbExecute(con, "
CREATE TABLE IF NOT EXISTS candidates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  position_id INTEGER NOT NULL,
  program TEXT,
  bio TEXT,
  photo_url TEXT,
  FOREIGN KEY(position_id) REFERENCES positions(id),
  UNIQUE(name, position_id)
)")

# Table des votes adaptée
DBI::dbExecute(con, "
CREATE TABLE IF NOT EXISTS votes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  voter_id INTEGER NOT NULL,
  candidate_id INTEGER NOT NULL,
  position_id INTEGER NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(voter_id) REFERENCES voters(id),
  FOREIGN KEY(candidate_id) REFERENCES candidates(id),
  FOREIGN KEY(position_id) REFERENCES positions(id),
  UNIQUE(voter_id, position_id)
)")

# Insertion des postes électoraux
positions <- data.frame(
  name = c(
    "Président de l'Amicale",
    "Président de la Junior Entreprise",
    "Secrétaire Général",
    "Secrétaire chargé à l'Organisation",
    "Conseiller à la Junior Entreprise",
    "Président du Club Leadership",
    "Président du Club Anglais",
    "Président du Club Informatique",
    "Chargé de la Communication"
  ),
  description = c(
    "Représente les étudiants et coordonne les activités de l'amicale",
    "Dirige les projets et activités de la Junior Entreprise",
    "Gestion administrative et procès-verbaux des réunions",
    "Coordination logistique des événements",
    "Apporte expertise et conseil aux projets de la JE",
    "Animation du club de développement personnel et leadership",
    "Coordination des activités d'apprentissage de l'anglais",
    "Organisation des projets et ateliers informatiques",
    "Gestion de la communication interne et externe"
  ),
  max_votes = rep(1, 9)
)

# Insérer les postes
for (i in 1:nrow(positions)) {
  DBI::dbExecute(con, 
    "INSERT OR IGNORE INTO positions (name, description, max_votes) VALUES (?, ?, ?)",
    params = list(positions$name[i], positions$description[i], positions$max_votes[i])
  )
}

# Vérification
if (all(c("positions", "candidates", "votes") %in% DBI::dbListTables(con))) {
  message("Base de données mise à jour avec succès !")
  
  # Vérification des postes
  pos_count <- DBI::dbGetQuery(con, "SELECT COUNT(*) FROM positions")[[1]]
  message(sprintf("Nombre de postes électoraux: %d", pos_count))
}

DBI::dbDisconnect(con) 