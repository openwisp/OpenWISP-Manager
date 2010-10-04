class CreateL2tcTemplates < ActiveRecord::Migration
  def self.up
    create_table :l2tc_templates do |t|
      t.text :notes

      t.belongs_to :access_point_template
      t.references :shapeable_template, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :l2tc_templates
  end
end
