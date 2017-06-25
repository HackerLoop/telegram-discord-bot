#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'uri'
require 'net/http'
require 'json'

if ARGV.length < 2
  puts "Usage: ruby forward.rb discord_bot_token dicord_channel_id"
  puts "once telegram stops to print stuff, enter your phone number"
  puts "like this 336XXX..., then wait until you receive the login code on telegram"
  puts "enter it and just wait for cryptoping to send stuff"
  puts "make sure you didn't mute it."

  exit(-1)
end

bot_token = ARGV[0]
channel_id = ARGV[1]


def post_on_discord(bot_token, channel_id, message)
  url = "https://discordapp.com/api/channels/#{channel_id}/messages"
  uri = URI(url)
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  request = Net::HTTP::Post.new(uri.path)

  request["Content-Type"] = 'application/json'
  request["Authorization"] = "Bot #{bot_token}"
  request.body = {content: message}.to_json

  https.request(request)
end

command = "docker run -i pataquets/telegram-cli /usr/bin/telegram-cli -C"

in_r, in_w = IO.pipe
out_r, out_w = IO.pipe
err_r, err_w = IO.pipe

in_w.sync = true

pid = spawn(
  command,
  in: in_r,
  out: out_w,
  err: err_w
)

Thread.new do
  multiline_started = false
  while message = out_r.gets
    puts message

    if !message.match(/\s*\[\d\d:\d\d\]\s/) && multiline_started
      post_on_discord(bot_token, channel_id, message)
      next
    end

    # Debug stuff to not have to wait for CryptoPing to send anything
    # if m = message.match(/\s+Robert ...\s+(.*)/)
    #   $stdout.puts "---------------"
    #   $stdout.puts message
    #   $stdout.puts m[1]
    #   $stdout.puts "---------------"
    #   multiline_started = true
    # else
    #   multiline_started = false
    # end

    if m = message.match(/\s+CryptoPing ...\s+(.*)/)
      multiline_started = true
      post_on_discord(bot_token, channel_id, m[1])
    else
      multiline_started = false
    end
  end
end

while input = $stdin.gets
  in_w.puts input
end

[in_r, out_w, err_w].each {|io| io.close }

Process.waitpid(pid)
