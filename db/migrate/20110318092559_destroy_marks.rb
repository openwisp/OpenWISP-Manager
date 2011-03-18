class DestroyMarks < ActiveRecord::Migration
  def self.up
    drop_table :marks
  end

  def self.down
    create_table :marks do |t|
      t.column :markable_id, :string
      t.column :markable_type, :string
      t.column :changed_at, :datetime
    end
  end
end
