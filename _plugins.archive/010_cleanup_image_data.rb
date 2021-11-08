Jekyll::Hooks.register :site, :after_init do |site|
  file = '_raw_data/objekt.json'
  data = JSON.parse(File.read file)

  html = JSON.parse(File.read '_raw_data/objekt.html.json')
  html_map = html.map{|r| [r['id'], r]}.to_h

  data.each do |record|
    images = []
    (record['Bild-URL'] || '').split("\n").each do |url|
      next if url.match?(/entity:node/)

      h = hash_for(url)

      next if no_image?(h)

      ext = ext_map(url)

      f = "_raw_data/images/original/#{h}.#{ext}"
      binding.pry unless File.exists?(f)

      images << {
        'url' => url,
        'hash' => h,
        'ext' => ext
      }
    end
    record['images'] = images

    images = []
    (record['Bearbeitetes Bild URL'] || '').split("\n").each do |url|
      h = hash_for(url)
      ext = ext_map(url)

      f = "_raw_data/images/original/#{h}.#{ext}"
      binding.pry unless File.exists?(f)

      images << {
        'url' => url,
        'hash' => h,
        'ext' => ext
      }
    end
    record['cropped'] = images

    if present?(ch = html_map[record['id']]['Kommentar-html'])
      record['comment_html'] = ch
    end
  end

  File.open file, 'w+' do |f|
    f.puts JSON.pretty_generate(data)
  end
end
