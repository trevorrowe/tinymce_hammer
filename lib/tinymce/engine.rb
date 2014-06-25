require 'action_controller/base'
require 'action_view'

require File.join(File.dirname(__FILE__), "hammer.rb")

%w(builder_methods combiner controller_methods view_helpers).each do |class_name|
  require File.join(File.dirname(__FILE__), "hammer", class_name)
end

module Tinymce
  class Engine < Rails::Engine
  
    # Load rake tasks
    rake_tasks do
     load File.join(File.dirname(__FILE__), '..', 'tasks', 'tinymce.rake')
    end
  
  end
end

ActionController::Base.send(:include, Tinymce::Hammer::ControllerMethods)
ActionView::Base.send(:include, Tinymce::Hammer::ViewHelpers)
ActionView::Helpers::FormBuilder.send(:include, Tinymce::Hammer::BuilderMethods)
