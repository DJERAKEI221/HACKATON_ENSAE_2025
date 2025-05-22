# Initialisation des modules serveur - Assure que les variables globales sont disponibles

# Si 'positions' n'est pas disponible dans les modules, le recréer ici
if (!exists("positions")) {
  positions <- dbGetQuery(con, "SELECT * FROM positions ORDER BY name")
} 