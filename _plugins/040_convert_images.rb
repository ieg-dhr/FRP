Jekyll::Hooks.register :site, :after_init do |site|
  puts "converting images ..."
  target = 'data/images/thumbs'
  mapping = {
    'data/images/thumbs' => '800x800>',
    'data/images/full' => '1920x1920>',
  }

  mapping.each do |target, resize|
    system 'mkdir', '-p', target

    data = JSON.parse(File.read("data/objekt.json"))
    data.each do |record|

      record['cropped'].each do |d|
        file = "#{target}/#{d['hash']}.jpg"
        unless File.exists?(file)
          original = "_raw_data/images/original/#{d['hash']}.#{d['ext']}[0]"
          system 'magick', 'convert', original, file
        end
      end

      record['images'].each do |d|
        file = "#{target}/#{d['hash']}.jpg"
        unless File.exists?(file)
          original = "_raw_data/images/original/#{d['hash']}.#{d['ext']}[0]"
          system 'magick', 'convert', original, '-resize', resize, file
        end
      end
    end
  end
end
