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

    suffix = Tinymce::Hammer.src ? '_src' : ''

    # add the tiny mce library
    add_content("tiny_mce#{suffix}.js", REQUIRED)

    # add languages
    Tinymce::Hammer.languages.each do |lang|
      add_content("langs/#{lang}.js", REQUIRED, MARK_DONE)
    end

    # add themes (and their languages)
    Tinymce::Hammer.themes.each do |theme|
      add_content("themes/#{theme}/editor_template#{suffix}.js", REQUIRED, MARK_DONE)
      Tinymce::Hammer.languages.each do |lang|
        add_content("themes/#{theme}/langs/#{lang}.js", OPTIONAL, MARK_DONE)
      end
    end

    # add plugins (and their languages)
    Tinymce::Hammer.plugins.each do |plugin|
      add_content("plugins/#{plugin}/editor_plugin#{suffix}.js" , OPTIONAL, MARK_DONE)
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
// domReady.js
//
// DOMContentLoaded event handler. Works for browsers that don't support the DOMContentLoaded event.
//
// Modification Log:
// Date 	Initial Description
// 26 May 2008	TKO	Created by Tanny O'Haley

/*global addEvent, escape, unescape */

var domReadyEvent = {
	name: "domReadyEvent",
	// Array of DOMContentLoaded event handlers.
	events: {},
	domReadyID: 1,
	bDone: false,
	DOMContentLoadedCustom: null,

	// Function that adds DOMContentLoaded listeners to the array.
	add: function(handler) {
		// Assign each event handler a unique ID. If the handler has an ID, it
		// has already been added to the events object or been run.
		if (!handler.$$domReadyID) {
			handler.$$domReadyID = this.domReadyID++;

			// If the DOMContentLoaded event has happened, run the function.
			if(this.bDone){
				handler();
			}

			// store the event handler in the hash table
			this.events[handler.$$domReadyID] = handler;
		}
	},

	remove: function(handler) {
		// Delete the event handler from the hash table
		if (handler.$$domReadyID) {
			delete this.events[handler.$$domReadyID];
		}
	},

	// Function to process the DOMContentLoaded events array.
	run: function() {
		// quit if this function has already been called
		if (this.bDone) {
			return;
		}

		// Flag this function so we don't do the same thing twice
		this.bDone = true;

		// iterates through array of registered functions 
		for (var i in this.events) {
			this.events[i]();
		}
	},

	schedule: function() {
		// Quit if the init function has already been called
		if (this.bDone) {
			return;
		}
	
		// First, check for Safari or KHTML.
		if(/KHTML|WebKit/i.test(navigator.userAgent)) {
			if(/loaded|complete/.test(document.readyState)) {
				this.run();
			} else {
				// Not ready yet, wait a little more.
				setTimeout(this.name + ".schedule()", 100);
			}
		} else if(document.getElementById("__ie_onload")) {
			// Second, check for IE.
			return true;
		}

		// Check for custom developer provided function.
		if(typeof this.DOMContentLoadedCustom === "function") {
			//if DOM methods are supported, and the body element exists
			//(using a double-check including document.body, for the benefit of older moz builds [eg ns7.1] 
			//in which getElementsByTagName('body')[0] is undefined, unless this script is in the body section)
			if(typeof document.getElementsByTagName !== 'undefined' && (document.getElementsByTagName('body')[0] !== null || document.body !== null)) {
				// Call custom function.
				if(this.DOMContentLoadedCustom()) {
					this.run();
				} else {
					// Not ready yet, wait a little more.
					setTimeout(this.name + ".schedule()", 250);
				}
			}
		}

		return true;
	},

	init: function() {
		// If addEventListener supports the DOMContentLoaded event.
		if(document.addEventListener) {
			document.addEventListener("DOMContentLoaded", function() { domReadyEvent.run(); }, false);
		}

		// Schedule to run the init function.
		setTimeout("domReadyEvent.schedule()", 100);

		function run() {
			domReadyEvent.run();
		}
		
		// Just in case window.onload happens first, add it to onload using an available method.
		if(typeof addEvent !== "undefined") {
			addEvent(window, "load", run);
		} else if(document.addEventListener) {
			document.addEventListener("load", run, false);
		} else if(typeof window.onload === "function") {
			var oldonload = window.onload;
			window.onload = function() {
				domReadyEvent.run();
				oldonload();
			};
		} else {
			window.onload = run;
		}


		/* for Internet Explorer */
		/*@cc_on
			@if (@_win32 || @_win64)
			document.write('<script id=__ie_onload defer src="//:"><\/script>');
			var script = document.getElementById("__ie_onload");
			script.onreadystatechange = function() {
				if (this.readyState == "complete") {
					domReadyEvent.run(); // call the onload handler
				}
			};
			@end
		@*/
	}
};

var domReady = function(handler) { domReadyEvent.add(handler); };
domReadyEvent.init();

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
