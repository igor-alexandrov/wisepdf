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
        log_pdf_creation
        make_and_send_pdf(options.delete(:pdf), Wisepdf::Configuration.options.merge(options))
      else
        super
      end
    end

    def render_to_string(options = nil, *args, &block)
      if options.is_a?(Hash) && options.has_key?(:pdf)
        log_pdf_creation
        options.delete(:pdf)
        make_pdf(Wisepdf::Configuration.options.merge(options))
      else
        super
      end
    end

  protected
    def log_pdf_creation
      logger.info '*'*15 + 'PDF' + '*'*15
    end

    def clean_temp_files
      if defined?(@hf_tempfiles)
        @hf_tempfiles.each { |tf| tf.close! }
      end
    end

    def make_pdf(options = {})
      html_string = render_to_string(:template => options.delete(:template), :layout => options.delete(:layout))
      options = prerender_header_and_footer(options)
      w = Wisepdf::Writer.new(options[:wkhtmltopdf])
      w.to_pdf(html_string, options)
    end

    def make_and_send_pdf(pdf_name, options={})
      options[:wkhtmltopdf] ||= nil
      options[:layout]      ||= false
      options[:template]    ||= File.join(controller_path, action_name)
      options[:disposition] ||= "inline"
      if options[:show_as_html]
        render :template => options[:template], :layout => options[:layout], :content_type => "text/html"
      else
        pdf_content = make_pdf(options)
        File.open(options[:save_to_file], 'wb') {|file| file << pdf_content } if options.delete(:save_to_file)
      
        pdf_name += '.pdf' unless pdf_name =~ /.pdf\z|.PDF\Z/
        send_data(pdf_content, :filename => pdf_name, :type => 'application/pdf', :disposition => options[:disposition]) unless options[:save_only]
      end
    end

    def prerender_header_and_footer(arguments)
      [:header, :footer].each do |hf|
        if arguments[hf] && arguments[hf][:html] && arguments[hf][:html].is_a?(Hash)
          opts = arguments[hf].delete(:html)
          
          @hf_tempfiles = [] if ! defined?(@hf_tempfiles)
          @hf_tempfiles.push( tf = Wisepdf::Tempfile.new("wisepdf_#{hf}_pdf.html") )
          opts[:layout] ||= arguments[:layout]
          
          tf.write render_to_string(:template => opts[:template], :layout => opts[:layout], :locals => opts[:locals])
          tf.flush
          
          options[hf][:html] = "file://#{tf.path}"                        
        end
      end
      arguments
    end
  end
end