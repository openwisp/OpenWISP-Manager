class AddLastConfigurationRetrieveIpToAccessPoint < ActiveRecord::Migration
  def self.up
    add_column :access_points, :last_configuration_retrieve_ip, :string
  end

  def self.down
    remove_column :access_points, :last_configuration_retrieve_ip
  end
end
