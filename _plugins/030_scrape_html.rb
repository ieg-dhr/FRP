Jekyll::Hooks.register :site, :after_init do |site|
  puts "scraping html from wisski objekt pages ... "

  target = "_raw_data/objekt.html.json"
  unless File.exists?(target)
    data = JSON.parse(File.read '_raw_data/objekt.json')
    client = make_client

    data.each_with_index do |record, i|
      client.navigate.to "#{ENV['UPSTREAM_URL']}/wisski/navigate/#{record['id']}/view"

      client.all(:css, '.field--name-fafca0b186007f0af55dce0c5bbbedb9').each do |k|
        record['Kommentar-html'] = k['innerHTML']
      end

      puts "#{i}/#{data.size}"
    end

    File.open target, 'w+' do |f|
      f.puts JSON.pretty_generate(data)
    end
  end
end
