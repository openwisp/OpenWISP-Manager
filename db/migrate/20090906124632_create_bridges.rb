class CreateBridges < ActiveRecord::Migration
  def self.up
    create_table :bridges do |t|
      t.string :name
      t.string :ip
      t.string :netmask
      t.string :gateway
      t.string :dns
      t.text :notes
      
      # static, dynamic, none
      t.string :addressing_mode

      t.references :machine, :polymorphic => true

      t.belongs_to :bridge_template

      t.timestamps
    end
  end

  def self.down
    drop_table :bridges
  end
end
