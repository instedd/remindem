# Remindem

## Setup

### Nuntium

Nuntium settings are stored under `config/nuntium.yml`. A template of the settings file is provided in `config/nuntium-sample.yml`. Rename (or copy) this file to 'nuntium.yml' and fill with your configuration. Settings are:

    url: host http://nuntium.instedd.org
    account: nuntium account name
    application: nuntium application name
    password: nuntium application password
    incoming_username: http interface user
    incoming_password: http interface password

At nuntium the application should be configured with HTTP POST interface, url `http://<HOST_AND_PORT>/receive_at` and user/password as specified in the incoming_username/incoming_password settings.

### Emails

It is required to setup the action mailer and config.action_mailer.default_url_options in order to properly send emails.

### Delayed jobs

Run delayed jobs via `rake jobs:work`.
