class CreateTaps < ActiveRecord::Migration
  def self.up
    create_table :taps do |t|
      t.text :notes
      t.integer :output_band

      t.references :l2vpn, :polymorphic => true

      t.belongs_to :bridge

      t.belongs_to :tap_template

      t.timestamps
    end
  end

  def self.down
    drop_table :taps
  end
end
