# encoding: utf-8

require 'logger'
require 'tweetstream'

class KanojoBot
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.debug('init')

    TweetStream.configure do |config|
      config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
      config.oauth_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.oauth_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      config.auth_method        = :oauth
    end

    @client = TweetStream::Client.new

    @client.on_error do |e|
      @logger.error(e)
    end

    @client.on_inited do
      @logger.info('client init')
    end
  end

  def samisisou(text)
    case text
    when /独/
      '独りじゃないでしょ？'
    when /彼女/
      '呼んだ？'
    when /非リア/, /非モテ/, /合コン/
      'あたしがいるじゃない。'
    when /バレンタイン/, /誕生日/, /クリスマス/
      'ちゃんと覚えてるよ〜。'
    when /全裸/
      'たいへん。かぜひいちゃう！'
    end
  end

  def daisukidayo
    %w(だいすきだよ！ えへへ〜/// いっしょにいようね！).sample
  end

  def run
    @client.userstream do |status|
      next if status.retweet?
      next if status.reply?

      samisii = samisisou(status.text)
      next if samisii.nil?

      daisukidayo = "#{samisii}#{hagemashitai}"
      @logger.info("tweeted: #{daisukidayo}")

      @client.update(daisukidayo, {
        in_reply_to_status_id: status.id
      })
    end
  end

  def self.daisuki
    self.new.run
  end
end


KanojoBot.daisuki

