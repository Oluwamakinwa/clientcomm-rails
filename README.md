# ClientComm

[![CircleCI](https://circleci.com/gh/codeforamerica/clientcomm-rails.svg?style=svg)](https://circleci.com/gh/codeforamerica/clientcomm-rails)
[![Code Climate](https://codeclimate.com/github/codeforamerica/clientcomm-rails/badges/gpa.svg)](https://codeclimate.com/github/codeforamerica/clientcomm-rails)
[![Test Coverage](https://codeclimate.com/github/codeforamerica/clientcomm-rails/badges/coverage.svg)](https://codeclimate.com/github/codeforamerica/clientcomm-rails/coverage)

ClientComm facilitates better communication between clients and case managers to increase the number of clients who successfully complete supervision.

# Overview

5.1 million people are currently on probation or parole, and that number is projected to grow in the coming years as criminal justice reform continues to spread. Across the country, community supervision departments are managing greater numbers of people, with limited resources.  

Community supervision personnel are tasked with maintaining public safety while helping their large caseloads navigate the terms of their release. It is vital for case managers to have a reliable way to contact each client, and today, people on community supervision are more likely to have a cell phone than a landline, and more likely to read a text than a letter in the mail. 

### ClientComm allows case managers to efficiently communicate with their clients.

ClientComm lets case managers send clients text messages from their computers or mobile devices. The text messages are sent from one department-wide phone number, and are not attached to individual case managers’ phones. Conversations between manager and client are kept together even if the client changes phone numbers, and can be printed or exported to your case management system.

In early 2016, we launched ClientComm with Salt Lake County Criminal Justice Services, which was struggling with individuals cycling in and out of jail due to missed court appearances or court-ordered treatment. Probation and Pretrial case managers are using ClientComm to text hundreds of their clients on a daily basis. ClientComm allows case managers to cut down on time lost playing phone tag and leaving voicemails. In minutes, case managers can remind, and have their client confirm, they will be at their next court date, or attend their next treatment class.

Our internal results in Salt Lake County show lower Failure to Appear rates, and time saved for case managers. We are currently undergoing a Randomized Control Test on the effectiveness of ClientComm in collaboration with researchers from the University of Virginia. ClientComm is now a central part of Code for America's product work on [Safety and Justice](https://www.codeforamerica.org/focus-areas/safety-and-justice), and is expanding to new jurisdictions across the country.

# Contents
1. [Development Setup](#development-setup)
2. [Production Deploy](#production-deploy)
3. [Restoring the DB](#restoring-the-db)

# Development Setup/Run Locally
### Requirements
1. Install Ruby with your ruby version manager of choice, like [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://github.com/codeforamerica/howto/blob/master/Ruby.md)
2. Check the ruby version in `.ruby-version` and ensure you have it installed locally e.g. `rbenv install 2.4.1`
3. [Install Postgres](https://github.com/codeforamerica/howto/blob/master/PostgreSQL.md). If setting up [Postgres.app](https://postgresapp.com/), you will also need to add the binary to your path. e.g. Add to your `~/.bashrc`:
`export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"`

## Application Setup

1. Install [bundler](https://bundler.io/) (the [latest Heroku-compatible version](https://devcenter.heroku.com/articles/ruby-support#libraries)): `gem install bundler -v 1.15.2`
2. Install other requirements: `bundle install`

    If you installed Postgres.app, you may need to install the `pg` gem independently with this command:

    ```gem install pg -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config```
3. Create the databases: `rails db:create`
4. Apply the schema to the databases:
```
rails db:schema:load RAILS_ENV=development
rails db:schema:load RAILS_ENV=test
```
5. Install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)
6. Copy `.env.example` to `.env` and fill in the relevant values.
7. Start the server with `heroku local`. Take note of the port the server is running on, which may be set with the `PORT` variable in your `.env` file.

## Setting Up Twilio

1. Buy an SMS-capable phone number on [Twilio](https://www.twilio.com/).
2. Install [ngrok](https://ngrok.com/). If you are running [npm](https://www.npmjs.com/), install with `npm install -g ngrok`. Otherwise [download the binary](https://ngrok.com/download) and [create a symlink](https://gist.github.com/wosephjeber/aa174fb851dfe87e644e#creating-a-symlink-to-ngrok).
3. Start ngrok by entering `ngrok http 3000` in the terminal to start a tunnel (replace `3000` with the port your application will run on if necessary). You should see an ngrok url displayed, e.g. `https://e595b046.ngrok.io`.
4. When your Twilio number receives an sms message or phone call, it needs to know where to route it. ClientComm has endpoints to receive Twilio webhooks at, for example, `https://e595b046.ngrok.io/incoming/sms/` and `https://e595b046.ngrok.io/incoming/voice/`. Click on your phone number in [the Twilio web interface](https://www.twilio.com/console/phone-numbers/incoming) and enter the `incoming/sms/` URL (with your unique ngrok hostname) in the *A MESSAGE COMES IN* field, under *Messaging*, and the `incoming/voice/` URL (with your unique ngrok hostname) in the *A CALL COMES IN* field, under *Voice & Fax*.

## Testing

- [Phantom](http://phantomjs.org/) is required to run some of the feature tests. [Download](http://phantomjs.org/download.html) or install with [Homebrew](https://brew.sh/): `brew install phantomjs`
- [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/) is also required to run some of the feature tests. [Download](https://sites.google.com/a/chromium.org/chromedriver/downloads) or install with [Homebrew](https://brew.sh/): `brew cask install chromedriver`
- Test suite: `bin/rspec`. For more detailed logging use `LOUD_TESTS=true bin/rspec`.
- File-watcher: `bin/guard` when running will automatically run corresponding specs when a file is edited.

# Production Deploy

See [the production deploy README.](deploy/terraform/README.md)

## Contact

Lou Moore ( @loumoore )
