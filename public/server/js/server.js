
$(document).foundation();

$(document).ready( function() {
  $(".way .go").click( function() {
    $go_link = $(this);
    go_url = $go_link.attr("href");
    $.get( go_url, function(json) {
      $go_link.siblings(".going").text(json.going);
      if ( json.go == true ) {
        window.setTimeout( function() {
          window.location.reload(true);
        }, 3000 );
      };
    });
    return false;
  });
});
 
