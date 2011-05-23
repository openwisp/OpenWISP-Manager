class AddOwmwInfoToWisp < ActiveRecord::Migration
  def self.up
    add_column :wisps, :owmw_url, :string
    add_column :wisps, :owmw_username, :string
    add_column :wisps, :owmw_password, :string
  end

  def self.down
    remove_column :wisps, :owmw_url
    remove_column :wisps, :owmw_username
    remove_column :wisps, :owmw_password
  end
end
