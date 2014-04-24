module Wisepdf
  module Rails
    class Engine < ::Rails::Engine
      initializer "wise_pdf.register" do
        ActionController::Base.send :include, Wisepdf::Render

        if Wisepdf::Configuration.use_asset_pipeline?
          ActionView::Base.send :include, Helper::Assets
        else
          ActionView::Base.send :include, Helper::Legacy
        end
      end
    end
  end
end
