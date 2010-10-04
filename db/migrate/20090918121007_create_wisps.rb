class CreateWisps < ActiveRecord::Migration
  def self.up
    create_table :wisps do |t|
      t.string :name, :null => false
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :wisps
  end
end
