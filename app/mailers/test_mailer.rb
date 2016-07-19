class TestMailer < ActionMailer::Base

  def test_mail(options = {})
    options = {
      subject: "Test",
      from: "no-reply@example.com"
    }.merge(options)

    mail subject: options[:subject],
      from: options[:from],
      to: options[:to],
      smtp_envelope_to: options[:smtp_envelope_to]
  end

end