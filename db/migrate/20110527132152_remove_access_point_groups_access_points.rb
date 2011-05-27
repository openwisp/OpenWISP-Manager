class RemoveAccessPointGroupsAccessPoints < ActiveRecord::Migration
  def self.up
    drop_table :access_point_groups_access_points
  end

  def self.down
    create_table :access_point_groups_access_points, :id => false, :force => true do |t|
      t.integer :access_point_id
      t.integer :access_point_group_id

      t.timestamps
    end
  end
end
