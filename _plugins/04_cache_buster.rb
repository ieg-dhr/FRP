require 'securerandom'

module Jekyll
  class CacheBusterTag < Liquid::Tag
    def render(context)
      if Jekyll.env == 'production'
        '?' + SecureRandom.hex(4)
      end
    end
  end
end

Liquid::Template.register_tag('cache_buster', Jekyll::CacheBusterTag)
