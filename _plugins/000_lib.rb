require 'dotenv/load'

require 'pry'
require 'selenium-webdriver'
require 'digest'

def hash_for(url)
  out = url.gsub ' ', '%20'
  r = Digest::SHA2.hexdigest(out)[0..14]
  bindnig.pry if r.match?('-')
  r
end

def make_client
  if ENV['HEADLESS_SCRAPING'] == 'true'
    opts = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    Selenium::WebDriver.for :firefox, options: opts
  else
    Selenium::WebDriver.for :firefox  
  end  
end

def wait_for_stale(element)
  50.times do
    element.tag_name
    sleep 0.2
  end

  raise "didn't turn stale!"
rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
  sleep 0.2
  true
end