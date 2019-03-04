require 'dotenv/load'
require_relative './lib/twitch.rb'



TWITCH_USER       = ENV.fetch('TWITCH_USER')
TWITCH_CHANNEL    = ENV.fetch('TWITCH_CHANNEL')
TWITCH_CHAT_TOKEN = ENV.fetch('TWITCH_CHAT_TOKEN')



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
