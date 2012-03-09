module Pdf
  class NoExecutableError < StandardError
    def initialize(path=nil)
      msg = "No wkhtmltopdf found or it is not executable\n"
      msg += "Path: '#{path}'\n" unless path.nil?
      msg += "Please install wkhtmltopdf - http://code.google.com/p/wkhtmltopdf"
      super(msg)
    end
  end
  
  class WriteError < StandardError
  end
end