require 'tempfile'

module Wisepdf
  module Render
    def self.included(base)
      base.class_eval do
        after_filter :clean_temp_files
      end
    end

    def render(options = nil, *args, &block)
      if options.is_a?(Hash) && options.has_key?(:pdf)
        options = self.default_pdf_render_options.merge(options)        
        super(options.merge(:content_type => "text/html"), *args, &block) and return if options[:show_as_html]
        
        self.log_pdf_creation
        self.make_and_send_pdf(options)
      else
        super
      end
    end

    def render_to_string(options = nil, *args, &block)
      if options.is_a?(Hash) && options.has_key?(:pdf)
        self.log_pdf_creation
        self.make_pdf(self.default_pdf_render_options.merge(options))
      else
        super
      end
    end

  protected
    def log_pdf_creation
      logger.info '*'*15 + 'WISEPDF' + '*'*15
    end

    def clean_temp_files
      if defined?(@hf_tempfiles)
        @hf_tempfiles.each { |tf| tf.close! }
      end
    end
    
    def default_pdf_render_options
      {
        :wkhtmltopdf => nil,
        :layout => false,
        :template => "#{controller_path}/#{action_name}",
        :disposition => "inline"                      
      }.merge(Wisepdf::Configuration.options)
    end
    
    def make_pdf(options = {})
      options = self.prerender_header_and_footer(options)            
      html = render_to_string(:template => options[:template], :layout => options[:layout])            
      Wisepdf::Writer.new(options[:wkhtmltopdf], options.dup).to_pdf(html)
    end

    def make_and_send_pdf(options = {})  
      pdf = self.make_pdf(options)
      File.open(options[:save_to_file], 'wb') {|file| file << pdf } if options[:save_to_file].present?
      
      filename = options.delete(:pdf)
      filename += '.pdf' unless filename =~ /.pdf\z|.PDF\Z/
      
      send_data(pdf, options.merge(:filename => filename, :type => 'application/pdf')) unless options[:save_only]
    end

    def prerender_header_and_footer(arguments)
      [:header, :footer].each do |hf|
        if arguments[hf] && arguments[hf][:html] && arguments[hf][:html].is_a?(Hash)
          opts = arguments[hf].delete(:html)
          
          @hf_tempfiles = [] if ! defined?(@hf_tempfiles)
          @hf_tempfiles.push( tf = Tempfile.new(["wisepdf_#{hf}_pdf", '.html'], 'tmp') )
          opts[:layout] ||= arguments[:layout]
          
          tf.write render_to_string(:template => opts[:template], :layout => opts[:layout], :locals => opts[:locals])
          tf.flush
          
          arguments[hf][:html] = "file://#{tf.path}"                        
        end
      end
      arguments
    end
  end
end