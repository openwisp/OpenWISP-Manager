var gmaps = {
/***********************************/
    // Configuration Variables

    // div and JSON url for markers
    // json_marker function should always
    // return an hash of options (compatible
    // with google map's markers options).
    // The additional info_window variable should
    // be an html string to be added as the marker's
    // infoWindow.
    maps: [
        {
            div: '#wisp_map',
            mapTypeId: 'hybrid',
            zoom: 4,
            hide_html_marker_if_json_not_empty: true,
            html_marker: function() {
                return {
                    position: gmaps.getCoords($('.lat').html(), $('.lon').html())
                };
            },
            json_url: window.location.href+"/access_points.json",
            json_marker: function(data) {
                return {
                    position: gmaps.getCoords(data.access_point.lat, data.access_point.lon),
                    title: data.access_point.name,
                    info_window: data.access_point.info_window
                }
            }
        },
        {
            div: '#access_point_map',
            zoom: 16,
            html_marker: function() {
                return {
                    position: gmaps.getCoords($('.lat').html(), $('.lon').html())
                };
            }
        },
        {
            div: '#access_point_new_map, #access_point_edit_map',
            html_marker: function() {
                return {
                    position: gmaps.getCoords($('.lat').html(), $('.lon').html()),
                    zIndex: 9999,
                    icon: "http://maps.gstatic.com/intl/en_en/mapfiles/ms/micons/grn-pushpin.png",
                    shadow: new google.maps.MarkerImage(
                            "http://maps.google.com/mapfiles/ms/micons/pushpin_shadow.png",
                            new google.maps.Size(38, 38),
                            new google.maps.Point(0, 0),
                            new google.maps.Point(15, 32)
                            ),
                    draggable: true,
                    drag_event: ['dragend', function(marker){
                        $('#access_point_lat').val(marker.getPosition().lat());
                        $('#access_point_lon').val(marker.getPosition().lng());
                        gmaps.reverse_geocode_zip('#access_point_zip');
                    }]
                };
            },
            //Use except=access_poin_id to skip that id from retrieved access points
            json_url: window.location.href.replace(/access_points\/(\d*).*/, "access_points.json?except=$1"),
            json_marker: function(json) {
                return {
                    position: gmaps.getCoords(json.access_point.lat, json.access_point.lon),
                    title: json.access_point.name,
                    info_window: json.access_point.info_window
                };
            }
        }
    ],

    // Use these selectors to retrieve lat e lon
    // values when not using JSON (single marker)
    lat: '.lat',
    lon: '.lon',

    // Google maps default opts
    map_defaults: {
        zoom: 9,
        mapTypeId: 'roadmap'
    },

/***********************************/
    //Private variables
    _map: undefined,
    _map_conf: undefined,
    _bounds: undefined,
    _geocoder: undefined,
    _main_marker: undefined,

    //Main drawing function, it calls the other
    //functions to arrange markers on the map
    drawMap: function(_new_map) {
        var _map_div = _new_map.div;

        if (exists(_map_div)) {
            gmaps._map_conf = _new_map;
            var _lat = $(gmaps.lat).html();
            var _lon = $(gmaps.lon).html();
            var _coords = gmaps.getCoords(_lat, _lon);
            var _has_to_load_resource = gmaps._map_conf.json_url ? true : false;

            gmaps.initMap(_map_div, {
                center: _coords,
                mapTypeId: gmaps._map_conf.mapTypeId,
                zoom: gmaps._map_conf.zoom
            });

            if (_has_to_load_resource && gmaps._map_conf.html_marker) {
                gmaps.fetchMarkers(function(_fetched){
                    if (gmaps._map_conf.hide_html_marker_if_json_not_empty) {
                        if (_fetched > 0) {
                            gmaps.fitMarkers();
                        } else {
                            gmaps._main_marker = gmaps.drawMarker(gmaps._map_conf.html_marker());
                        }
                    } else {
                        gmaps._main_marker = gmaps.drawMarker(gmaps._map_conf.html_marker());
                        gmaps.fitMarkers();
                    }
                });
            } else if (_has_to_load_resource && !gmaps._map_conf.html_marker) {
                gmaps.fetchMarkers(function(){
                    gmaps.fitMarkers();
                });
            } else if (!_has_to_load_resource && gmaps._map_conf.html_marker) {
                gmaps._main_marker = gmaps.drawMarker(gmaps._map_conf.html_marker());
                if (!gmaps._map_conf.zoom) {
                    gmaps.fitMarkers();
                }
            }
        }
    },

    geocode: function(_location) {
        var _geocode_address = $(_location.street).val()+","+$(_location.zip).val()+","+$(_location.city).val();

        if (!gmaps._geocoder) {
            gmaps._geocoder = new google.maps.Geocoder();
        }

        gmaps._geocoder.geocode({address: _geocode_address}, function(results, status){
            if (status == google.maps.GeocoderStatus.OK) {
                var _position = results[0].geometry.location;
                gmaps._map.setCenter(_position, 20);
                gmaps._main_marker.setPosition(_position);
                gmaps._map.fitBounds(results[0].geometry.bounds);

                $(_location.update_fields[0]).val(_position.lat());
                $(_location.update_fields[1]).val(_position.lng());

                $(_location.zip).val(gmaps.parseZip(results));
            } else {
                console.log("Geocoding failed: " + status);
            }
        });
    },

    reverse_geocode_zip: function(_zip_selector) {
        if (!gmaps._geocoder) {
            gmaps._geocoder = new google.maps.Geocoder();
        }

        gmaps._geocoder.geocode({latLng: gmaps._main_marker.getPosition()}, function(results, status){
            if (status == google.maps.GeocoderStatus.OK) {
                $(_zip_selector).val(gmaps.parseZip(results));
            } else {
                console.log("Geocoding failed: " + status);
            }
        });
    },

    parseZip: function(_geocode_results) {
        var to_return;
        $.each(_geocode_results[0].address_components, function() {
            if (this.types[0] == "postal_code") {
                to_return = this.short_name;
                return false;
            }
        });
        return to_return;
    },

    fetchMarkers: function(_oncomplete) {
        $.getJSON(gmaps._map_conf.json_url, function(_data) {
            var _counter = 0;
            $.each(_data, function(){
                gmaps.drawMarker(gmaps._map_conf.json_marker(this));
                _counter++;
            });
            _oncomplete(_counter);
        });
    },

    mapDivs: function() {
        return $.map(gmaps.maps, function(_map){
            return _map.div;
        });
    },

    initMap: function(_map_div, _custom_opts) {
        gmaps._map = new google.maps.Map(document.getElementById($(_map_div).attr('id')), $.extend(gmaps.map_defaults, _custom_opts));
        gmaps._bounds = new google.maps.LatLngBounds();
    },

    drawMarker: function(_opts) {
        var _new_marker = new google.maps.Marker($.extend(_opts, {map: gmaps._map}));
        gmaps._bounds.extend(_new_marker.getPosition());

        if (_opts.info_window) {
            var _new_infowindow = new google.maps.InfoWindow({content: _opts.info_window});
            google.maps.event.addListener(_new_marker, 'click', function() {
                _new_infowindow.open(gmaps._map, _new_marker);
            });
        }

        if (_opts.drag_event) {
            google.maps.event.addListener(_new_marker, _opts.drag_event[0], function(){_opts.drag_event[1](_new_marker);});
        }

        return _new_marker;
    },

    fitMarkers: function() {
        gmaps._map.fitBounds(gmaps._bounds);
    },

    getCoords: function(lat, lng) {
        return new google.maps.LatLng(lat, lng);
    }
};