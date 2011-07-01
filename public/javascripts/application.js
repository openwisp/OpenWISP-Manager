// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
    if ((typeof(gmaps) !== 'undefined') && gmaps) {
        $.each(gmaps.maps, function(){
            gmaps.drawMap(this);
        });
    }
});

function exists(_selector) {
    return ($(_selector).length > 0);
}
