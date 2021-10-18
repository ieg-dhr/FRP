require 'pry'
require 'roo'
require 'digest'

Jekyll::Hooks.register :site, :after_init do |site|
  print "converting object data ... "
  
  dir = File.expand_path(__dir__ + '/..')

  system 'mkdir', '-p', "#{dir}/_data/images/original/"
  system 'mkdir', '-p', "#{dir}/_site/data"

  filename = "#{dir}/_data/objects.ods"
  ods = Roo::Spreadsheet.open(filename)
  s = ods.sheet(0)

  fields = s.row(1)[0..-1]
  data = []

  (2..s.last_row).each do |i|
    values = s.row(i)
    record = fields.zip(values).to_h.reject{|k, v| v.nil?}

    (record['Bild-URL'] || '').split("\n").each do |u|
      next if u.match?(/^entity:node/)

      u.gsub! ' ', '%20'
      h = Digest::SHA2.hexdigest(u)[0..14]
      base = u.split('/').last
      parts = base.split('.')
      ext = (parts.size > 1 ? parts.last : nil) || 'jpg'

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

      # force jpg format for these
      ext = 'jpg' if [
        '0ddd11da4e961a5'
      ].include?(h)

      # force png format for these
      ext = 'png' if [
        '9e48d6ab64ce34f',
        '24f4223b9f1c250',
        '9e48d6ab64ce34f',
        '78b71077c71bd41',
        '39aa1421587a67c'
      ].include?(h)

      # force gif format for these
      ext = 'gif' if [
        'eb5f88326331d50'
      ].include?(h)

      file = "#{dir}/_data/images/original/#{h}.#{ext}"

      unless File.exists?(file)
        puts "downloading '#{u}' to #{file}"
        success = system 'curl', '-o', file, '-L', u
        system 'rm', '-f', file unless success
      end

      record['W-Image'] ||= []
      record['W-Image'] << file
    end

    data << record
  end

  File.open "#{dir}/data/objects.json", 'w' do |f|
    f.write JSON.dump(data)
  end

  puts "done"
end
