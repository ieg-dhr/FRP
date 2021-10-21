Jekyll::Hooks.register :site, :after_init do |site|
  site.config['wisski_url'] = ENV['WISSKI_URL']
end
