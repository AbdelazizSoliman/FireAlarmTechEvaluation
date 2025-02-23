class SupplierMailer < ApplicationMailer
  def rfq_email
    @supplier = params[:supplier]
    # Assuming the supplier’s associations (projects, subsystems, etc.) are already loaded
    @projects = @supplier.projects
    @subsystems = @supplier.approved_subsystems

    # Build a subject line that includes the project name(s) and subsystem(s)
    subject_text = "RFQ for #{@projects.pluck(:name).join(', ')} - #{@subsystems.pluck(:name).join(', ')}"

    mail(
      to: @supplier.supplier_email,
      subject: subject_text
    )
  end
end
