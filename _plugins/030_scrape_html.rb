require 'pry'
require 'selenium-webdriver'

Jekyll::Hooks.register :site, :after_init do |site|
  puts "scraping html from wisski objekt pages ... "

  target = "_raw_data/objekt.html.json"
  unless File.exists?(target)
    data = JSON.parse(File.read '_raw_data/objekt.json')
    client = make_client

    data.each_with_index do |record, i|
      client.navigate.to "#{ENV['UPSTREAM_URL']}/wisski/navigate/#{record['id']}/view"

      binding.pry
    end
  end
end
