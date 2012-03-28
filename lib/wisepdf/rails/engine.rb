module Wisepdf
  module Rails
    class Engine < ::Rails::Engine
      initializer "wicked_pdf.register" do
        ActionController::Base.send :include, Render
        if ::Rails.configuration.assets.enabled
          ActionView::Base.send :include, Helper::Assets
        else
          ActionView::Base.send :include, Helper::Legacy
        end
      end
    end
  end
end
