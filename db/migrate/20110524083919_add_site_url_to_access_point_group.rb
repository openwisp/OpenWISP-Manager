class AddSiteUrlToAccessPointGroup < ActiveRecord::Migration
  def self.up
    add_column :access_point_groups, :site_url, :string
  end

  def self.down
    remove_column :access_point_groups, :site_url
  end
end
