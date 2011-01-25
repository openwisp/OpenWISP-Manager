class AddIpaddressToAccessPoint < ActiveRecord::Migration
  def self.up
    add_column :access_points, :ip_address, :string
  end

  def self.down
    remove_column :access_points, :ip_address
  end
end
