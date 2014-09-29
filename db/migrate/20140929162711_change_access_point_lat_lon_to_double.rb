class ChangeAccessPointLatLonToDouble < ActiveRecord::Migration
  def self.up
    change_column :access_points, :lat, :double
    change_column :access_points, :lon, :double
  end

  def self.down
    change_column :access_points, :lat, :float
    change_column :access_points, :lon, :float
  end
end
