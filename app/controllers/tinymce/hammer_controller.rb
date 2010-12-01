class Tinymce::HammerController < ActionController::Base
  
  caches_page :combine
  
  before_filter do |c|
    c.headers["Content-Type"] = "text/javascript; charset=utf-8"
  end

  def combine
    render :text => Tinymce::Hammer::Combiner.combined_js, :layout => false
  end
 
end
