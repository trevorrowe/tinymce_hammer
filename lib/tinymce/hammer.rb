module Tinymce::Hammer

  mattr_accessor :install_path, :languages, :themes, :plugins

  @@install_path = '/javascripts/tiny_mce'

  @@languages = ['en']

  @@themes = ['advanced']

  @@plugins = ['paste']

end
