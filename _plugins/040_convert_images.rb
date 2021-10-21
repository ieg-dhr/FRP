Jekyll::Hooks.register :site, :after_init do |site|
  puts "converting images ..."
  target = 'assets/images/thumbs'
  system 'mkdir', '-p', target

  data = JSON.parse(File.read("_raw_data/objekt.json"))
  data.each do |record|

    if bbu = record['Bearbeitetes Bild URL']
      bbu.split("\n").each do |u|
        h = hash_for(u)
        path = record['W-Image'].find{|p| p.match?(h)}
        file = "#{target}/#{h}.jpg"

        unless File.exists?(file)
          system 'magick', 'convert', path, file
        end
      end
    end

    if bu = record['Bild-URL']
      bu.split("\n").each do |u|
        h = hash_for(u)
        next unless record['W-Image']

        path = record['W-Image'].find{|p| p.match?(h)}
        next unless path

        file = "#{target}/#{h}.jpg"
        unless File.exists?(file)
          path << '[0]'
          system 'magick', 'convert', path, '-resize', '800x800>', file
        end
      end
    end
  end
end
