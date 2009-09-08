class Tinymce::HammerController < ActionController::Base

  REQUIRED = true
  OPTIONAL = false
  MARK_DONE = true
  
  caches_page :combine
  
  before_filter do |c|
    c.headers["Content-Type"] = "text/javascript; charset=utf-8"
  end

  # Combines the following files into a single .js file, and caches that file
  # to disk (when action_controller.perform_caching == true).   
  #
  # * tiny_mce.js (the main library)
  # * each requested language file (like en.js)
  # * each requested theme's editor_template.js
  # * each requested theme's language files
  # * each requested plugin's editor_plugin.js
  # * each requested plugin's language files
  #
  # On-top of combining .js files support js is added to the top and end of this
  # file to alert tiny_mce that these files have been loaded into the dom and
  # no XMLHttpRequests are required to load these dynamically.
  def combine

    init_content

    # add the tiny mce library
    add_content('tiny_mce.js', REQUIRED)

    # add languages
    Tinymce::Hammer.languages.each do |lang|
      add_content("langs/#{lang}.js", REQUIRED, MARK_DONE)
    end

    # add themes (and their languages)
    Tinymce::Hammer.themes.each do |theme|
      add_content("themes/#{theme}/editor_template.js", REQUIRED, MARK_DONE)
      Tinymce::Hammer.languages.each do |lang|
        add_content("themes/#{theme}/langs/#{lang}.js", OPTIONAL, MARK_DONE)
      end
    end

    # add plugins (and their languages)
    Tinymce::Hammer.plugins.each do |plugin|
      add_content("plugins/#{plugin}/editor_plugin.js" , OPTIONAL, MARK_DONE)
      Tinymce::Hammer.languages.each do |lang|
        add_content("plugins/#{plugin}/langs/#{lang}.js", OPTIONAL, MARK_DONE)
      end
    end
    
    render :text => content, :layout => false

  end

  protected

  # this code tells tiny_mce where its main library files are located and that
  # it was loaded via a combined file.
  def init_content
    @content = <<-JS
      window.tinyMCEPreInit = {
        base : '#{Tinymce::Hammer.url_path}',
        suffix : '',  
        query : ''
      }
      window.tinyMCE_GZ = { loaded : true };
    JS
    @events = []
  end

  def add_content path, required, mark_done = false
    url_path = File.join(Tinymce::Hammer.url_path, path)
    disk_path = File.join(Rails.root, 'public', Tinymce::Hammer.install_path, path)
    if required or File.exists?(disk_path)
      @content += File.read(disk_path)
      if mark_done
        @events << "tinymce.ScriptLoader.markDone(tinyMCE.baseURI.toAbsolute('#{url_path}'));";
      end
    end
  end

  def content
    @content += @events.join("\n")
  end
 
end
