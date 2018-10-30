module Wisepdf
  module Helper
    module Legacy
      def wisepdf_stylesheet_tag(*sources)
        stylesheets_dir = ::Rails.root.join('public','stylesheets')

        sources.collect { |source|
          filename = ( source =~ /.css\z/ ? source : source + '.css' )
          "<style type='text/css'>
            #{File.read(stylesheets_dir.join(filename))}
          </style>"
        }.join("\n").html_safe
      end

      def wisepdf_image_tag(img, options={})
        image_tag "file:///#{::Rails.root.join('public', 'images', img).pathname.to_s}", options
      end

      def wisepdf_javascript_tag(*sources)
        javascripts_dir = ::Rails.root.join('public','javascripts')

        sources.collect { |source|
          filename = ( source =~ /.js\z/ ? source : source + '.js' )
          "<script type='text/javascript'>
            //<![CDATA[
              #{File.read(javascripts_dir.join(filename))}
            //]]>
          </script>"
        }.join("\n").html_safe
      end
    end

    module Assets
      def wisepdf_stylesheet_tag(*sources)
        env = ::Sprockets::Railtie.build_environment(::Rails.application)
        sources.collect { |source|
          filename = ( source =~ /.css\z/ ? source : source + '.css' )
          "<style type='text/css'>
            #{env.find_asset(filename)}
          </style>"
        }.join("\n").html_safe
      end

      def wisepdf_image_tag(img, options={})
        env = ::Sprockets::Railtie.build_environment(::Rails.application)
        if File.exists? img
          image_tag "file://#{img}", options
        elsif asset = env.find_asset(img)
          image_tag "file://#{asset.pathname.to_s}", options
        end
      end

      def wisepdf_javascript_tag(*sources)
        env = ::Sprockets::Railtie.build_environment(::Rails.application)
        sources.collect { |source|
          filename = ( source =~ /.js\z/ ? source : source + '.js' )
          "<script type='text/javascript'>
            //<![CDATA[
              #{env.find_asset(filename)}
            //]]>
          </script>"
        }.join("\n").html_safe
      end
    end
  end
end
