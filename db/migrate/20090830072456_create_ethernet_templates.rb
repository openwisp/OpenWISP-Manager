class CreateEthernetTemplates < ActiveRecord::Migration
  def self.up
    create_table :ethernet_templates do |t|
      t.string :name
      t.text :notes
      t.integer :output_band

      t.belongs_to :bridge_template
      t.belongs_to :access_point_template

      t.timestamps
    end
  end

  def self.down
    drop_table :ethernet_templates
  end
end
