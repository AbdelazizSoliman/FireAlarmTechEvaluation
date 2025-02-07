class TestMailer < ApplicationMailer
  def simple_test
    mail(
      to: 'aziz2geometry@gmail.com', # Replace with your test email address if needed
      subject: 'Simple Test Email',
      body: 'This is a test email sent from Rails using SMTP.'
    )
  end
end
