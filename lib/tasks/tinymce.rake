namespace :tinymce do
  
  task :cache_js => :environment do
    Tinymce::Hammer.cache_js
  end

end
