# frozen_string_literal: true

module ApplicationHelper
  def active_class(link_path)
    request.path.include?(link_path) && link_path != "/" ? 'bg-sidebarActiveBg text-white rounded-md' : 'text-white hover:bg-sidebarActiveBg rounded-md'
  end

  def current_page_name
    controller_link = link_to(controller_name.titleize, { controller: controller_name, action: 'index' })

    "#{controller_link}
        <li>
          <svg class=\"h-4 w-4 text-gray-400\" xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke=\"currentColor\">
            <path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M9 5l7 7-7 7\" />
          </svg>
        </li>
        #{action_name.titleize}".html_safe
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
