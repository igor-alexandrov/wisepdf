module Wisepdf
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "wise_pdf.register" do
        ActionController::Base.send :include, Render
        ActionView::Base.send :include, Helper::Legacy
      end
    end
  end
end
