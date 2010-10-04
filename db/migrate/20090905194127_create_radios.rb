class CreateRadios < ActiveRecord::Migration
  def self.up
    create_table :radios do |t|
      t.string :name
      t.string :mode
      t.integer :channel
      t.text :notes
      t.integer :output_band

      t.belongs_to :access_point

      t.belongs_to :radio_template

      t.timestamps
    end
  end

  def self.down
    drop_table :radios
  end
end
