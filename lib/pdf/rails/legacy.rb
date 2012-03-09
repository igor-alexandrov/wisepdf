ActionController::Base.send :include, Render

unless ActionView::Base.instance_methods.include? "wicked_pdf_stylesheet_link_tag"
  ActionView::Base.send :include, Helper
end
