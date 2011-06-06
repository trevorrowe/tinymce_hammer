puts "\n+++ loaded tinymce"

module Tinymce
  module Hammer
    class Engine < Rails::Engine
    
      # Load rake tasks
      rake_tasks do
        load File.join(File.dirname(__FILE__), 'tasks/tinymce.rake')
      end
    
    end
  end
end
