class AddConfigurationOutdatedToAccessPoint < ActiveRecord::Migration
  def self.up
    add_column :access_points, :configuration_outdated, :boolean, :default => false
  end

  def self.down
    remove_column :access_points, :configuration_outdated
  end
end
