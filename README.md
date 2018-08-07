# Scrape pararius listings

This is an R app that allows the user to scrape a page of listings from [Pararius](https://www.pararius.nl/). The app is containerized using Docker.

## Installation instructions

To install & run the app, you need only install [docker](https://www.docker.com/). Then, go to the folder containing the `Dockerfile` and execute:

```bash
docker build . -t jhginn/pararius
```

## Configuration

Open up an empty file and call it `env.list` (this file is listed in `.gitignore`). Save it in the same folder as the `Dockerfile`. This file must contain the following entries:

```text
MAIL_HOST=<email-host>
MAIL_PORT=<email-port>
MAIL_USER=<email-address>
MAIL_PWD=<email-password>
```

For example, if you use Gmail, it should look like this:

```text
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=myemailaddress@gmail.com
MAIL_PWD=mypassword
```

If you do end up using Gmail, keep the following in mind:

- It is **a mistake**!! to use your own, private email address. The reason is that you must connect via SMTP (email/password) and you therefore have to turn of two-factor authentication. A better approach is to make a new email address and use that address with this app.
- Allow 'less secure apps' to access your email account by changing the setting found [here](https://myaccount.google.com/lesssecureapps).

## Running the app

You can run the application by executing:

```bash
docker run -v /PATH/TO/FOLDER/data:/root/data --env-file env.list jhginn/pararius
```

Where `/PATH/TO/FOLDER` is the absolute filepath of the folder containing the `Dockerfile`

## Cron job

It's a good idea to let the app check new listings with some regularity. To this end, simply schedule a cron job every 5-10 minutes:

```text
# Install this crontab file

# execute 'date' on your VM to see what time/date settings are
# <min> <hr> <day> <month> <weekday>

SHELL=/bin/bash

*/5 * * * * cd /PATH/TO/FOLDER/ && docker run -v /PATH/TO/FOLDER/data:/root/data --env-file env.list jhginn/pararius
```

## Debugging

You can enter a bash environment by executing the following:

```bash
docker run -v /PATH/TO/FOLDER/data:/root/data --env-file env.list -it --entrypoint /bin/bash jhginn/pararius
```
