# encoding: utf-8

require 'pathname'
require 'yaml'
require 'logger'
require 'tweetstream'

DATA_DIR = Pathname.new(__FILE__).dirname.join('data')

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

    @logger       = Logger.new(STDOUT)
    @face         = YAML.load(DATA_DIR.join('face.yaml').read)
    @hagemashitai = YAML.load(DATA_DIR.join('hagemashitai.yaml').read)
    @samishisou   = YAML.load(DATA_DIR.join('samishisou.yaml').read)
    @twitter      = TwitterWrapper.new(@logger)

    date = Time.now.strftime('%Yねん%mがつ%dにち %Hじ%Mふん%Sびょう')
    @twitter.tweet_update("#{date} きょうも すぎゃーん だいすき #{face}")
  end

  # running kanojo!
  def run
    @logger.debug 'run!'
    @twitter.stream.userstream do |status|
      @logger.debug(status)
      next if @twitter.exclude_tweet?(status)

      daisukidayo = create_message(status)
      next if daisukidayo.nil?

      @logger.info("tweeted: #{daisukidayo}")
      @twitter.tweet_update(daisukidayo, status.id)
    end
  end

  def self.daisuki
    self.new.run
  end

  private

  # create reply message 
  # @return [String] reply string
  # @return [nil] not reply
  def create_message(status)
    samishii = samishisou(status.text)
    return nil if samishii.nil?

    "@#{status.from_user} #{samishii}#{hagemashitai} #{face}"
  end

  # samishisou ?
  # @param [String] text tweet text.
  # @return [String] reply string
  # @return [nil] not reply
  def samishisou(text)
    @samishisou.each do |match_word|
      match_word["word"].each do |word|
        return match_word["response"] if text =~ /#{word}/
      end
    end
  end

  def hagemashitai
    @hagemashitai.sample
  end

  def face
    @face.sample
  end
end

KanojoBot.daisuki

