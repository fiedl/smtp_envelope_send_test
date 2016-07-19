# SmtpEnvelopeSendTest

This is a rails-4.2.7-test application for experiments with the smtp-envelope-to header.

## Installation

```bash
cd ~/rails
git clone https://github.com/fiedl/smtp_envelope_send_test
```

## Preparation

Please enter the smtp settings you are using in production in the `secrets.yml` file, but into the `development` section:

```yaml
# config/secrets.yml

development:
  smtp_address: '...'
  smtp_user: '...'
  smtp_password: '...'
  smtp_domain: '...'

```

## Usage

```bash
cd ~/rails/smtp_envelope_send_test
bin/rake emails RECIPIENTS=test1@example.com,test2@example.com
```

This sends one email to each of the recipients, having both recipients in the `To` field, but only one recipient in the `smtp-envelope-to` field.

## What does it do?

The task [emails.rake](lib/tasks/emails.rake) does this:

```ruby
# lib/tasks/emails.rake

task :emails => [:environment] do
  recipients = ENV['RECIPIENTS'].split(",")

  recipients.each do |recipient|
    mail = TestMailer.test_mail(to: recipients, smtp_envelope_to: recipient)
    log_mail(mail, recipient)
    mail.deliver
  end
end
```

## Results

My first test run produces the following output, where I've replaced the real recipient domain by `example.com`.

```bash
[10:39:28] fiedl@fiedl-mbp: ~/rails/smtp_envelope_send_test master
➜  bin/rake emails RECIPIENTS=test1@example.com,test2@example.com

Running via Spring preloader in process 40431
Sending email to test1@example.com.
  -> From: no-reply@example.com
  -> To: ["test1@example.com", "test2@example.com"]
  -> Subject: Test
  -> Mime-Version: 1.0
  -> Content-Type: text/html
  -> smtp-envelope-to: test1@example.com
Sending email to test2@example.com.
  -> From: no-reply@example.com
  -> To: ["test1@example.com", "test2@example.com"]
  -> Subject: Test
  -> Mime-Version: 1.0
  -> Content-Type: text/html
  -> smtp-envelope-to: test2@example.com
```

### Expected behavior

Looking at the inboxes of test1@example.com and test2@example.com, each recipient should receive one email, since the first one from the log above is sent to test1@example.com the second one to test2@example.com.

### Observed bahavior

Unfortunately, looking at the inboxes of test1@example.com and test2@example.com, **each recipient receives two emails**, not one.

One of the raw emails in the inbox of test1@example.com looks like this, where I have replaced the domains and ips:

