# coding: utf-8

require 'logger'

require_relative 'text_processor'
require_relative 'twitter_wrapper'

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
    @twitter.userstream do |status|
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


