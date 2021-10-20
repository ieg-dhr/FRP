require 'pry'

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

  objekt = JSON.parse(File.read("_raw_data/objekt.json"))
  ort = JSON.parse(File.read("_raw_data/ort.json"))
  gebaeude = JSON.parse(File.read("_raw_data/gebaeude.json"))
  verwalter = JSON.parse(File.read("_raw_data/verwalter.json"))
  person = JSON.parse(File.read("_raw_data/person.json"))
  inhalt = JSON.parse(File.read("_raw_data/inhalt.json"))

  ids = {}
  types.each do |type|
    data = JSON.parse(File.read("_raw_data/#{type}.json"))

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

    binding.pry if record['id'] == '658'
  end

  # inhalt.each do ||
end
