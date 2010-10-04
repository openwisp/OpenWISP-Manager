class CreateTemplateGroups < ActiveRecord::Migration
  def self.up
    create_table :template_groups do |t|
      t.string :name, :null => false
      t.text :notes

      t.belongs_to :wisp

      t.timestamps
    end
  end

  def self.down
    drop_table :template_groups
  end
end
