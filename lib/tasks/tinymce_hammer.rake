namespace :tinymce do
  
  desc 'Copies TinyMCE to your Tinymce::Hammer.install_path'
  task :install => ['environment'] do

    plugin_path = File.join(File.dirname(__FILE__), '..', '..')
    src = File.join(plugin_path, 'javascripts', 'tiny_mce', '.')
    dest = File.join(Rails.root, 'public', Tinymce::Hammer.install_path)

    if File.exists?(dest)
      puts ""
      puts "Unable to install, destination directory already exists."
      puts "  #{dest}"
      puts ""
      puts "To fix this you can:"
      puts " * remove the files at the above destination"
      puts " * change Tinymce::Hammer.install_path and try again (do this in"
      puts "   config/initializers/tinymce_hammer.rb)"
      puts ""
      exit
    end

    FileUtils.mkdir_p(dest)
    FileUtils.cp_r(src, dest)

    puts ""
    puts "TinyMCE installed to:"
    puts "  #{dest}"
    puts ""

  end

end
