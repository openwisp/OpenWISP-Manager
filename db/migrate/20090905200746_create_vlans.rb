class CreateVlans < ActiveRecord::Migration
  def self.up
    create_table :vlans do |t|
      t.text :notes
      t.integer :output_band_percent
      t.integer :tag

      t.references :interface, :polymorphic => true

      t.belongs_to :bridge

      t.belongs_to :vlan_template

      t.timestamps
    end
  end

  def self.down
    drop_table :vlans
  end
end
