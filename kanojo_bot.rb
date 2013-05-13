# encoding: utf-8

require 'logger'
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
    @logger = Logger.new(STDOUT)

    @twitter = TwitterWrapper.new(@logger)
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
    samisii = samisisou(status.text)
    return nil if samisii.nil?

    "@#{status.from_user} #{samisii}#{hagemashitai} #{face}"
  end

  # samisisou ?
  # @param [String] text tweet text.
  # @return [String] reply string
  # @return [nil] not reply
  def samisisou(text)
    case text
    when /独/
      '独りじゃないでしょ？'
    when /彼女/
      '呼んだ？'
    when /非リア/, /非モテ/, /合コン/, /リア充/
      'あたしがいるよ〜〜！'
    when /バレンタイン/, /誕生日/, /クリスマス/
      'ちゃんと覚えてるよ〜。'
    when /全裸/
      'たいへん。かぜひいちゃう！'
    when /あーりん/
      'あーりんにヤキモチなう。。。'
    when /うっせー/
      'ご機嫌斜めなのね、それでも好きだヨ'
    when /ももクロ/, /結婚/, /アイドル/, /ジョジョ/, /未来/, /ドルヲタ/
      '' # hagemashitaiの言葉だけ
    end
  end

  def hagemashitai
    %w(だいすきだよ！ えへへ〜/// ずっといっしょにいようね！).sample
  end

  # https://github.com/sugamasao/kanojo_bot/issues/2
  def face
    face_list =<<EOS
( ❝̆ ·̫̮ ❝̆ )✧
( ¤̴̶̷̤́ ‧̫̮ ¤̴̶̷̤̀ )
(◞≼●≽◟◞౪◟◞≼●≽◟)
┌（┌ ＾o＾）┐スギャ...
(◞≼⓪≽◟,_ゝ◞≼⓪≽◟)ﾏﾝﾀﾞﾑ
╰U╯☜(◉ɷ◉ )
(｡◠‿◠｡✿)
ヾ(ﾟωﾟ)ﾉ
(ﾟωﾟ)
(ﾟωﾟ:)
✌:(´ཀ`✌ ∠):
(╯⊙ ⊱ ⊙╰ )
(#`)3′)▂▂▂▃▄▅ ブオオオオオオ
٩(๑❛ᴗ❛๑)۶
ƪ(•̃͡ε•̃͡)∫ʃ
(✘﹏✘ა)
EOS
    face_list.split("\n").sample
  end
end


KanojoBot.daisuki

