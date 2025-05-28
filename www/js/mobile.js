// Détection de l'appareil mobile et proposition de redirection
document.addEventListener('DOMContentLoaded', function() {
  // Fonction pour détecter si l'utilisateur est sur mobile
  function isMobileDevice() {
    return (typeof window.orientation !== "undefined") || 
           (navigator.userAgent.indexOf('IEMobile') !== -1) ||
           window.innerWidth < 768;
  }
  
  // Si c'est un mobile et pas déjà sur la version mobile
  if (isMobileDevice() && window.location.href.indexOf('mobile.html') === -1) {
    // Créer une bannière en haut de l'écran
    var banner = document.createElement('div');
    banner.style.position = 'fixed';
    banner.style.top = '0';
    banner.style.left = '0';
    banner.style.right = '0';
    banner.style.background = '#3f51b5';
    banner.style.color = 'white';
    banner.style.padding = '10px';
    banner.style.textAlign = 'center';
    banner.style.zIndex = '9999';
    banner.style.fontSize = '14px';
    banner.style.boxShadow = '0 2px 5px rgba(0,0,0,0.2)';
    
    // Contenu de la bannière
    banner.innerHTML = 'Version mobile disponible pour une meilleure expérience. <a href="mobile.html" style="color:white;text-decoration:underline;font-weight:bold;">Cliquez ici</a> pour y accéder.';
    
    // Ajouter au document
    document.body.appendChild(banner);
    
    // Ajouter une marge en haut pour éviter que le contenu ne soit caché par la bannière
    document.body.style.marginTop = banner.offsetHeight + 'px';
  }

  // Animations et fonctionnalités pour l'en-tête
  enhanceHeader();
});

// Mobile.js - Enhanced mobile experience and floating elements

$(document).ready(function() {
  // Mobile menu toggling
  $('.navbar-toggler').on('click', function() {
    if (!$('.navbar-collapse').hasClass('show')) {
      $('.navbar-collapse').addClass('show');
    } else {
      $('.navbar-collapse').removeClass('show');
    }
  });
  
  // Handle floating action buttons
  setupFloatingActionButtons();
  
  // Handle scroll events
  $(window).scroll(function() {
    handleScrollEffects();
    enhanceHeaderOnScroll();
  });
  
  // Initialize tooltips
  $('[data-bs-toggle="tooltip"]').tooltip();
});

// Fonction pour améliorer l'en-tête
function enhanceHeader() {
  // Animation de l'en-tête au chargement de la page
  setTimeout(function() {
    $('.logo-container').addClass('loaded');
    $('.main-title').addClass('loaded');
    $('.year-badge').addClass('loaded');
  }, 300);
  
  // Effet de parallaxe sur le logo
  $('.header-container').on('mousemove', function(e) {
    const moveX = (e.pageX - $(this).offset().left - $(this).width()/2) / 20;
    const moveY = (e.pageY - $(this).offset().top - $(this).height()/2) / 20;
    
    $('.logo-container').css({
      'transform': 'rotate(-2deg) translate(' + moveX + 'px, ' + moveY + 'px)'
    });
  });
  
  // Réinitialiser la position du logo quand la souris quitte l'en-tête
  $('.header-container').on('mouseleave', function() {
    $('.logo-container').css({
      'transform': 'rotate(-2deg)'
    });
  });
  
  // Appliquer des animations sur les onglets
  $('.nav-item').hover(
    function() {
      $(this).css('transform', 'translateY(-3px)');
    },
    function() {
      $(this).css('transform', 'translateY(0)');
    }
  );
}

// Améliorations de l'en-tête lors du défilement
function enhanceHeaderOnScroll() {
  const scrollY = $(window).scrollTop();
  
  // Réduire la taille de l'en-tête au défilement
  if (scrollY > 50) {
    $('.navbar').addClass('navbar-scrolled');
    $('.header-logo').css('height', '50px');
    $('.main-title').css('fontSize', '1.3rem');
    $('.year-badge').css({'fontSize': '0.7rem', 'padding': '1px 6px'});
    // Ajuster le padding du body pour la nouvelle hauteur de l'en-tête
    $('body').css('padding-top', '80px');
  } else {
    $('.navbar').removeClass('navbar-scrolled');
    $('.header-logo').css('height', $(window).width() > 991 ? '60px' : '50px');
    $('.main-title').css('fontSize', $(window).width() > 991 ? '1.6rem' : '1.3rem');
    $('.year-badge').css({'fontSize': $(window).width() > 991 ? '0.8rem' : '0.7rem', 'padding': $(window).width() > 991 ? '2px 8px' : '1px 6px'});
    // Réinitialiser le padding du body
    $('body').css('padding-top', '100px');
  }
}

