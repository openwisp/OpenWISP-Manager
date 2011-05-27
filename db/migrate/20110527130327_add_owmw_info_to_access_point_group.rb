class AddOwmwInfoToAccessPointGroup < ActiveRecord::Migration
  def self.up
    add_column :access_point_groups, :owmw_url, :string
    add_column :access_point_groups, :owmw_username, :string
    add_column :access_point_groups, :owmw_password, :string
  end

  def self.down
    remove_column :access_point_groups, :owmw_url
    remove_column :access_point_groups, :owmw_username
    remove_column :access_point_groups, :owmw_password
  end
end
