class AccessPointGroup < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'
  
  validates_presence_of :name
  validates_format_of :name, :with => /\A[\w\d_\s\.]+\Z/i
  validates_length_of :name, :maximum => 32
  validates_uniqueness_of :name, :scope => :wisp_id
    
  has_and_belongs_to_many :access_points

  belongs_to :wisp
  
end
