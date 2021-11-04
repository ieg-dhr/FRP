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
  result = if ENV['HEADLESS_SCRAPING'] == 'true'
    opts = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    Selenium::WebDriver.for :firefox, options: opts
  else
    Selenium::WebDriver.for :firefox  
  end

  result.manage.timeouts.implicit_wait = 5.0

  result
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

def find_field(element, label)
  label = element.all(:xpath, "//label[contains(text(), '#{label}')]").first
  id = label['for']
  element.all(:xpath, "//*[@id='#{id}']").first
end

def blank?(text)
  return true unless text
  return !!text unless text.is_a?(String)

  text.match?(/\A[\s\n]*\Z/)
end

def present?(text)
  !blank?(text)
end

def sign_in(client)
  client.navigate.to "#{ENV['UPSTREAM_URL']}/user/login"
  find_field(client, 'Username').send_keys ENV['UPSTREAM_USERNAME']
  find_field(client, 'Password').send_keys ENV['UPSTREAM_PASSWORD']
  client.all(:css, '#edit-submit').first.click
end
