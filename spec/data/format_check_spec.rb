require 'spec_helper'
require 'yaml'

describe 'YAML format' do
  let(:dir) { File.expand_path('../../../data', __FILE__) }
  let(:face)         { File.join(dir, 'face.yaml') }
  let(:hagemashitai) { File.join(dir, 'hagemashitai.yaml') }
  let(:samishisou)   { File.join(dir, 'samishisou.yaml') }

  it 'face.yaml' do
    expect { YAML.load(File.read(face)) }.to_not raise_error
  end

  it 'hagemashitai.yaml' do
    expect { YAML.load(File.read(hagemashitai)) }.to_not raise_error
  end

  it 'samishisou.yaml' do
    expect { YAML.load(File.read(samishisou)) }.to_not raise_error
  end
end
