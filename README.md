# Twitch Chat Bot


## Config

You'll need an OAuth token, and you can get one [here](https://twitchapps.com/tmi/).


## Usage

```ruby
### example/main.rb ###

TWITCH_USER       = ENV.fetch('TWITCH_USER')       # 'user'
TWITCH_CHANNEL    = ENV.fetch('TWITCH_CHANNEL')    # 'user'
TWITCH_CHAT_TOKEN = ENV.fetch('TWITCH_CHAT_TOKEN') # 'oauth:1234abcd'


bot = Twitch::Bot.new(
  user:     TWITCH_USER,
  token:    TWITCH_CHAT_TOKEN,
  channel:  TWITCH_CHANNEL,
)

bot.connect do
  command(:echo) do |text|
    respond text
  end
end
```


## Heroku Example

This repo can be deployed directly to Heroku:

```
$ heroku create your-app-name
$ heroku config:set \
    TWITCH_USER='user' \
    TWITCH_CHANNEL='channel' \
    TWITCH_CHAT_TOKEN='oauth:1234abcd'
$ git push heroku master
$ heroku ps:scale bot=1
```
