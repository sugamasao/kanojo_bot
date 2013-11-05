# -*- coding: utf-8 -*-
require 'spec_helper'
require 'text_processor'

describe TextProcessor do
  let(:processor) { TextProcessor.new }
  let(:birthday) { Date.new(2013,12,10) }

  describe "#has_event?" do
    it { expect(processor).to have_event(birthday) }
  end

  describe "#event_message" do
    it { expect(processor.event_message(birthday)).to match(/誕生日/) }
  end
end
