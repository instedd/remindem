# Copyright (C) 2011-2012, InSTEDD
# 
# This file is part of Remindem.
# 
# Remindem is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Remindem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Remindem.  If not, see <http://www.gnu.org/licenses/>.

module InsteddAppHelper

  def link_to_instedd(text, urls, html_options={})
    url = I18n.locale == :es ? urls[:latam] : urls[:instedd]
    link_to text, url, html_options
  end

  def flash_message
    res = nil

    keys = { :notice => 'flash_notice', :error => 'flash_error', :alert => 'flash_error' }

    keys.each do |key, value|
      if flash[key]
        html_option = { :class => "flash #{value}" }
        html_option[:'data-hide-timeout'] = 3000 if key == :notice
        res = content_tag :div, html_option do
          content_tag :div do
            flash[key]
          end
        end
      end
    end

    res
  end

  def errors_for(object, options = {})
    unless object.nil?
      if object.errors.any?
         # TODO change on rails 3.1 to ActiveModel::Naming.param_key(object)
        object_name = options[:as].try(:to_s) || ActiveModel::Naming.singular(object)

        content_tag :div, :class => "box error_description #{options[:class] || 'w60'}" do
          (content_tag :h2 do
            if object.errors.count == 1
              _("%{count} error prohibited this %{model} from being saved:")
            else
              _("%{count} errors prohibited this %{model} from being saved:")
            end % {count: object.errors.count, model: _(object_name.humanize)}
          end) \
          + \
          (content_tag :ul do
            raw object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
          end)
        end
      end
    end
  end
end

DeviseHelper #Force load of Devise's original module
module DeviseHelper
  def devise_error_messages!(html_options = {})
    return if resource.errors.full_messages.empty?

    (content_tag :div, :class => "box error_description #{html_options[:class] || 'w60'}"  do
      (content_tag :h2, _('The following errors occurred')) \
      + \
      (content_tag :ul do
        raw resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      end)
    end)
  end
end