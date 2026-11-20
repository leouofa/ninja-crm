module ApplicationHelper
  def active_nav_class(controller_name_to_match)
    if controller_name == controller_name_to_match
      "bg-slate-900 text-white font-medium shadow-sm"
    else
      "text-slate-600 hover:text-slate-900 hover:bg-slate-100 transition-colors"
    end
  end
end
