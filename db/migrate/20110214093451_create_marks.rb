class CreateMarks < ActiveRecord::Migration
  def self.up
    create_table :marks do |t|
      t.column :markable_id, :string
      t.column :markable_type, :string
      t.column :changed_at, :datetime
    end
  end

  def self.down
    drop_table :marks
  end
end
