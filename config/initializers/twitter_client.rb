

$twitter_client = Twitter::REST::Client.new do |config|
  credentials = YAML.load(File.read(Rails.root.to_s + '/config/twitter.yml'))
  config.consumer_key    = credentials["consumer_key"]
  config.consumer_secret = credentials["consumer_secret"]
  config.access_token        = credentials["access_token"]
  config.access_token_secret = credentials["access_token_secret"]
end