```
[10:59:12] fiedl@fiedl-mbp: ~/rails/smtp_envelope_send_test master
➜  cat email1.eml

DomainKey-Status: no signature
Return-Path: <no-reply@example.com>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	example.com
X-Spam-Level: *
X-Spam-Status: No, score=1.1 required=7.0 tests=BAYES_20,HTML_MESSAGE,
	HTML_MIME_NO_HTML_TAG,MIME_HTML_ONLY,RCVD_IN_DNSWL_NONE,RCVD_IN_MSPIKE_H2
	autolearn=no autolearn_force=no version=3.4.0
X-Original-To: test1@example.com
Delivered-To: sebastian@example.com
Received: from mout.example.com (mout.example.com [___.___.___.___])
	by ___-___-___-___.example.com (Postfix) with ESMTPS id 270EE2183C3E
	for <test1@example.com>; Tue, 19 Jul 2016 10:58:06 +0200 (CEST)
Received: from wingolfsplattform.org ([___.___.___.___]) by
 mrelayeu.example.com (mreue103) with ESMTPSA (Nemesis) id
 0M7VWZ-1bBDh91xrT-00xIKv; Tue, 19 Jul 2016 10:58:16 +0200
Date: Tue, 19 Jul 2016 10:58:15 +0200
From: no-reply@example.com
To: test1@example.com,
 test2@example.com
Message-ID: <578deba7d7421_a9963fc03d03f9e8688c7@fiedl-mbp.mail>
Subject: Test
Mime-Version: 1.0
Content-Type: text/html;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
smtp-envelope-to: test1@example.com
X-Provags-ID: V03:K0:nvhwlurRx2RI8la2V+he9CtlBKkJBfut8sIucnc8lmqPSduo/mk
 HjJVD08b5yagLNOdz3CEXCgmXqvqRPi05L4SveJyyRZwG3sJmvRS+6LAtaab5fABSEhZ/Nf
 CYiW5FPoZsq1tc6SrvLt7Fu5hhZi0WH+4eZdBTkzpDXCTP6oImYn2IFPrCM8UflcoUnw+Po
 zqOX/YqA7dIZm3Lf2O22Q==
X-UI-Out-Filterresults: notjunk:1;V01:K0:we1aQuAx2Rk=:CdypLd5tBaiK6kCROKcE3p
 JVC7TW1oy1a0qWhSwbSkZQl5+DxUSjRR75wyOnnmNWpg5OnIeuKVUftb+Itfab+3ZXYMKWXBR
 ETTcQxfcPBxQ2a80Hy6gfjCpzOn1sE4RlRKOo5k0lKUOGVmDbxzdQvHzIkkiCCiqgeMYdN+BC
 rFSIKLif3eZIp+I8JriIU5FaIYMJQnpQtxh80B4aqFBpd7adSr4OXSJTqaLiGqAnReB8dYVys
 hpYIlK8727kYep2lKXlNYw+lXkCa/n4bMlRGA6ccUnWV2vOjJfUfvflpok3dC4C31MY0wJu5J
 +CoF6rq1Alk9628ifI24toHTYPtIPmOKfJ+PQ8ND28BVsgNuqp9jGh2miD1wnMY8l1wme5qhP
 y7CysyD6je7IfAIXehYA66BMEjI3b4Ydj1IA1K+3RCRbfXB1zWfYYpUm+Y9Hmg2nFUIN+0/9Q
 LrWbkqOVPyJPMJP4COOk9iY+xExKqmDNwWSfDxf75y8QpcNI5EZuua13jO3XNtM5JVKgZsZ6t
 q2AEymeMXEYuUQSPwU0uEHEQk6RSr2c0qZ5WnFEs40hhM5/N5wD7zm2VjCk5tp8/od5Huo+WV
 dtYD15mj7dXlBGoMjFRi5ZX7XVcKsJONwiftX1G49OnnRZKh6F+w2SZfsheBbjJbEk2JvONuG
 wtp51SCYrgMXb8f2ugvMiQ/p/Ll4PpFBk6+M3sBhqjX0P4qHSHCpdMI8ehZ73Nd16t1skPSJ4
 06FEfHPvs0UXqebYeLFDoH1aL9nKJ7vnZ5nLuuM/5F4ur8aWejdq4I5GIz5XL3sTC1lwUo61L
 x+8vC8s

This is a test.
```

The diff of the two emails looks like this:

