# checks data for
# * missing or duplicate ids
# * missing or ambiguous related entity: Verwalter (Ort)
# * missing or ambiguous related entity: Verwalter (Ort) dupl.
# * missing or ambiguous related entity: Verwalter (Name)
# * missing or ambiguous related entity: Verwalter (Name dupl.)
# * missing or ambiguous related entity: Herstellungsort
# * missing or ambiguous related entity: Herstellername
# * missing images: not retrievable from urls in 'Bild-URL' and 'Bearbeitetes Bild URL'

Jekyll::Hooks.register :site, :after_init do |site|
  puts 'checking data integrity ...'

  types = [
    'objekt',
    'gebaeude',
    'ereignis',
    'fotobestellung',
    'inhalt',
    'motiv',
    'person',
    'ort',
    'verwalter'
  ]

  objekt = JSON.parse(File.read("data/objekt.json"))
  ort = JSON.parse(File.read("data/ort.json"))
  gebaeude = JSON.parse(File.read("data/gebaeude.json"))
  verwalter = JSON.parse(File.read("data/verwalter.json"))
  person = JSON.parse(File.read("data/person.json"))
  inhalt = JSON.parse(File.read("data/inhalt.json"))

  ids = {}
  types.each do |type|
    data = JSON.parse(File.read("data/#{type}.json"))

    data.each do |record|
      unless record['id']
        puts "NO ID (#{type}): #{record.inspect}"
        next
      end

      if ids[record['id']]
        puts "DUPLICATE (#{type}): #{record['id']}"
        next
      end

      ids[record['id']] = true
    end
  end

  objekt.each do |record|
    (record['Verwalter (Ort)'] || '').split("\n").each do |o|
      related = ort.find{|e| e['Ortsname'] == o}
      binding.pry unless related
    end

    (record['Verwalter (Ort) dupl.'] || '').split("\n").each do |o|
      related = ort.find{|e| e['Ortsname'] == o}
      # some locations are just strings
    end

    (record['Verwalter (Name)'] || '').split("\n").each do |o|
      related = verwalter.find{|e| e['Verwalter (Bezeichnung)'] == o}
      binding.pry unless related
    end

    (record['Verwalter (Name) dupl.'] || '').split("\n").each do |o|
      related = verwalter.find{|e| e['Verwalter (Bezeichnung)'] == o}
      binding.pry unless related
    end

    (record['Herstellungsort'] || '').split("\n").each do |o|
      related = ort.find{|e| e['Ortsname'] == o}
      binding.pry unless related
    end

    (record['Herstellername'] || '').split("\n").each do |o|
      related = person.find{|e| e['name'] == o}
      # some locations are just strings
    end

    urls = 
      (record['Bild-URL'] || '').split("\n") + 
      (record['Bearbeitetes Bild URL'] || '').split("\n")
    hashes = record['W-Image'] || []
    puts "MISSING IMAGE: record id #{record['id']}: #{urls.size} urls vs #{hashes.size} downloaded" unless urls.size == hashes.size

    if record['Objekt in Ausstellung'] == 'Virtuelle Ausstellung'
      if blank?(record['Pr??sentationsgruppe'])
        puts "NO EXHIBITION CATEGORY ASSIGNED: #{record['id']}"
      end
      if record['Pr??sentationsgruppe'] != 'Intro'
        if blank?(record['exhibition_text'])
          puts "NO EXHIBITION TEXT FOUND: #{record['id']}"
        end
      end
    end

    # binding.pry if record['id'] == '658'
  end
end
