module Tinymce::Hammer::ViewHelpers

  # If you call this method in your document head two script tags will be
  # inserted when tinymce is required, otherwise nothing will be inserted.
  def init_tinymce_hammer_if_required
    if tinymce_hammer_required?
      tinymce_hammer_javascript_tags
    else
      nil
    end
  end

  def init_tinymce_hammer
    tinymce_hammer_javascript_tags
  end

  # Returns two script tags.  The first loads the combined javascript file
  # containing tinymce.  The second tag initializes tiny mce.
  def tinymce_hammer_javascript_tags

    init = ::Tinymce::Hammer.init
    if init.is_a?(Hash)
      init = HashWithIndifferentAccess.new(init)
      init = init.keys.sort.collect(&:to_s).sort.collect{|key|
        [key, init[key]]
      }
    end
    init = init.collect {|key,value| "#{key} : #{value.to_json}" }.join(', ')

    setup = "init.setup = #{Tinymce::Hammer.setup};" if Tinymce::Hammer.setup

    js_tags = "
<script src='#{tinymce_hammer_js_path}' type='text/javascript'></script>
<script type='text/javascript'>
  TinymceHammer = {
    init : function() {
      var init = { #{init} };
      init.mode = 'specific_textareas';
      init.editor_selector = 'tinymce';
      init.plugins = '#{Tinymce::Hammer.plugins.join(',')}';
      init.language = '#{Tinymce::Hammer.languages.first}';
      #{setup}
      tinyMCE.init(init);
    },
    addEditor : function(dom_id) {
      tinyMCE.execCommand('mceAddControl', true, dom_id);
    }
  }
  DomReady.ready(TinymceHammer.init);
</script>"
    js_tags.respond_to?(:html_safe) ? js_tags.html_safe : js_tags
  end

  def tinymce_tag name, content = '', options = {}
    require_tinymce_hammer
    append_class_name(options, 'tinymce')
    text_area_tag(name, content, options)
  end

  def tinymce object_name, method, options = {}
    require_tinymce_hammer
    append_class_name(options, 'tinymce')
    text_area(object_name, method, options)
  end

  def append_class_name options, class_name #:nodoc:
    key = options.has_key?('class') ? 'class' : :class 
    unless options[key].to_s =~ /(^|\s+)#{class_name}(\s+|$)/
      options[key] = "#{options[key]} #{class_name}".strip
    end
    options
  end

end
