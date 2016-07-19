# SmtpEnvelopeSendTest

This is a rails-4.2.7-test application for experiments with the smtp-envelope-to header.

## Preparation

Make sure to set the smtp settings in the `secrets.yml`.

```yaml
# config/secrets.yml

development:
  smtp_address: '...'
  smtp_user: '...'
  smtp_password: '...'
  smtp_domain: '...'

```