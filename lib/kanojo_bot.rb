# coding: utf-8

require 'date'
require 'logger'

require_relative 'text_processor'
require_relative 'zatsudan_processor'
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
        @logger.debug("[stream] status: #{status.text}") if @debug

        next if @twitter.exclude_tweet?(status)
        next if gaman?

        daisukidayo = nil
        if rand(2) == 0
          @logger.debug('[stream] use Zatsudan API')
          daisukidayo = ZatsudanProcessor.new.create(status.text)
        else
          @logger.debug('[stream] use text processor')
          daisukidayo = @processor.create(status.text)
        end

        next if daisukidayo.nil?

        daisukidayo = "@#{status.user.screen_name} #{ daisukidayo }"

        @logger.info("[stream] daisukidayo: #{daisukidayo}")
        @twitter.tweet_update(daisukidayo, status.id)
      end
    rescue => e
      @logger.error("[stream] message=#{e.message}, class=#{e.class}, backtrace=#{e.backtrace}")
      retry
    end
  end

  # 2/3くらいのツイートは我慢する
  def gaman?
    rand(3) != 0
  end

  def self.daisuki(debug = false)
    new(debug).run
  end
end
