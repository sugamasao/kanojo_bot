# coding: utf-8

require 'pathname'
require 'yaml'

class TextProcessor
  # data directory
  DATA_DIR = Pathname.new(__FILE__).dirname.parent.join('data')

  # Read for yaml files.
  def initialize
    @face         = YAML.load(DATA_DIR.join('face.yaml').read)
    @hagemashitai = YAML.load(DATA_DIR.join('hagemashitai.yaml').read)
    @samishisou   = YAML.load(DATA_DIR.join('samishisou.yaml').read)
    @event        = YAML.load(DATA_DIR.join('event.yaml').read)
  end

  # Wakeup kanojo_bot message.
  # @param [Time] time wakeup time
  # @return [String] wake up message
  def wakeup_message(time)
    formated_time = time.strftime('%Yねん%mがつ%dにち %Hじ%Mふん%Sびょう')
    love_call = 'だい' * (rand * 10).to_i + 'すき' * (rand * 10).to_i
    "#{formated_time} きょうも すぎゃーん #{love_call} #{face}"
  end

  # Call to user for message
  # @param [String] user_name tweet for @user_name
  # @param [String] text original message
  # @return [String] message
  # @return [nil] not to do.
  def call_to_user(user_name, text)
    samishisou = samishisou(text)
    return nil if samishisou.nil?

    "@#{user_name} #{samishisou}#{hagemashitai} #{face}"
  end

  # Samishisou?
  # @param [String] text tweet text.
  # @return [String] reply string
  # @return [nil] not reply
  def samishisou(text)
    @samishisou.each do |match_word|
      match_word['word'].each do |word|
        return match_word['response'] if text =~ /#{word}/
      end
    end

    nil
  end

  # Hagemashi no message
  # @return [Strgin]
  def hagemashitai
    @hagemashitai.sample
  end

  # Face mark
  # @return [Strgin]
  def face
    @face.sample
  end

  def has_event?(date)
    @event.key?(date)
  end

  def event_message(date)
    @event[date]
  end
end
