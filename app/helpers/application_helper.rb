# frozen_string_literal: true

module ApplicationHelper
  def active_class(link_path)
    request.path.include?(link_path) && link_path != "/" ? 'bg-sidebarActiveBg text-white rounded-md' : 'text-white hover:bg-sidebarActiveBg rounded-md'
  end

  def current_page_name
    case controller_name
    when "projects"
      link_to("Projects", projects_path)
    when "systems"
      if params[:project_id] && params[:project_scope_id]
        link_to("Projects", projects_path) +
          " > ".html_safe +
          link_to("Project Scopes", project_project_scopes_path(params[:project_id])) +
          " > ".html_safe +
          link_to("Systems", project_project_scope_systems_path(params[:project_id], params[:project_scope_id]))
      else
        "Systems"
      end
    when "subsystems"
      if params[:project_id] && params[:project_scope_id] && params[:system_id]
        link_to("Projects", projects_path) +
          " > ".html_safe +
          link_to("Project Scopes", project_project_scopes_path(params[:project_id])) +
          " > ".html_safe +
          link_to("Systems", project_project_scope_systems_path(params[:project_id], params[:project_scope_id])) +
          " > ".html_safe +
          link_to("Subsystems", project_project_scope_system_subsystems_path(params[:project_id], params[:project_scope_id], params[:system_id]))
      else
        "Subsystems"
      end
    else
      controller_name.titleize
    end
  end
  
  def us_states
    %w[
      AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD
      MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC
      SD TN TX UT VT VA WA WV WI WY
    ]
  end

  def formatted_phone_number(phone)
    return '' if phone.nil? || phone.empty?

    digits = phone.gsub(/\D/, '')
    "+1 (#{digits[2, 3]}) #{digits[5, 3]}-#{digits[8, 4]}"
  end
end
