# encoding: utf-8

require 'yaml'
require 'logger'
require 'tweetstream'

require_relative 'text_processor'

class TwitterWrapper
  attr_reader :client, :stream

  # @param [Logger] logger logger instance
  def initialize(logger)
    @logger = logger
    @client = Twitter::Client.new(
      consumer_key:       ENV['TWITTER_CONSUMER_KEY'],
      consumer_secret:    ENV['TWITTER_CONSUMER_SECRET'],
      oauth_token:        ENV['TWITTER_ACCESS_TOKEN'],
      oauth_token_secret: ENV['TWITTER_ACCESS_TOKEN_SECRET'],
    )
    @profile = @client.verify_credentials

    TweetStream.configure do |config|
      config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
      config.oauth_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.oauth_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      config.auth_method        = :oauth
    end

    @stream = TweetStream::Client.new

    @stream.on_error do |e|
      @logger.error(e)
    end

    @stream.on_inited do
      @logger.info('client init')
    end
  end

  # user id is me?
  #
  # @param [Fixnum] id user id
  def me?(id)
    id == @profile.id
  end

  # tweet update! say daisuki
  # @param [String] daisukidayo daisuki message 
  # @param [Fixnum] id reply user id
  def tweet_update(daisukidayo, id = nil)
    option = {}
    option[:in_reply_to_status_id] = id if id
    @client.update(daisukidayo, option)
  end

  # exclude tweet
  # @return [Boolean] true is exclude status
  def exclude_tweet?(status)
    return true if me?(status[:user][:id])
    return true if status.retweet?
    return true if status.reply?
    return false
  end
end

class KanojoBot

  def initialize
    STDOUT.sync = true

    @logger    = Logger.new(STDOUT)
    @twitter   = TwitterWrapper.new(@logger)
    @processor = TextProcessor.new

    @twitter.tweet_update(@processor.wakeup_message(Time.now))
  end

  # running kanojo!
  def run
    @logger.debug 'run!'
    @twitter.stream.userstream do |status|
      @logger.debug(status)
      next if @twitter.exclude_tweet?(status)

      daisukidayo = @processor.call_to_user(status.from_user, status.text)

      next if daisukidayo.nil?

      @logger.info("tweeted: #{daisukidayo}")
      @twitter.tweet_update(daisukidayo, status.id)
    end
  end

  def self.daisuki
    self.new.run
  end
end


