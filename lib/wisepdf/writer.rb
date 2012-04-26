module Wisepdf
  class Writer        
    def initialize(path=nil)
      self.wkhtmltopdf = path unless path.nil?
    end

    def to_pdf(string, options={})
      options = { :encoding => "UTF-8" }.merge(options)
      @options = normalize_options(options)

      invoke = self.command.join(' ')   
      log(invoke) if Wisepdf::Configuration.development? || Wisepdf::Configuration.test?

      result = IO.popen(invoke, "wb+") do |pdf|
        pdf.sync = true
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

    protected
    def command
      args = [self.wkhtmltopdf]
      args += @options.to_a.flatten.compact
      args << '--quiet'

      args << '-'        
      args << '-'

      args.map {|arg| %Q{"#{arg.gsub('"', '\"')}"}}
    end

    def normalize_options(options)
      options = self.flatten(options)
      normalized_options = {}

      options.each do |key, value|
        next if !value
        normalized_key = "--#{self.normalize_arg(key)}"
        normalized_options[normalized_key] = self.normalize_value(value)
      end
      normalized_options
    end

    def flatten(options, prefix = nil)
      hash = {}
      options.each do |k,v|
        key = prefix.nil? ? k : "#{prefix.to_s}-#{k}"

        if v.is_a?(Hash)
          hash.delete(k)              
          hash.merge!(self.flatten(v, key))
        else              
          hash[key.to_s] = v  
        end            
      end
      return hash
    end

    def normalize_arg(arg)
      arg.to_s.downcase.gsub(/[^a-z0-9]/,'-')
    end

    def normalize_value(value)
      case value
      when TrueClass
        nil
      else
        value.to_s
      end
    end

    def log(command)
      puts "*"*15 
      puts command
      puts "*"*15
    end
  end
end