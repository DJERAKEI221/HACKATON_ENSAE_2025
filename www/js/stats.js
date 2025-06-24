/**
 * Gestion JavaScript pour la page Statistiques
 */
$(document).ready(function() {
  // Handler pour imprimer la section statistiques
  Shiny.addCustomMessageHandler("print_stats_section", function(message) {
    // Sélectionner la section à imprimer
    var statsSection = document.querySelector('.stats-container');
    if (!statsSection) {
      console.error("Section statistiques introuvable !");
      return;
    }

    // Créer une nouvelle fenêtre pour l'impression
    var printWindow = window.open('', '_blank');
    printWindow.document.write('<html><head><title>Statistiques des élections ENSAE</title>');
    
    // Copier les styles CSS
    var styles = document.querySelectorAll('link[rel="stylesheet"], style');
    styles.forEach(function(style) {
      printWindow.document.write(style.outerHTML);
    });
    
    // Ajouter des styles spécifiques pour l'impression
    printWindow.document.write(`
      <style>
        body { padding: 20px; }
        .stats-container { max-width: 100%; }
        .card { border: 1px solid #ddd; margin-bottom: 20px; }
        .card-header { background-color: #f8f9fa; padding: 10px; }
        .card-body { padding: 15px; }
        @media print {
          .no-print { display: none !important; }
        }
      </style>
    `);
    
    printWindow.document.write('</head><body>');
    printWindow.document.write('<div class="stats-container">');
    printWindow.document.write(statsSection.innerHTML);
    printWindow.document.write('</div></body></html>');
    
    printWindow.document.close();
    
    // Attendre que les ressources soient chargées avant d'imprimer
    printWindow.onload = function() {
      printWindow.focus();
      printWindow.print();
      // Fermer la fenêtre après l'impression
      printWindow.onafterprint = function() {
        printWindow.close();
      };
    };
  });

  // Améliorer l'apparence des boutons de téléchargement
  $('.download-button').hover(
    function() {
      $(this).addClass('btn-hover');
    },
    function() {
      $(this).removeClass('btn-hover');
    }
  );

  // Ajouter des styles pour les boutons
  $('<style>')
    .text(`
      .download-button {
        transition: all 0.3s ease;
      }
      .download-button.btn-hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
      }
      .btn-info {
        background-color: #17a2b8;
        border-color: #17a2b8;
        color: white;
      }
      .btn-info:hover {
        background-color: #138496;
        border-color: #117a8b;
      }
    `)
    .appendTo('head');
}); 