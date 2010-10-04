class CreateTapTemplates < ActiveRecord::Migration
  def self.up
    create_table :tap_templates do |t|
      t.text :notes
      t.integer :output_band

      t.belongs_to :l2vpn_template

      t.belongs_to :bridge_template

      t.timestamps
    end
  end

  def self.down
    drop_table :tap_templates
  end
end
