puts "\n +++++++ loaded tinymce hammer\n"

require 'actioncontroller/base'
require 'actionview'

module Tinymce
  class Engine < Rails::Engine
  
    # Load rake tasks
    rake_tasks do
      load File.join(File.dirname(__FILE__), 'tasks/tinymce.rake')
    end
  
  end
end

ActionController::Base.send(:include, Tinymce::Hammer::ControllerMethods)
ActionView::Base.send(:include, Tinymce::Hammer::ViewHelpers)
ActionView::Helpers::FormBuilder.send(:include, Tinymce::Hammer::BuilderMethods)
