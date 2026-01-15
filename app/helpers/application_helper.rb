module ApplicationHelper
  def status_flash_messages(name)
    case name
    when "error"
      return "danger"
    when "alert"
      return "warning"
    else
      "success"
    end
  end
end
