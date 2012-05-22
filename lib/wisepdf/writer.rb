require 'open3'

module Wisepdf
  class Writer  
    def initialize(wkhtmltopdf = nil, options = {})
      self.wkhtmltopdf = wkhtmltopdf unless wkhtmltopdf.nil?
      self.options = options
    end

    def to_pdf(string, options={})
      invoke = self.command(options).join(' ')   
      self.log(invoke) if Wisepdf::Configuration.development? || Wisepdf::Configuration.test?

      result, err = Open3.popen3(invoke) do |stdin, stdout, stderr|
        stdin.binmode
        stdin.write(string)
        stdin.close
        [stdout.read, stderr.read]
      end

      raise Wisepdf::WriteError if result.to_s.strip.empty?

      return result
    end

    def wkhtmltopdf
      @wkhtmltopdf ||= Wisepdf::Configuration.wkhtmltopdf
      @wkhtmltopdf
    end

    def wkhtmltopdf=(value)      
      @wkhtmltopdf = value
      raise Wisepdf::NoExecutableError.new(@wkhtmltopdf) if @wkhtmltopdf.blank? || !File.exists?(@wkhtmltopdf)            
    end
    
    def options
      @options ||= Wisepdf::Parser.parse(Wisepdf::Configuration.options.dup)
      @options
    end
    
    def options=(value)
      self.options.merge!(Wisepdf::Parser.parse(value))
    end
    
  protected
    def command(options = {})
      options = Wisepdf::Parser.parse(options)
      
      args = [self.wkhtmltopdf]
      args += self.options.merge(options).to_a.flatten.compact
      args << '--quiet'

      args << '-'        
      args << '-'

      args.map {|arg| %Q{"#{arg.gsub('"', '\"')}"}}
    end

    def log(command)
      puts "*"*15 
      puts command
      puts "*"*15
    end
  end
end