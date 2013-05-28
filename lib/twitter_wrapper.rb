# coding: utf-8

require 'tweetstream'

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

  def userstream
    @stream.userstream
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
