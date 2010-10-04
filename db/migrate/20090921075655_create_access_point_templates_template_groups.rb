class CreateAccessPointTemplatesTemplateGroups < ActiveRecord::Migration
  def self.up
    create_table :access_point_templates_template_groups, :id => false, :force => true do |t|
      t.integer :access_point_template_id
      t.integer :template_group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :access_point_templates_template_groups
  end
end
