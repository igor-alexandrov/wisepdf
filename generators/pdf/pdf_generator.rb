class PdfGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "configure_pdf.rb", "config/initializers/configure_pdf.rb"
    end
  end
end
