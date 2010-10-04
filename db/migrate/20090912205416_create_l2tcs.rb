class CreateL2tcs < ActiveRecord::Migration
  def self.up
    create_table :l2tcs do |t|
      
      t.text :notes

      t.belongs_to :access_point
      t.references :shapeable, :polymorphic => true

      t.belongs_to :l2tc_template
      
      t.timestamps
    end
  end

  def self.down
    drop_table :l2tcs
  end
end
