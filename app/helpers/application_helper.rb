module ApplicationHelper
  def flash_class_names(key)
    case key.to_sym
    when :notice, :success then 'bg-success text-success-content'
    when :alert, :warning then 'bg-warning text-warning-content'
    when :error, :danger then 'bg-danger text-danger-content'
    else 'bg-primary text-primary-content'
    end
  end
end
