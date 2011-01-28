# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def observe_fields(fields, options)
    ret = ""
    fields.each do |field|
      ret += observe_field(field, options.merge({ :with => field }))
    end
    ret
  end

  def auth?(role, object=nil)
    current_operator && current_operator.has_role?(role, object)
  end

end
