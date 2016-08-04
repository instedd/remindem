# Remindem

[![Build Status](https://travis-ci.org/instedd/remindem.svg?branch=master)](https://travis-ci.org/instedd/remindem)

Remindem is a free and easy-to-use tool that allows you to set up a list of tips, reminders, and advice that people can subscribe to via text messages. Remindem sends important text reminders just when your subscribers need them, based on a schedule you define.

## Setup

Remindem is a standard Ruby on Rails application, which uses MySQL as a database engine.

### Nuntium

Nuntium settings are stored under `config/nuntium.yml`. A template of the settings file is provided in `config/nuntium-sample.yml`. Rename (or copy) this file to 'nuntium.yml' and fill with your configuration. Settings are:

    url: host http://nuntium.instedd.org
    account: nuntium account name
    application: nuntium application name
    password: nuntium application password
    incoming_username: http interface user
    incoming_password: http interface password

At nuntium the application should be configured with HTTP POST interface, url `http://<HOST_AND_PORT>/receive_at` and user/password as specified in the incoming_username/incoming_password settings.

### Guisso

Remindem can use [Guisso](https://github.com/instedd/guisso) (Guisso unveils Instedd's Single Sign On) for managing user accounts. This is configured via a `config/guisso.yml` file, which can be generated from the Guisso's instance to be used; or refer to `guisso.yml.template` for an example.

### Hub

Remindem posts notifications of new subscribers and provides access to external actions in [InSTEDD Hub](https://github.com/instedd/hub) using [Hub Client](https://github.com/instedd/ruby-hub_client). To configure the client, add a `config/hub.yml` file with the following contents:

    enabled: true                   # Set to false to disable and not send notifications
    url: http://hub-stg.instedd.org # URL to the hub instance to be used
    connector_guid: CONNECTOR_GUID  # GUID of the Remindem connector in the hub
    token: SECRET_TOKEN             # Secret token used to report notifications


### Emails

It is required to setup the action mailer and config.action_mailer.default_url_options in order to properly send emails.

### Delayed jobs

Run delayed jobs via `rake jobs:work`.

## Development

### Docker development

`docker-compose.yml` file build a development environment mounting the current folder and running rails in development environment.

Run the following commands to have a stable development environment.

```
$ docker-compose run --rm --no-deps web bundle install
$ docker-compose up -d db
$ docker-compose run --rm web rake db:setup
$ docker-compose up
```

To setup and run test, once the web container is running:

```
$ docker-compose exec web bash
root@web_1 $ rake
```
