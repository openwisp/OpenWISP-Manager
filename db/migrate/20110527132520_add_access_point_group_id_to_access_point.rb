class AddAccessPointGroupIdToAccessPoint < ActiveRecord::Migration
  def self.up
    add_column :access_points, :access_point_group_id, :integer
  end

  def self.down
    remove_column :access_points, :access_point_group_id
  end
end
