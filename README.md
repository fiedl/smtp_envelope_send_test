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

