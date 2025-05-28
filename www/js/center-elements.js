/**
 * Script pour améliorer le centrage des éléments de la page
 */
$(document).ready(function() {
  // Appliquer une fonction de centrage immédiatement
  applyCorrections();
  
  // Réappliquer lors du redimensionnement
  $(window).resize(function() {
    applyCorrections();
  });
  
  // Réappliquer après un léger délai (pour s'assurer que tout le DOM est chargé)
  setTimeout(function() {
    applyCorrections();
  }, 500);
  
  // Réappliquer plusieurs fois pour s'assurer que ça fonctionne
  setTimeout(function() { applyCorrections(); }, 1000);
  setTimeout(function() { applyCorrections(); }, 2000);
  
  // Fonction pour appliquer toutes les corrections de centrage
  function applyCorrections() {
    // Fixer le conteneur principal (fluidPage)
    $('body > .container-fluid').css({
      'width': '100%',
      'max-width': '100%',
      'margin-left': 'auto',
      'margin-right': 'auto',
      'padding-left': '0',
      'padding-right': '0',
      'display': 'flex',
      'flex-direction': 'column',
      'align-items': 'center'
    });
    
    // Fixer la navbar
    $('.page-navbar').css({
      'width': '100%',
      'max-width': '100%'
    });
    
    // Fixer le contenu de l'onglet
    $('.tab-content').css({
      'width': '100%',
      'display': 'flex',
      'flex-direction': 'column',
      'align-items': 'center'
    });
    
    // Centrer les conteneurs principaux
    $('.container, .home-container, .delegates-container, .candidates-container, .vote-container, .stats-container, .results-container, .ideas-container')
      .css({
        'width': '100%',
        'max-width': '1200px',
        'margin-left': 'auto',
        'margin-right': 'auto',
        'padding-left': '15px',
        'padding-right': '15px',
        'box-sizing': 'border-box',
        'float': 'none',
        'position': 'relative',
        'display': 'block',
        'text-align': 'center'
      });
    
    // Corriger les rangées pour qu'elles prennent toute la largeur
    $('.row')
      .css({
        'width': '100%',
        'margin-left': '0',
        'margin-right': '0',
        'display': 'flex',
        'flex-wrap': 'wrap',
        'justify-content': 'center',
        'box-sizing': 'border-box'
      });
    
    // Corriger le positionnement des colonnes
    $('.col, .col-1, .col-2, .col-3, .col-4, .col-5, .col-6, .col-7, .col-8, .col-9, .col-10, .col-11, .col-12, ' +
        '.col-md-1, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6, .col-md-7, .col-md-8, .col-md-9, .col-md-10, .col-md-11, .col-md-12, ' +
        '.col-lg-1, .col-lg-2, .col-lg-3, .col-lg-4, .col-lg-5, .col-lg-6, .col-lg-7, .col-lg-8, .col-lg-9, .col-lg-10, .col-lg-11, .col-lg-12')
      .css({
        'float': 'none',
        'position': 'relative',
        'box-sizing': 'border-box',
        'text-align': 'left' // Garder le texte aligné à gauche dans les colonnes
      });
    
    // Corriger l'affichage des cartes
    $('.card')
      .css({
        'width': '100%',
        'margin-left': 'auto',
        'margin-right': 'auto',
        'box-sizing': 'border-box'
      });
    
    // S'assurer que le contenu des cartes est aligné à gauche
    $('.card-body, .card-header, .card-footer').css({
      'text-align': 'left'
    });
    
    // Corriger les bannières
    $('.banner, .home-banner, .vote-banner, .ideas-banner, .stats-banner, .results-banner')
      .css({
        'width': '100%',
        'margin-left': 'auto',
        'margin-right': 'auto',
        'box-sizing': 'border-box'
      });
    
    // Corriger les éléments flottants
    $('.floating-filter, .floating-profile, .floating-results')
      .css({
        'width': '100%',
        'box-sizing': 'border-box'
      });

    // Forcer le centrage sur les éléments spécifiques
    $('.class-buttons-grid').css({
      'display': 'flex',
      'flex-wrap': 'wrap',
      'justify-content': 'center',
      'width': '100%'
    });
  }
}); 