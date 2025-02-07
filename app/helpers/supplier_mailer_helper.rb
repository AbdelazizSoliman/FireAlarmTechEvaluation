module SupplierMailerHelper
  def link_for_subsystem(subsystem)
    case subsystem.name.downcase
    when 'fire alarm'
      'https://drive.google.com/file/d/1SufADcLbZeWvnM_83-8VY_bI474UNZpw/view?usp=sharing'
    when 'cctv'
      'https://docs.google.com/spreadsheets/d/1CmTy_b6GDQOE4Htl3QZFP4Re_S9SY8nc/edit?usp=drive_link&ouid=101904130154790046861&rtpof=true&sd=true'
    else
      'https://example.com/docs/default'
    end
  end
end
