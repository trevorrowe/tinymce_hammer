if Rails.version =~ /^3/

  # rails 3 generator
  class TinymceInstallationGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def copy_files
      src_dir = File.join('javascripts', 'tiny_mce')
      dest_dir = File.join('public', Tinymce::Hammer.install_path)
      if File.exists?(dest_dir)
        puts <<-MSG
A TinyMCE installation appears to already exist at:

  #{dest_dir}

You should remove the old instation before running this generator.  Be sure
to save any manually added plugins/code.
      MSG


      else
        directory src_dir, dest_dir
      end
    end

  end

else

  class TinymceInstallationGenerator < Rails::Generator::Base
  
    def manifest
      record do |m|
  
        src_prefix = File.join('javascripts', 'tiny_mce')
        dest_prefix = File.join('public', Tinymce::Hammer.install_path)

        src_dir = File.expand_path("../templates/#{src_prefix}", __FILE__)

        m.directory dest_prefix
  
        Dir.glob("#{src_dir}/**/*").each do |path|

          # remove the absolute path to the plugin template dir
          path = path.gsub(/^#{src_dir}/, '')
  
          src = File.join(src_prefix, path)
          dest = File.join(dest_prefix, path)
  
          if path =~ /\./
            m.file src, dest
          else
            m.directory dest
          end
  
        end
  
      end
    end
  
  end

end
