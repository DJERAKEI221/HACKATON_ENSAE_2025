// JavaScript pour la page des candidats

$(document).ready(function() {
  // Gestion des messages personnalisés de Shiny
  Shiny.addCustomMessageHandler('show_candidate_modal', function(message) {
    $('#candidate-modal').modal('show');
  });
  
  Shiny.addCustomMessageHandler('hide_candidate_modal', function(message) {
    $('#candidate-modal').modal('hide');
  });
  
  Shiny.addCustomMessageHandler('scroll_to_filters', function(message) {
    $('.filter-sidebar').get(0).scrollIntoView({ behavior: 'smooth' });
  });
  
  Shiny.addCustomMessageHandler('preselect_candidate', function(message) {
    // Cette fonction sera utilisée pour pré-sélectionner un candidat dans la page de vote
    console.log('Candidat pré-sélectionné:', message.candidate_id);
  });
  
  // Animation d'entrée progressive
  $('.hero-section').addClass('animate__animated animate__fadeInDown');
  $('.filter-sidebar').addClass('animate__animated animate__fadeInLeft animate__delay-1s');
  $('.candidates-grid').addClass('animate__animated animate__fadeInUp animate__delay-2s');
  
  // Gestion des boutons de vue (grille/liste)
  $(document).on('click', '#grid_view', function() {
    $(this).addClass('active');
    $('#list_view').removeClass('active');
    $('.candidates-grid-container, .candidates-list-container').addClass('animate__animated animate__fadeIn');
  });
  
  $(document).on('click', '#list_view', function() {
    $(this).addClass('active');
    $('#grid_view').removeClass('active');
    $('.candidates-grid-container, .candidates-list-container').addClass('animate__animated animate__fadeIn');
  });
  
  // Gestion des filtres avec animation
  $(document).on('click', '.filter-chip', function() {
    $('.candidates-grid .candidate-card, .candidates-list .candidate-list-item').addClass('animate__animated animate__fadeIn');
  });
  
  // Animation au survol des cartes candidats (mode grille)
  $(document).on('mouseenter', '.candidate-card', function() {
    $(this).addClass('animate__animated animate__pulse');
    $(this).find('.candidate-actions').slideDown(200);
  });
  
  $(document).on('mouseleave', '.candidate-card', function() {
    $(this).removeClass('animate__animated animate__pulse');
    $(this).find('.candidate-actions').slideUp(200);
  });
  
  // Animation au survol des éléments de liste
  $(document).on('mouseenter', '.candidate-list-item', function() {
    $(this).addClass('animate__animated animate__pulse');
  });
  
  $(document).on('mouseleave', '.candidate-list-item', function() {
    $(this).removeClass('animate__animated animate__pulse');
  });
  
  // Gestion du modal de profil candidat
  $(document).on('click', '.view-profile-btn', function() {
    $('.modal-content').addClass('animate__animated animate__zoomIn');
  });
  
  // Recherche en temps réel
  $(document).on('input', '#candidate_search', function() {
    const searchTerm = $(this).val().toLowerCase();
    $('.candidate-card, .candidate-list-item').each(function() {
      const candidateName = $(this).find('.candidate-name, .candidate-list-name').text().toLowerCase();
      if (candidateName.includes(searchTerm)) {
        $(this).show().addClass('animate__animated animate__fadeIn');
      } else {
        $(this).hide();
      }
    });
  });
  
  // Tri des candidats
  $(document).on('change', '#sort_candidates', function() {
    $('.candidates-grid, .candidates-list-container').addClass('animate__animated animate__fadeIn');
  });
  
  // Parallax effect pour le hero
  $(window).scroll(function() {
    const scrolled = $(this).scrollTop();
    $('.hero-background').css('transform', 'translateY(' + (scrolled * 0.5) + 'px)');
  });
  
  // Smooth scroll pour les ancres
  $(document).on('click', 'a[href^="#"]', function(e) {
    e.preventDefault();
    const target = $($(this).attr('href'));
    if (target.length) {
      $('html, body').animate({
        scrollTop: target.offset().top - 100
      }, 800);
    }
  });
  
  // Gestion du FAB menu
  $(document).on('click', '#fab_main', function() {
    $('#fab-options').toggleClass('show');
  });
  
  // Fermer le FAB menu en cliquant ailleurs
  $(document).on('click', function(e) {
    if (!$(e.target).closest('.floating-action-menu').length) {
      $('#fab-options').removeClass('show');
    }
  });
  
  // Gestion responsive du modal
  $(window).on('resize', function() {
    if ($(window).width() < 768) {
      $('.modal-dialog').removeClass('modal-xl').addClass('modal-lg');
    } else {
      $('.modal-dialog').removeClass('modal-lg').addClass('modal-xl');
    }
  });
  
  // Animation de nettoyage lors de la fermeture du modal
  $('#candidate-modal').on('hidden.bs.modal', function() {
    $('.modal-content').removeClass('animate__animated animate__zoomIn');
  });
  
  // Gestion des tooltips pour les boutons FAB
  $('[title]').tooltip();
  
  // Amélioration de l'accessibilité - navigation au clavier
  $(document).on('keydown', '.candidate-card, .candidate-list-item', function(e) {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      $(this).find('.view-profile-btn, .btn-outline-primary').first().click();
    }
  });
  
  // Ajout d'attributs d'accessibilité
  $('.candidate-card, .candidate-list-item').attr('tabindex', '0').attr('role', 'button');
  
  // Gestion du focus pour l'accessibilité
  $('.candidate-card, .candidate-list-item').on('focus', function() {
    $(this).addClass('focused');
  }).on('blur', function() {
    $(this).removeClass('focused');
  });
});

// Fonction utilitaire pour déboguer
function debugCandidatesPage() {
  console.log('Candidats page debug info:');
  console.log('Nombre de cartes candidats:', $('.candidate-card').length);
  console.log('Filtres actifs:', $('.filter-chip.active').length);
  console.log('Terme de recherche:', $('#candidate_search').val());
}

// Fonction pour rafraîchir les animations
function refreshAnimations() {
  $('.candidate-card').removeClass('animate__animated animate__fadeIn');
  setTimeout(function() {
    $('.candidate-card:visible').addClass('animate__animated animate__fadeIn');
  }, 100);
} 