Jekyll::Hooks.register :site, :after_init do |site|
  puts "converting images ..."
  mapping = [
    {'path' => 'data/images/thumbs', 'resize' => '480x480>', 'ext' => 'png'},
    {'path' => 'data/images/full', 'resize' => '1920x1920>', 'ext' => 'jpg'}
  ]

  mapping.each do |m|
    target = m['path']
    resize = m['resize']
    ext = m['ext']

    system 'mkdir', '-p', target

    data = JSON.parse(File.read("data/objekt.json"))
    data.each do |record|
      record['cropped'].each do |d|
        file = "#{target}/#{d['hash']}.#{ext}"
        unless File.exists?(file)
          original = "_raw_data/images/original/#{d['hash']}.#{d['ext']}[0]"
          system 'magick', 'convert', original, file
        end
      end

      record['images'].each do |d|
        file = "#{target}/#{d['hash']}.#{ext}"
        unless File.exists?(file)
          original = "_raw_data/images/original/#{d['hash']}.#{d['ext']}[0]"
          system 'magick', 'convert', original, '-resize', resize, file
        end
      end
    end
  end
end
