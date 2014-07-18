module Tinymce::Hammer

  mattr_accessor :install_path, :src, :languages, :themes, :plugins, :setup

  @@install_path = '/javascripts/tiny_mce'

  @@src = false

  @@setup = nil

  @@plugins = ['paste']

  @@languages = []

  @@themes = ['modern']

  @@init = {
    :paste_convert_headers_to_strong => true,
    :paste_convert_middot_lists => true,
    :paste_remove_spans => true,
    :paste_remove_styles => true,
    :paste_strip_class_attributes => true,
    :theme => 'modern',
    :valid_elements => "a[href|title,blockquote[cite],br,caption,cite,code,dl,dt,dd,em,i,img[src|alt|title|width|height|align],li,ol,p,pre,q[cite],small,strike,strong/b,sub,sup,u,ul" ,
  }

  def self.init= js
    @@init = js
  end

  def self.init
    @@init
  end

  def self.cache_js
    File.open("#{Rails.root}/public/javascripts/tinymce_hammer.js", 'w') do |file|
      file.write Combiner.combined_js
    end
  end

end
