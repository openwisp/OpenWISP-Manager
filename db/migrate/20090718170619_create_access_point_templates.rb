class CreateAccessPointTemplates < ActiveRecord::Migration
  def self.up
    create_table :access_point_templates do |t|
      t.string :name, :null => false
      t.text :notes
      
      t.belongs_to :wisp

      t.timestamps
    end
  end

  def self.down
    drop_table :access_point_templates
  end
end
