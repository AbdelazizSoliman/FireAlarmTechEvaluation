module SupplierMailerHelper
  def link_for_subsystem(subsystem)
    case subsystem.name.downcase
    when 'fire alarm'
      'https://drive.google.com/file/d/1SufADcLbZeWvnM_83-8VY_bI474UNZpw/view?usp=sharing'
    when 'data'
      'https://example.com/docs/data'
    else
      'https://example.com/docs/default'
    end
  end
end
