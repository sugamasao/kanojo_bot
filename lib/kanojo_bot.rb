# coding: utf-8

require 'date'
require 'logger'

require_relative 'text_processor'
require_relative 'twitter_wrapper'

class KanojoBot

  def initialize(debug)
    STDOUT.sync = true

    @debug     = debug
    @logger    = Logger.new(STDOUT)
    @twitter   = TwitterWrapper.new(@logger, @debug)
    @processor = TextProcessor.new
  end

  # running kanojo!
  def run
    @logger.info 'wakeup!'
    @twitter.tweet_update(@processor.wakeup_message(Time.now))
    @twitter.tweet_update(@processor.event_message(Date.today)) if @processor.has_event?(Date.today)

    @logger.info '[stream] start!'
    begin
      @twitter.userstream do |status|
        @logger.debug("[stream] status: #{status}") if @debug

        next if @twitter.exclude_tweet?(status)
        next if ignore?

        daisukidayo = @processor.call_to_user(status.from_user, status.text)

        next if daisukidayo.nil?

        @logger.info("[stream] daisukidayo: #{daisukidayo}")
        @twitter.tweet_update(daisukidayo, status.id)
      end
    rescue => e
      @logger.error("[stream] message=#{e.message}, class=#{e.class}, backtrace=#{e.backtrace}")
      retry
    end
  end

  # ツイートに反応するのは3回に1回ていど
  def ignore?
    rand(3) == 0
  end

  def self.daisuki(debug = false)
    self.new(debug).run
  end
end

