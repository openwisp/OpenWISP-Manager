class CreateVlanTemplates < ActiveRecord::Migration
  def self.up
    create_table :vlan_templates do |t|
      t.text :notes
      t.integer :output_band_percent
      t.integer :tag

      t.references :interface_template, :polymorphic => true

      t.belongs_to :bridge_template

      t.timestamps
    end
  end

  def self.down
    drop_table :vlan_templates
  end
end
