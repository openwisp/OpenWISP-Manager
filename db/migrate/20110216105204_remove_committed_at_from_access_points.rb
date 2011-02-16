class RemoveCommittedAtFromAccessPoints < ActiveRecord::Migration
  def self.up
    remove_column :access_points, :committed_at
  end

  def self.down
    add_column :access_points, :committed_at, :datetime
  end
end
