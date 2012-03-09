module Pdf
  module Rails
    class Engine < ::Rails::Engine
      initializer "wicked_pdf.register" do
        ActionController::Base.send :include, Render
        ActionView::Base.send :include, Helper::Assets
      end
    end
  end
end
