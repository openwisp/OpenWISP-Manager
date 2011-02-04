class TemplateGroup < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :wisp_id
  validates_format_of :name, :with => /\A[\w\d_\.\s]+\Z/i
  validates_length_of :name, :maximum => 32
  
  has_and_belongs_to_many :access_point_templates

  belongs_to :wisp
  
end
