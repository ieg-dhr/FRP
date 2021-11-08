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

def ext_map(url)
  base = url.split('/').last
  parts = base.split('.')
  ext = (parts.size > 1 ? parts.last : nil) || 'jpg'

  h = hash_for(url)

  # force jpg format for these
  ext = 'jpg' if [
    '0ddd11da4e961a5'
  ].include?(h)

  # force png format for these
  ext = 'png' if [
    '9e48d6ab64ce34f',
    '24f4223b9f1c250',
    '9e48d6ab64ce34f',
    '78b71077c71bd41',
    '39aa1421587a67c',
    '12a0b97b93ea369'
  ].include?(h)

  # force gif format for these
  ext = 'gif' if [
    'eb5f88326331d50'
  ].include?(h)

  ext = 'pdf' if [
    '9ecb09a9c50200a',
    'e853942da0f4294'
  ].include?(h)

  ext
end

def no_image?(h)
  return [
    '272146aef84cbfa',
    '847b22e43b21c3e',
    'a52aea8f9141050',
    '098de2dc4b75eb7',
    'da2b125b9154a76',
    '93861d79aa25557',
    'c4592bde2140b64',
    '9c2c16708061e27',
    '4a734a3b81a88ad',
    '9f9fe0848e95004',
    'cf99726c75ba79b'
  ].include?(h)
end
