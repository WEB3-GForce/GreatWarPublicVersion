if ENV['RAILS_ENV'] != 'production'
  $redis = Redis.new(:host => 'localhost', :port => 6379)
else
  uri = URI.parse(ENV["REDISTOGO_URL"])
  $redis = Redis.new(:url => uri)
end
