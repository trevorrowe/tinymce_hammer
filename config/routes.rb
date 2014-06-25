Rails.application.routes.draw do
  match '/javascripts/tinymce_hammer.js' => 'tinymce/hammer#combine',
    :as => 'tinymce_hammer_js'
end
