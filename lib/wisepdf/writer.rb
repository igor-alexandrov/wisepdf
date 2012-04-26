require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/object/blank'

module Wisepdf
  class Writer        
    def initialize(path=nil)
      self.wkhtmltopdf = path unless path.nil?
    end

    def to_pdf(string, options={})
      command = "\"#{self.wkhtmltopdf}\" #{parse_options(options)} #{'-q ' unless Wisepdf::Configuration.windows?}- - " # -q for no errors on stdout
      print_command(command) if Wisepdf::Configuration.development?
         
      result = IO.popen(command, "wb+") do |pdf|
        pdf.puts(string)
        pdf.close_write
        pdf.gets(nil)
      end
      
      raise Wisepdf::WriteError if result.to_s.strip.empty?
      
      return result
    end
    
    def wkhtmltopdf
      return @wkhtmltopdf if @wkhtmltopdf.present?

      @wkhtmltopdf = Wisepdf::Configuration.wkhtmltopdf
      raise Wisepdf::NoExecutableError.new(@wkhtmltopdf) if @wkhtmltopdf.nil? || !File.exists?(@wkhtmltopdf)
      
      return @wkhtmltopdf
    end
    
    def wkhtmltopdf=(value)
      @wkhtmltopdf = value
      raise Wisepdf::NoExecutableError.new(@wkhtmltopdf) if @wkhtmltopdf.nil? || !File.exists?(@wkhtmltopdf)      
    end
    
  private
    def print_command(cmd)
      puts "*"*15 
      puts cmd
      puts "*"*15
    end

    def parse_options(options)
      [
        parse_header_footer(:header => options.delete(:header),
                            :footer => options.delete(:footer),
                            :layout => options[:layout]),
        parse_toc(options.delete(:toc)),
        parse_outline(options.delete(:outline)),
        parse_margins(options.delete(:margin)),
        parse_others(options),
        parse_basic_auth(options)
      ].join(' ')
    end

    def parse_basic_auth(options)
      if options[:basic_auth]
        user, passwd = Base64.decode64(options[:basic_auth]).split(":")
        "--username '#{user}' --password '#{passwd}'"
      else
        ""
      end
    end

    def make_option(name, value, type=:string)
      if value.is_a?(Array)
        return value.collect { |v| make_option(name, v, type) }.join('')
      end
      "--#{name.gsub('_', '-')} " + case type
        when :boolean then ""
        when :numeric then value.to_s
        when :name_value then value.to_s
        else "\"#{value}\""
      end + " "
    end

    def make_options(options, names, prefix="", type=:string)
      names.collect {|o| make_option("#{prefix.blank? ? "" : prefix + "-"}#{o.to_s}", options[o], type) unless options[o].blank?}.join
    end

    def parse_header_footer(options)
      r=""
      [:header, :footer].collect do |hf|
        unless options[hf].blank?
          opt_hf = options[hf]
          r += make_options(opt_hf, [:center, :font_name, :left, :right], "#{hf.to_s}")
          r += make_options(opt_hf, [:font_size, :spacing], "#{hf.to_s}", :numeric)
          r += make_options(opt_hf, [:line], "#{hf.to_s}", :boolean)
          unless opt_hf[:html].blank?
            r += make_option("#{hf.to_s}-html", opt_hf[:html][:url]) unless opt_hf[:html][:url].blank?
          end
        end
      end unless options.blank?
      r
    end

    def parse_toc(options)
      r = 'toc ' unless options.nil?
      unless options.blank?
        r += make_options(options, [ :level_indentation, :header_text], "toc")
        r += make_options(options, [ :text_size_shrink], "toc", :numeric)
        r += make_options(options, [ :disable_toc_links, :disable_dotted_lines], "", :boolean)
      end
      return r
    end

    def parse_outline(options)
      unless options.blank?
        r = make_options(options, [:outline], "", :boolean)
        r +=make_options(options, [:outline_depth], "", :numeric)
      end
    end

    def parse_margins(options)
      make_options(options, [:top, :bottom, :left, :right], "margin", :numeric) unless options.blank?
    end

    def parse_others(options)
      unless options.blank?
        r = make_options(options, [ :orientation,
                                    :page_size,
                                    :page_width,
                                    :page_height,
                                    :proxy,
                                    :username,
                                    :password,
                                    :cover,
                                    :dpi,
                                    :encoding,
                                    :user_style_sheet])
        r +=make_options(options, [ :cookie,
                                    :post], "", :name_value)
        r +=make_options(options, [ :redirect_delay,
                                    :zoom,
                                    :page_offset,
                                    :javascript_delay], "", :numeric)
        r +=make_options(options, [ :book,
                                    :default_header,
                                    :disable_javascript,
                                    :greyscale,
                                    :lowquality,
                                    :enable_plugins,
                                    :disable_internal_links,
                                    :disable_external_links,
                                    :print_media_type,
                                    :disable_smart_shrinking,
                                    :use_xserver,
                                    :no_background], "", :boolean)
      end
    end
  end
end