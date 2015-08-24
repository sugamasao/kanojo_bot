require 'docomoru'

class ZatsudanProcessor
  def create(text)
    client = Docomoru::Client.new(api_key: ENV['DOCOMO_API_KEY'])
    response = client.create_dialogue(text)
    if response.status == 200
      response.body['utt']
    end
  end
end
