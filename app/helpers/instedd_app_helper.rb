module InsteddAppHelper
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
            "#{pluralize(object.errors.count, 'error')} prohibited this #{object_name.humanize} from being saved:"
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
      (content_tag :h2, 'The following errors occurred') \
      + \
      (content_tag :ul do
        raw resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      end)
    end)
  end
end