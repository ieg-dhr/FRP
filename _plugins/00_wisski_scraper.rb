require 'pry'
require 'selenium-webdriver'
require 'digest'

jobs = {
  'ereignis' => 'b0b3d5c18f9c38cf9655078cb0bfffe6',
  'motiv' => 'b86a7fe89da3031b6c7cc8227b8d87cb',
  'gebaeude' => 'bd824e05796c3b2f8db5d1167fda59dd',
  'fotobestellung' => 'b66c59a4ba3bfcf0699eb081f643d5a0',
  'inhalt' => 'bd0ad85d551efca5a6dcfd6d1de42df9',
  'objekt' => 'b58a655f471f731aa3027e53e517725f',
  'ort' => 'b4711691d621d7794fd72af6286c19d6',
  'person' => 'b10b510daf42e0a36209527dbc75e5c0',
  'verwalter' => 'bf0bab5072899ae2aa7c949a6e35903a'
}

Jekyll::Hooks.register :site, :after_init do |site|
  puts "scraping data from wisski web interface ... "

  jobs.each do |name, job_id|
    file = "_raw_data/upstream_ids/#{name}_ids.json"

    unless File.exists?(file)
      data = []
      counter = 1

      client = make_client
      client.navigate.to "#{ENV['UPSTREAM_URL']}/wisski_views/#{job_id}"

      loop do
        container = client.all(:css, ".item-list, .views-table").first
        links = container.all(:css, "a[href$='view']")
        names = links.map{|a| a.text.strip}
        ids = links.map{|a| a['href'].split('/')[-2]}

        names.each_with_index do |n, i|
          data << {
            'name' => n,
            'id' => ids[i],
            'page' => counter
          }
        end

        button = client.all(:css, '[rel=next]').first
        break unless button

        button.click
        wait_for_stale(container)

        counter += 1
      end

      client.close

      File.open file, 'w+' do |f|
        f.puts JSON.pretty_generate(data)
      end
    end
  end

  # the excel data downloaded from upstream is difficult to use (shifted rows,
  # missing fields etc.), we therefore iterate all person ids and scrape the
  # information from upstream directly
  target = "_raw_data/person.json"
  unless File.exists?(target)
    data = JSON.parse(File.read '_raw_data/upstream_ids/person_ids.json')

    client = make_client

    data.each_with_index do |record, i|
      client.navigate.to "#{ENV['UPSTREAM_URL']}/wisski/navigate/#{record['id']}/view"

      # alternative names
      client.all(:css, '.field--name-f177e549a10aa88d225ef336ef0a639a').each do |f|
        values = f.all(:css, '.field__items > .field__item').map{|e| e.text.strip}
        record['Alternative Namen'] ||= []
        record['Alternative Namen'] += values
      end

      if f = client.all(:css, '.field--name-fb1eec48b85cb61785376cedfe7d1208')[0]
        record['Geburtsdatum'] = f.first(:css, '.field__item').text.strip
      end

      if f = client.all(:css, '.field--name-f21807ca0775aeec7f4cb7d1d63468ab')[0]
        record['Sterbedatum'] = f.first(:css, '.field__item').text.strip
      end

      if f = client.all(:css, '.field--name-ff80cc1948cde8b813d25cb03b3a62f9')[0]
        record['Funktion I Amt'] = f.first(:css, '.field__item').text.strip
      end

      if f = client.all(:css, '.field--name-f506bdb394e0fbf3a4387116f4ca87f7')[0]
        values = 
        record['Geburtsort'] = {
          'id' => f.first(:css, 'a')['href'].split('/')[-2],
          'name' => f.first(:css, 'a').text.strip
        }
      end

      if f = client.all(:css, '.field--name-f333b35af6768c6933d8a2aa6855c03a')[0]
        values = 
        record['Sterbeort'] = {
          'id' => f.first(:css, 'a')['href'].split('/')[-2],
          'name' => f.first(:css, 'a').text.strip
        }
      end

      if f = client.all(:css, 'h3')[0]
        if f.text == 'Objekte mit dieser Person'
          record['Objekte mit dieser Person'] = 
            f.first(:xpath, '..').
            all(:css, 'a').
            map{|e| e['href'].split('/')[-2]}
        end
      end

      if f = client.all(:css, '.field--name-fa358ebf520779f0cc9208b2a835dbc0')[0]
        record['Kommentar'] = f.first(:css, '.field__item').text.strip
      end

      if f = client.all(:css, '.field--name-f1aa6c1f9705866b3dee3a39879fa43e')[0]
        record['Gruppenmitglied'] = f.first(:css, '.field__item').text.strip
      end

      t = client.first(:css, 'main').text
      puts "NOT FOUND: #{record}" if t.match(/The requested page could not be found/)

      puts "#{i}/#{data.size}"
    end

    File.open target, 'w+' do |f|
      f.puts JSON.pretty_generate(data)
    end
  end
end
