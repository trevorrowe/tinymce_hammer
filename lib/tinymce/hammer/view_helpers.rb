module Tinymce::Hammer::ViewHelpers

  def tinymce_hammer_js
    if @tinymce_hammer_required
      javascript_include_tag(tinymce_hammer_js_path)
    else
      nil
    end
  end

end