```
[11:04:38] fiedl@fiedl-mbp: ~/rails/smtp_envelope_send_test master
➜  diff email1.eml email2.eml

12c12
< 	by ___-___-___-___.example.com (Postfix) with ESMTPS id 270EE2183C3E
---
> 	by ___-___-___-___.example.com (Postfix) with ESMTPS id 9CF9D2183C3E
15,17c15,17
<  mrelayeu.example.com (mreue103) with ESMTPSA (Nemesis) id
<  0M7VWZ-1bBDh91xrT-00xIKv; Tue, 19 Jul 2016 10:58:16 +0200
< Date: Tue, 19 Jul 2016 10:58:15 +0200
---
>  mrelayeu.example.com (mreue101) with ESMTPSA (Nemesis) id
>  0MN3u4-1bRdmS3cls-006dqK; Tue, 19 Jul 2016 10:58:16 +0200
> Date: Tue, 19 Jul 2016 10:58:16 +0200
21c21
< Message-ID: <578deba7d7421_a9963fc03d03f9e8688c7@fiedl-mbp.mail>
---
> Message-ID: <578deba89a17a_a9963fc03d03f9e86894d@fiedl-mbp.mail>
27,44c27,44
< smtp-envelope-to: test1@example.com
< X-Provags-ID: V03:K0:nvhwlurRx2RI8la2V+he9CtlBKkJBfut8sIucnc8lmqPSduo/mk
<  HjJVD08b5yagLNOdz3CEXCgmXqvqRPi05L4SveJyyRZwG3sJmvRS+6LAtaab5fABSEhZ/Nf
<  CYiW5FPoZsq1tc6SrvLt7Fu5hhZi0WH+4eZdBTkzpDXCTP6oImYn2IFPrCM8UflcoUnw+Po
<  zqOX/YqA7dIZm3Lf2O22Q==
< X-UI-Out-Filterresults: notjunk:1;V01:K0:we1aQuAx2Rk=:CdypLd5tBaiK6kCROKcE3p
<  JVC7TW1oy1a0qWhSwbSkZQl5+DxUSjRR75wyOnnmNWpg5OnIeuKVUftb+Itfab+3ZXYMKWXBR
<  ETTcQxfcPBxQ2a80Hy6gfjCpzOn1sE4RlRKOo5k0lKUOGVmDbxzdQvHzIkkiCCiqgeMYdN+BC
<  rFSIKLif3eZIp+I8JriIU5FaIYMJQnpQtxh80B4aqFBpd7adSr4OXSJTqaLiGqAnReB8dYVys
<  hpYIlK8727kYep2lKXlNYw+lXkCa/n4bMlRGA6ccUnWV2vOjJfUfvflpok3dC4C31MY0wJu5J
<  +CoF6rq1Alk9628ifI24toHTYPtIPmOKfJ+PQ8ND28BVsgNuqp9jGh2miD1wnMY8l1wme5qhP
<  y7CysyD6je7IfAIXehYA66BMEjI3b4Ydj1IA1K+3RCRbfXB1zWfYYpUm+Y9Hmg2nFUIN+0/9Q
<  LrWbkqOVPyJPMJP4COOk9iY+xExKqmDNwWSfDxf75y8QpcNI5EZuua13jO3XNtM5JVKgZsZ6t
<  q2AEymeMXEYuUQSPwU0uEHEQk6RSr2c0qZ5WnFEs40hhM5/N5wD7zm2VjCk5tp8/od5Huo+WV
<  dtYD15mj7dXlBGoMjFRi5ZX7XVcKsJONwiftX1G49OnnRZKh6F+w2SZfsheBbjJbEk2JvONuG
<  wtp51SCYrgMXb8f2ugvMiQ/p/Ll4PpFBk6+M3sBhqjX0P4qHSHCpdMI8ehZ73Nd16t1skPSJ4
<  06FEfHPvs0UXqebYeLFDoH1aL9nKJ7vnZ5nLuuM/5F4ur8aWejdq4I5GIz5XL3sTC1lwUo61L
<  x+8vC8s
---
> smtp-envelope-to: test2@example.com
> X-Provags-ID: V03:K0:CnOvJbUlUjrvfpLUQlQD+WWqULK9kYY4JlzlWMEL4ki8GSOm1lt
>  SFjNbzHj16BtuhZd7Nt+iHX6Pburh6JaB4++efOmzQYcnjb+AjfHsf6ssXd5BSQeh2xANw3
>  UKOkp4zQ4qPHFei10iqhIyYuv7SOTLDvCBBU3TWj5GxobRbqqkNXUrEz4czRqRbJnPHtrkO
>  0jq4+yZ0pFyzmq18xJJjw==
> X-UI-Out-Filterresults: notjunk:1;V01:K0:vTPyxBUKV3w=:AqYvibVEXQ03Em3RUFZkYp
>  z9g2usEw+vvVHpP0em+FVGeieFP2tEuDkuIzsd/+nRUqDc3pJrsDJei7lYYwOv5UozgLkSvNz
>  LeckIfEKlpvpKNjcygEFkSyMtPxCs7+CoLK9cHZiZCWspDp167OLw6NwdynH3+BeaLECmGLP3
>  bNWenjOkp7shXnCXEoAWErjj9FsWfyXvWVnoh0gR2zJyqj8gupaaRSWlc5vNh1cB02uE8lbGY
>  AzP4Yidp7Aza7CgZx+FoEDpiXUaNC+Wjk8hgKEqdkLAlULWPgbmvky2LhzCfNZa04DYG6sHcN
>  gjI3ygdeqNcdds42BL12Qwj5qzEazJ0WZGAsFzHLleg3IvTKTvTsgwFdaBuvehGTLij2a9ODT
>  L7auCK7KHklYu46kYHRQ+Fhheof4JQwBNyJS2+xekGVUv66t3sNQ7vSdpjJ+DvybYwu23y04C
>  Tk21YPzTujzkM2PNB/QV/EcuuC/5vR/RSqS+rX5eRDmIe1SKUbIahW5rNYre+AhQfk3MwuHoR
>  npEgfZH0OoKeOsMmBqEpymLYM3oJQ/H1SJ3UOZq2ho57I5rUX9/6Qotn5oU7WojmOz9ODhawo
>  Z6QjPZ3rSMC12nyjAcai4wk7y69zB3Z3hpfMamyR7KKmTaaUNN6hRX3dbXUrgHGBZXl5iXsKl
>  AFQboGGAYgHqtn8jBOHOvsxcOdht9sNe9/F0XFOFnPt9+4wUMGwvAusIjrJkaDN43+rrXKojt
>  sITRdkWfknUJJh5q3Iorjf8w2V+wounqxaq/ROBPhX0+Qaw908Br80cJUPh/9ZLfng3CZQLUT
>  PIGyXyx
```

