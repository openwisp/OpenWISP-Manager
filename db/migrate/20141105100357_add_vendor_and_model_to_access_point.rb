class AddVendorAndModelToAccessPoint < ActiveRecord::Migration
  def self.up
    add_column :access_points, :vendor, :string
    add_column :access_points, :model, :string
  end

  def self.down
    remove_column :access_points, :vendor
    remove_column :access_points, :model
  end
end
