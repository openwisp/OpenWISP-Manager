# This file is part of the OpenWISP Manager
#
# Copyright (C) 2010 CASPUR (wifi@caspur.it)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