As one can see, the first email has `smtp-envelope-to: test1@example.com` in its header, the second one `smtp-envelope-to: test2@example.com`.

Be aware that the header field `smtp-envelope-to` is just a copy of the real smtp envelope field. The mail servers do not look at the header fields but at the real smtp envelope.

## Workaround

When using the `Mail::Message#smtp_envelope_to=` setter, only one email is received by each of the recipients.

```ruby
# lib/tasks/emails.rake

task :emails => [:environment] do
  recipients = ENV['RECIPIENTS'].split(",")

  recipients.each do |recipient|
    mail = TestMailer.test_mail(to: recipients, smtp_envelope_to: recipient)
    mail.smtp_envelope_to = recipient if ENV['USE_SMTP_ENVELOPE_TO_SETTER']
    log_mail(mail, recipient)
    mail.deliver
  end
end
```

Send like this:

```bash
cd ~/rails/smtp_envelope_send_test
bin/rake emails RECIPIENTS=test1@example.com,test2@example.com USE_SMTP_ENVELOPE_TO_SETTER=true
```

## How do *rails* and *mail* interact?

The `mail` method used in the `TestMailer` is defined [here, `ActionMailer::Base#mail` ](https://github.com/rails/rails/blob/4-2-stable/actionmailer/lib/action_mailer/base.rb#L800).

As one can see there, the `smtp_envelope_to` is passed to the `Mail::Message` object like this:

```ruby
def mail(headers = {}, &block)
  # ...
  m = @_message
  headers.except(...).each { |k, v| m[k] = v }
end
```

The `smtp_envelope_to` value is passed using `[]=`.

The [documentation of `Mail::Message`](https://github.com/mikel/mail/blob/master/lib/mail/message.rb) reads:

>        ===Making an email via assignment
>
>        You can assign values to a mail object via four approaches:
>
>        * Message#field_name=(value)
>        * Message#field_name(value)
>        * Message#['field_name']=(value)
>        * Message#[:field_name]=(value)
>
>        Examples:
>
>         mail = Mail.new
>         mail['from'] = 'mikel@test.lindsaar.net'
>         mail[:to]    = 'you@test.lindsaar.net'
>         mail.subject 'This is a test email'
>         mail.body    = 'This is a body'
>
>         mail.to_s #=> "From: mikel@test.lindsaar.net\r\nTo: you@...

[The `[]=` method](https://github.com/mikel/mail/blob/master/lib/mail/message.rb#L1306) just sets the header field, but does not pass it to `#smtp_envelope_to=`.

```ruby
# mikel/mail: lib/mail/message.rb

    def []=(name, value)
      if name.to_s == 'body'
        self.body = value
      elsif name.to_s =~ /content[-_]type/i
        header[name] = value
      elsif name.to_s == 'charset'
        self.charset = value
      else
        header[name] = value
      end
    end

    def smtp_envelope_to=( val )
      @smtp_envelope_to =
        case val
        when Array, NilClass
          val
        else
          [val]
        end
    end
```

Therefore, `mail[:smtp_envelope_to] = ...` and `mail.smtp_envelope_to = ...` are not equivalent, which explains the observed behavior.

## Is this a bug?

The parameter of `def mail(headers = {}, &block)` is called "`headers`". In fact, the `smtp-envelope-to` header is set correctly, as seen in the results section above. Thus, the method does what can be expected from the definition.

Nevertheless, the smtp envelope itself is not set.

Considering that the `mail` parameter in Rails is called "`headers`" and that the `Mail::Message#smtp_envelope_to=` and `Mail::Message#[:smtp_envelope_to]=` are not equivalent, I'd tend to try to resolve this in [mail](https://github.com/mikel/mail) rather than in [rails](https://github.com/rails/rails).

To discuss whether this is considered a bug, see this issue:
https://github.com/mikel/mail/issues/1015

In the meantime, as a [workaround](#workaround), the `Mail::Message#smtp_envelope_to=` setter can be used manually:

```ruby
recipients.each do |recipient|
  mail = TestMailer.test_mail(to: recipients, smtp_envelope_to: recipient)
  mail.smtp_envelope_to = recipient
  mail.deliver
end
```