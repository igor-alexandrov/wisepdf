require 'singleton'

module Wisepdf
  class Configuration
    include Singleton

    class << self
      attr_accessor :options
      attr_accessor :wkhtmltopdf

      def wkhtmltopdf
        return @wkhtmltopdf if @wkhtmltopdf.present?

        if @wkhtmltopdf.nil? && !self.windows?
          @wkhtmltopdf = (defined?(Bundler) ? `bundle exec which wkhtmltopdf` : `which wkhtmltopdf`).chomp
        end
        return @wkhtmltopdf
      end

      def configure
        yield self
      end

      def reset!
        @options = {
          :encoding => "UTF-8",
          :use_xserver => false
        }
        @wkhtmltopdf = nil
      end

      def development?
        (defined?(::Rails) && ::Rails.env == 'development') ||
          (defined?(RAILS_ENV) && RAILS_ENV == 'development')
      end

      def test?
        (defined?(::Rails) && ::Rails.env == 'test') ||
          (defined?(RAILS_ENV) && RAILS_ENV == 'test')
      end

      def windows?
        RbConfig::CONFIG['target_os'] == 'mingw32'
      end
    end

    self.reset!

    def method_missing(method)
      self.class.send(method)
    end
  end
end
