IDS = {}

def ensure_images(record)
  binding.pry if record['Bild-URL'] &&
                 record['Bearbeitetes Bild URL'] == record['Bild-URL']

  urls =
    (record['Bild-URL'] || '').split("\n") +
    (record['Bearbeitetes Bild URL'] || '').split("\n")

  urls.each do |u|
    next if u.match?(/^entity:node/)

    u.gsub! ' ', '%20'
    h = hash_for(u)
    ext = ext_map(u)

    # TODO: investigate if we can still get images for these
    next if [
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

    file = "_raw_data/images/original/#{h}.#{ext}"

    unless File.exists?(file)
      puts "downloading '#{u}' to #{file}"
      success = system 'curl', '-o', file, '-L', u
      system 'rm', '-f', file unless success
    end

    record['W-Image'] ||= []
    record['W-Image'] << file
  end
end

def match_ids(record, type)
  IDS[type] ||= JSON.parse(File.read "_raw_data/upstream_ids/#{type}_ids.json")

  results = case type
  when 'objekt' then match_objekt_ids(record)
  when 'ereignis'
    IDS[type].select{|e| e['name'] == record['Ereignis'].strip}
  when 'gebaeude'
    IDS[type].select{|e| e['name'] == record['Name'].strip}
  when 'fotobestellung'
    IDS[type].select do |e|
      sig =
        record['Inventarnummer/Signatur'] ||
        record['Inventarnummer/Signatur Duplikat']
      return unless sig

      e['name'] == sig.strip
    end
  when 'inhalt'
    titel = record['Titel']
    sig = record['Inv.nr./Signatur zugehöriges Objekt']
    v = "#{titel}, #{sig}"

    IDS[type].select do |e|
      e['name'] == v || e['name'] == titel
    end
  when 'motiv'
    IDS[type].select{|e| e['name'] == (record['Motiv'] || '').strip}
  when 'person'
    IDS[type].select{|e| e['name'] == (record['Name'] || '').strip}
  when 'ort'
    IDS[type].select{|e| e['name'] == (record['Ortsname'] || '').strip}
  when 'verwalter'
    name = record['Verwalter (Bezeichnung)']
    location = record['Verwalter (Ort)']
    v = "#{name}, #{location}"

    IDS[type].select{|e| e['name'] == v}
  else
    binding.pry
  end

  binding.pry unless results.size == 1

  if results.size == 1
    record['id'] = results.first['id']
    return
  end
end

def match_objekt_ids(record)
  results = IDS['objekt'].select do |e|
    v = (record['Titel/Incipit'] || '').strip.gsub('  ', ' ')
    e['name'] == v
  end

  if results.size > 1
    client = Selenium::WebDriver.for :firefox

    results.select! do |r|
      url = "#{ENV['UPSTREAM_URL']}/wisski/navigate/#{r['id']}/view"
      client.navigate.to url

      scraped = client.all(
          :css,
          '.field--name-f00b1ba81385cc949224d56d13cbbffc .field__item'
        ).
        map{|e| e.text.strip}.join("\n")

      record['Inventarnummer/Signatur'] == scraped
    end

    binding.pry if results.size != 1

    client.close
  end

  results
end

Jekyll::Hooks.register :site, :after_init do |site|
  puts "converting object data ... "
  
  system 'mkdir', '-p', "_raw_data/images/original/"

  types = [
    'objekt',
    'gebaeude',
    'ereignis',
    'fotobestellung',
    'inhalt',
    'motiv',
    # 'person', (done entirly with scraping)
    'ort',
    'verwalter'
  ]

  types.each do |type|
    target = "_raw_data/#{type}.json"
    next if File.exists?(target)

    source = "_raw_data/upstream_csv/#{type}.xlsx"
    next unless File.exists?(source)

    ods = Roo::Spreadsheet.open(source)
    s = ods.sheet(0)

    fields = s.row(1)[0..-1]
    data = []

    (2..s.last_row).each do |i|
      values = s.row(i)
      record = fields.zip(values).to_h.reject{|k, v| v.nil?}

      ensure_images(record)
      match_ids(record, type)

      data << record
    end

    File.open target, 'w' do |f|
      f.pretty_generate JSON.dump(data)
    end
  end
end
