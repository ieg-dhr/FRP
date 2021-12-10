Jekyll::Hooks.register :site, :after_init do |site|
  puts "converting images ..."
  mapping = {
    'data/images/thumbs' => {'resize' => '480x480>', 'ext' => 'png'},
    'data/images/full' => {'resize' => '1920x1920>', 'ext' => 'jpg'}
  }

  mapping.each do |target, options|
    resize = options['resize']
    ext = options['ext']

    system 'mkdir', '-p', target

    data = JSON.parse(File.read("data/objekt.json"))
    data.each do |record|
      args = [
        '-resize', resize,
        '-type', 'palette'
      ]

      images = record['cropped'] + record['images']
      images.each do |d|
        file = "#{target}/#{d['hash']}.#{ext}"
        unless File.exists?(file)
          # these have multiple images enbedded
          special = [
            '5a05c9381397ce5',
            '2eade4ce5e8228c',
            '68592f30f1ab8f4',
            'e961acb60834ece',
            '4a69488bad9f3bf',
            '063285b5e2cc7b4',
            'aa3c5fd4fa67b7a',
            '05f49264c5754c8',
            'dd9396da2d59a18',
            'a272b3beca06783',
            'cd15cac1884d2f1',
            '2615b32005c42c6',
            '59d54335064ca4a',
            '7372aa2281df8f7',
            '974c8eac61ce909',
            '8876cae94c62df1',
            '001d06ff011feb8',
            '3cd3ee5ac549f5b',
            '591ff13bd879c62',
            '0f995e564a992cf',
            '9fddcfce91b87d0',
            '31dae481bd29b6f'
          ]
          original = "_raw_data/images/original/#{d['hash']}.#{d['ext']}"
          if special.include?(d['hash'])
            original << '[1]'
          else
            original << '[0]'
          end

          # try again without palette type
          result = system 'magick', 'convert', original, *args, file
          unless result
            args = ['-resize', resize]
            system 'magick', 'convert', original, *args, file
          end

          # optimize
          if ext == 'png'
            system 'pngquant', '--ext', '.png', '--force', '--strip', file
          end
        end
      end
    end
  end
end
