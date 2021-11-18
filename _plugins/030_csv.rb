Jekyll::Hooks.register :site, :after_init do |site|
  data_file = 'data/objekt.json'
  csv_out = 'data/objekt.csv'
  # csv_input = 'data/object.new.csv'

  csv = CSV.open(csv_out, 'w+')
  data = JSON.parse(File.read data_file)

  headers = data.map{|r| r.keys}.flatten.uniq - [
    'id',
    'Ausstellungstext',
    'Kommentar',
    'W-Image'
  ]
  headers.prepend('id')

  csv << headers

  data.each do |record|
    record['images'] = record['images'] ? JSON.dump(record['images']) : nil
    record['cropped'] = record['cropped'] ? JSON.dump(record['cropped']) : nil

    csv << headers.map{|h| record[h] && record[h].is_a?(String) ? record[h].strip : nil}
  end
end
