
$(document).foundation();

$(document).ready( function() {
  $("body").fadeIn('slow');
  $(".way .go").click( function() {
    $go_link = $(this);
    go_url = $go_link.attr("href");
    $.get( go_url, function(json) {
      if ( json.go == true ) {
        $go_link.siblings(".going").text(json.going).fadeIn('slow', function() {
          $("body").fadeOut('slow', function() {
            window.location.reload(true);
          });
        });
      } else {
        $go_link.siblings(".going").text(json.going).fadeIn('slow');
      };
    });
    return false;
  });
});
 
