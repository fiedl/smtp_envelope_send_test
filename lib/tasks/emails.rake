task :emails => [:environment] do

  recipients = ENV['RECIPIENTS'].split(",")

  recipients.each do |recipient|
    mail = TestMailer.test_mail(to: recipients, smtp_envelope_to: recipient)
    mail.smtp_envelope_to = recipient if ENV['USE_SMTP_ENVELOPE_TO_SETTER']
    log_mail(mail, recipient)
    mail.deliver
  end

end

def log_mail(mail, recipient)
  print "Sending email to #{recipient}.\n"
  mail.header_fields.each do |field|
    print "  -> #{field.name}: #{field.value}\n"
  end
end
