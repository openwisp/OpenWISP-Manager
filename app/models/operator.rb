class Operator < ActiveRecord::Base
  acts_as_authentic
  acts_as_authorization_subject
  acts_as_authorization_object :subject_class_name => 'Operator'

  belongs_to :wisp

  # The hidden roles (that give superadmin powers)
  HIDDEN_ROLES = [
      :wisps_viewer, :wisps_creator, :wisps_manager, :wisps_destroyer
  ]

  ROLES = [
      :wisp_viewer, :wisp_manager, :operators_viewer, :operators_creator,
      :operators_manager, :operators_destroyer, :access_point_templates_creator,
      :access_point_templates_viewer, :access_point_templates_manager,
      :access_point_templates_destroyer, :access_points_creator, :access_points_viewer,
      :access_points_manager, :access_points_destroyer, :servers_viewer, :servers_creator,
      :servers_manager, :servers_destroyer
  ]

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

  def roles=(new_roles)
    to_remove = self.roles - new_roles
    to_remove.each do |role|
      self.has_no_role!(role, self.wisp) if self.wisp
      self.has_no_role!(role)
    end

    new_roles.map!{|role| role.to_sym}
    new_roles.each do |role|
      if Operator::ROLES.include? role
        self.wisp ? self.has_role!(role, self.wisp) : self.has_role!(role)
      end
    end
  end
end
