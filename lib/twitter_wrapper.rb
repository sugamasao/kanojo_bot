# coding: utf-8

require 'tweetstream'
require 'twitter'

class TwitterWrapper
  attr_reader :client, :stream

  # @param [Logger] logger logger instance
  def initialize(logger, debug = false)
    @debug  = debug
    @logger = logger
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

    @profile = @client.user

    TweetStream.configure do |config|
      config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
      config.oauth_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.oauth_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      config.auth_method        = :oauth
    end

    @stream = TweetStream::Client.new

    @stream.on_error do |e|
      @logger.error("[client] #{e}")
    end

    @stream.on_inited do
      @logger.info("[client] inited")
    end
  end

  def userstream(&block)
    @stream.userstream(&block)
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
    if @debug
      @logger.debug("[client] Tweeted:#{daisukidayo}, Option:#{option}")
    else
      @client.update(daisukidayo, option)
    end
  end

  # exclude tweet
  # @return [Boolean] true is exclude status
  def exclude_tweet?(status)
    return true if me?(status[:user][:id])
    return true if status.retweet?
    return true if status.reply?
    false
  end
end
