# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_to_locale(locale)
    link_to(image_tag("locale/#{locale}.jpg", :size => "26x26"), :controller => :application, :action => :set_session_locale, :locale => locale)
  end

  def observe_fields(fields, options)
    ret =""
    params = "$('#{fields.join(',')}').serialize()"

    fields.each do |field|
      ret += observe_field(field, options.merge({ :with => params }))
    end
    ret
  end

  def auth?(role, object=nil)
    current_operator && current_operator.has_role?(role, object)
  end

  def for_ie(opts = {:version => nil, :if => nil}, &block)
    to_include = with_output_buffer(&block)
    open_tag = "<!--[if "
    open_tag << "#{opts[:if]} " unless opts[:if].nil?
    open_tag << "IE"
    open_tag << " #{opts[:version]}" unless opts[:version].nil?
    open_tag << "]>"
    concat(open_tag+capture(&block)+"<![endif]-->")
  end

end
