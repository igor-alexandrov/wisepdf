require 'singleton'

module Wisepdf
  class Configuration
    include Singleton
    cattr_accessor :options
    cattr_accessor :wkhtmltopdf
    
    class << self
      def wkhtmltopdf
        return @@wkhtmltopdf if @@wkhtmltopdf.present?
                
        if @@wkhtmltopdf.nil? && !self.windows?
          @@wkhtmltopdf = (defined?(Bundler) ? `bundle exec which wkhtmltopdf` : `which wkhtmltopdf`).chomp
        end
        return @@wkhtmltopdf 
      end
    
      def configure
        yield self
      end
    
      def reset!
        @@options = {
          :layout => "pdf.html",
          :use_xserver => false
        }
        @@wkhtmltopdf = nil
      end    
    
      def development?
        (defined?(::Rails) && ::Rails.env == 'development') ||
          (defined?(RAILS_ENV) && RAILS_ENV == 'development')
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