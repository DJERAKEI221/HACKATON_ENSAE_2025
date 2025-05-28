/**
 * Gestion JavaScript pour la page Participation
 */
$(document).ready(function() {
  // Gérer les messages de mise à jour de la progression XP
  Shiny.addCustomMessageHandler("update-xp-progress", function(message) {
    // Mettre à jour la barre de progression XP
    $("#xp_progress_bar").css("width", message.percent + "%");
  });
  
  // Fonction de journalisation pour détecter les badges
  function checkBadges() {
    console.log("Recherche de badges...");
    var badgeCount = $(".badge-card").length;
    console.log("Nombre de badges trouvés: " + badgeCount);
    
    // Animer les badges si présents
    if (badgeCount > 0) {
      $(".badge-card").each(function(index) {
        $(this).css({
          'opacity': 0,
          'transform': 'translateY(20px)'
        }).delay(100 * index).animate({
          'opacity': 1,
          'transform': 'translateY(0)'
        }, 500);
      });
      
      console.log("Animation des badges appliquée");
    } else {
      // Réessayer après un court délai si aucun badge n'est encore présent
      setTimeout(checkBadges, 1000);
    }
  }
  
  // Observer les changements dans le conteneur de badges
  const badgesObserver = new MutationObserver(function(mutations) {
    checkBadges();
  });
  
  // Observer le conteneur de badges pour détecter quand les badges sont ajoutés
  setTimeout(function() {
    const badgesGrid = document.querySelector('.badges-grid');
    if (badgesGrid) {
      badgesObserver.observe(badgesGrid, { childList: true, subtree: true });
      checkBadges(); // Vérifier immédiatement
    }
  }, 500);
  
  // Animer l'entrée des statistiques
  $(".stat-card").each(function(index) {
    $(this).css({
      'opacity': 0,
      'transform': 'translateX(-20px)'
    }).delay(150 * index).animate({
      'opacity': 1,
      'transform': 'translateX(0)'
    }, 500);
  });
  
  // Animer l'entrée du cercle de niveau
  $(".level-circle").css({
    'opacity': 0,
    'transform': 'scale(0.5)'
  }).delay(300).animate({
    'opacity': 1,
    'transform': 'scale(1)'
  }, 800, function() {
    // Animation de pulsation après l'entrée
    $(this).addClass('pulse-animation');
  });
  
  // S'assurer que les colonnes occupent correctement l'espace
  function adjustColumns() {
    // Largeur de fenêtre actuelle
    var windowWidth = $(window).width();
    
    if (windowWidth >= 992) { // Écrans larges (desktop)
      // S'assurer que les colonnes ont la même hauteur
      var badgesHeight = $(".badges-column").outerHeight();
      var statsHeight = $(".stats-column").outerHeight();
      
      if (badgesHeight > statsHeight) {
        $(".stats-column").css("min-height", badgesHeight + "px");
      } else {
        $(".badges-column").css("min-height", statsHeight + "px");
      }
      
      // S'assurer que l'espace est bien utilisé
      $(".gamification-container").css({
        "width": "100%",
        "max-width": "1200px",
        "margin": "0 auto"
      });
    } else { // Mobile/tablette
      // Réinitialiser les hauteurs sur mobile
      $(".badges-column, .stats-column").css("min-height", "auto");
    }
  }
  
  // Exécuter l'ajustement au chargement et au redimensionnement
  adjustColumns();
  $(window).resize(adjustColumns);
}); 