Jekyll::Hooks.register :site, :after_init do |site|
  client = nil

  file = '_raw_data/objekt.json'
  data = JSON.parse(File.read file)

  # log in
  signed_in = false

  data.each do |record|
    next if present?(record['exhibition_text'])
    next if record['Präsentationsgruppe'] == 'Intro'

    if record['Objekt in Ausstellung'] == 'Virtuelle Ausstellung'

      unless signed_in
        client = make_client
        sign_in(client)
        signed_in = true
      end

      id = record['id']
      client.navigate.to "#{ENV['UPSTREAM_URL']}/wisski/navigate/#{id}/edit"

      table = client.find_element(:css, '#fe777d25634d5b9acd6e2e3f380cdbba-values')
      source_button = client.find_element(:css, '.cke_button__source')
      textarea = table.all(:css, 'textarea')[0]
      text = textarea['value']

      binding.pry if blank?(text)
      record['exhibition_text'] = text

      File.open file, 'w+' do |f|
        f.puts JSON.pretty_generate(data)
      end
    end
  end

  client.close if client
end
