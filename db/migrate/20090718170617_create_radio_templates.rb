class CreateRadioTemplates < ActiveRecord::Migration
  def self.up
    create_table :radio_templates do |t|
      t.string :name, :null => false
      t.string :mode, :null => false
      t.integer :channel, :null => false
      t.text :notes
      t.integer :output_band

      t.belongs_to :access_point_template

      t.timestamps
    end
  end

  def self.down
    drop_table :radio_templates
  end
end
