Pdf::Configuration.configuration do |config|
  config.wkhtmltopdf = '/path/to/wkhtmltopdf'
  config.options = {
    #:layout => "pdf.html"
  }
end
