class Operator < ActiveRecord::Base
  acts_as_authentic
  acts_as_authorization_subject
  acts_as_authorization_object :subject_class_name => 'Operator'

  belongs_to :wisp
  
  ROLES = %w(wisp_admin wisp_operator wisp_viewer)
  
  def initialize(params = nil)
    super(params)
    
  end
  
  def roles
    @rs = []
    Operator::ROLES.each do |r|
      @rs << r if self.has_role?(r)
    end
    @rs
  end
  
end
