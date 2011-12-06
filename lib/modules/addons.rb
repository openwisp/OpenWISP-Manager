# This file is part of the OpenWISP Manager
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module Addons
  module Mappable
    include Geokit::Geocoders

    def get_center_zoom(mappables)
      max_lat = max_lon = 0.0
      min_lat = min_lon = 360.0

      mappables.each do |m|
        lat = m.send(m.class.lat_column_name)
        lon = m.send(m.class.lng_column_name)

        if lat > max_lat
          max_lat =  lat
        end
        if lat < min_lat
          min_lat = lat
        end

        if lon > max_lon
          max_lon =  lon
        end
        if lon < min_lon
          min_lon = lon
        end
      end

      max_distance = (max_lat - min_lat) > (max_lon - min_lon) ? (max_lat - min_lat) : (max_lon - min_lon)
      if max_distance > 0
        [(max_lat + min_lat)/2, (max_lon + min_lon)/2, (16 - (Math::log(max_distance * 2000))).to_i]
      else
        [(max_lat + min_lat)/2, (max_lon + min_lon)/2, 16]
      end
    end

    def get_center(mappables)
      max_lat = max_lon = 0.0
      min_lat = min_lon = 360.0

      mappables.each do |m|
        lat = m.send(m.class.lat_column_name)
        lon = m.send(m.class.lng_column_name)

        if lat > max_lat
          max_lat =  lat
        elsif lat < min_lat
          min_lat = lat
        end

        if lon > max_lon
          max_lon =  lon
        elsif lon < min_lon
          min_lon = lon
        end
      end

      [(max_lat + min_lat)/2, (max_lon + min_lon)/2]
    end

    def get_wisp_geocode(wisp_address)
      env = ENV['RAILS_ENV'] || RAILS_ENV
      geocode = GoogleGeocoder::geocode(wisp_address)
      if geocode.success?
        geocode.to_a
      else
        [0,0]
      end
    end
  end
end