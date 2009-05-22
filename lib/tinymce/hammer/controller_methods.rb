module Tinymce::Hammer::ControllerMethods

  def self.included base
    base.send(:hide_action, :require_tinymce_hammer)
  end

  def require_tinymce_hammer
    @tinymce_hammer_required = true
  end

end