// Function to set up floating action buttons
function setupFloatingActionButtons() {
  // Candidates page quick vote button
  $('#quick_vote_button').on('click', function() {
    // Scroll to voting section or trigger vote modal
    $('#vote_for_candidate').trigger('click');
  });
  
  // Results page quick download button
  $('#quick_download_button').on('click', function() {
    // Trigger the download button
    $('#downloadPV').trigger('click');
  });
  
  // Delegates page quick vote button
  $('#quick_delegate_vote_button').on('click', function() {
    // Scroll to voting section
    $('html, body').animate({
      scrollTop: $('.delegate-card').offset().top - 100
    }, 500);
    // Flash the vote button to draw attention
    $('#submit_delegate_vote').addClass('btn-pulse');
    setTimeout(function() {
      $('#submit_delegate_vote').removeClass('btn-pulse');
    }, 2000);
  });
  
  // Create floating menu functionality if needed
  createFloatingMenu();
}

// Function to create floating menu with multiple options
function createFloatingMenu() {
  // Check if we're on a page that would benefit from a menu
  if ($('#vote_for_candidate').length || $('#downloadPV').length) {
    // Create the menu container if it doesn't exist
    if ($('.floating-menu').length === 0) {
      $('body').append('<div class="floating-menu"></div>');
      
      // Add menu items based on page context
      if ($('#vote_for_candidate').length) {
        $('.floating-menu').append(`
          <div class="floating-menu-item vote-menu-item">
            <i class="fas fa-vote-yea"></i>
            <span>Voter maintenant</span>
          </div>
          <div class="floating-menu-item profile-menu-item">
            <i class="fas fa-user"></i>
            <span>Voir profil</span>
          </div>
        `);
      }
      
      if ($('#downloadPV').length) {
        $('.floating-menu').append(`
          <div class="floating-menu-item download-menu-item">
            <i class="fas fa-file-download"></i>
            <span>Télécharger PV</span>
          </div>
          <div class="floating-menu-item chart-menu-item">
            <i class="fas fa-chart-bar"></i>
            <span>Voir graphique</span>
          </div>
        `);
      }
      
      // Toggle menu on floating action button click
      $('.floating-action').on('click', function() {
        $('.floating-menu').toggleClass('open');
      });
      
      // Handle menu item clicks
      $('.vote-menu-item').on('click', function() {
        $('#vote_for_candidate').trigger('click');
        $('.floating-menu').removeClass('open');
      });
      
      $('.profile-menu-item').on('click', function() {
        $('html, body').animate({
          scrollTop: $('.candidate-profile-card').offset().top - 100
        }, 500);
        $('.floating-menu').removeClass('open');
      });
      
      $('.download-menu-item').on('click', function() {
        $('#downloadPV').trigger('click');
        $('.floating-menu').removeClass('open');
      });
      
      $('.chart-menu-item').on('click', function() {
        $('html, body').animate({
          scrollTop: $('#results_chart_wrapper').offset().top - 100
        }, 500);
        $('.floating-menu').removeClass('open');
      });
    }
  }
}

// Function to handle scroll effects for floating elements
function handleScrollEffects() {
  const scrollTop = $(window).scrollTop();
  
  // Adjust sticky elements based on scroll position
  if (scrollTop > 100) {
    $('.floating-filter, .floating-profile, .floating-results').addClass('scrolled');
  } else {
    $('.floating-filter, .floating-profile, .floating-results').removeClass('scrolled');
  }
  
  // Show/hide floating action button based on scroll
  if (scrollTop > 300) {
    $('.floating-action').fadeIn();
  } else {
    $('.floating-action').fadeOut();
    $('.floating-menu').removeClass('open');
  }
} 