# Telegram to Discord both

:warning: This is a quick hack, as it's not presently possible to have bots talking with each others
through Telegram bot API. 

This scripts relies on running a Dockerized [tg](https://github.com/vysheng/tg) and doing some fugly parsing to extract 
the right messages. 

## Usage

```
ruby forward.rb DISCORD_BOT_TOKEN DISCORD_CHANNEL_ID
```

From there: 

- wait a few seconds, the script should stop outputting anything
- enter your phone in the following format `336XXX...`
- wait until you receive the authentication code on your phone
- enter the authentication code
- let it live


## Todo 

- [] Enable to select the username to be forwarded
- [] Move ruby script inside the docker image

## Notes

If we continue to need this, we'd better study https://telegram.org/apps#source-code and get things done
directly rather than doing this crap.
