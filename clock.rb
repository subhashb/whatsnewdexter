require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(2.minutes, 'Initiating Crawl...') { TwitterWorker.perform_async }
end
