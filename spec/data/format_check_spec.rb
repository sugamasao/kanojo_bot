require 'spec_helper'
require 'yaml'

describe 'YAML format' do
  let(:dir)  { File.expand_path('../../../data', __FILE__) }
  let(:samishisou)   { File.join(dir, 'samishisou.yaml') }

  shared_examples_for 'value is String instance' do |name|
    let(:dir)  { File.expand_path('../../../data', __FILE__) }
    let(:data) { File.join(dir, name) }

    it { YAML.load(File.read(data)).each { |f| expect(f).to be_an_instance_of(String) } }
  end

  describe 'face.yaml' do
    it_should_behave_like 'value is String instance', 'face.yaml'
  end

  describe 'hagemashitai.yaml' do
    it_should_behave_like 'value is String instance', 'hagemashitai.yaml'
  end

  describe 'samishisou.yaml' do
    it { expect { YAML.load(File.read(samishisou)) }.to_not raise_error }
  end
end
