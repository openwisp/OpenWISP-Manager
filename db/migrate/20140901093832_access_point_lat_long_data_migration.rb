class AccessPointLatLongDataMigration < ActiveRecord::Migration
  def self.up
    # find AP that have identical coordinates and slightly change them
    AccessPoint.all.each do |ap|
      same_coordinates = AccessPoint.all(:conditions => ["id != ? AND lat = ? AND lon = ?", ap.id, ap.lat, ap.lon])
      same_coordinates.each do |same_ap|
        while true
          # repeat this code until
          if rand(10) > 5
            new_lat = same_ap.lat + (rand / 10000)
          else
            new_lat = same_ap.lat - (rand / 10000)
          end

          if rand(10) > 5
            new_lon = same_ap.lon + (rand / 10000)
          else
            new_lon = same_ap.lon - (rand / 10000)
          end

          old_lat = same_ap.lat
          old_lon = same_ap.lon

          # if coordinates are really unique
          if AccessPoint.all(:conditions => ["lat = ? AND lon = ?", new_lat, new_lon]).count < 1
            begin
              same_ap.lat = new_lat
              same_ap.lon = new_lon
              same_ap.save!
            rescue Exception
              puts "Access Point #{same_ap.name} errors: #{same_ap.errors}"
            else
              puts "Access Point #{same_ap.name} old coords: #{old_lat}, #{old_lon} - new coords: #{new_lat}, #{new_lon}"
            ensure
              break
            end
          else
            puts "Access Point #{same_ap.name} new coordinates not unique, looking for new coordinates"
          end
        end
      end
    end

  end

  def self.down
  end
end
