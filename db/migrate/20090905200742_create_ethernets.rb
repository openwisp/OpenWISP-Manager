class CreateEthernets < ActiveRecord::Migration
  def self.up
    create_table :ethernets do |t|
      t.string :name
      t.text :notes
      t.integer :output_band

      t.belongs_to :bridge
      t.references :machine, :polymorphic => true

      t.belongs_to :ethernet_template

      t.timestamps
    end
  end

  def self.down
    drop_table :ethernets
  end
end
