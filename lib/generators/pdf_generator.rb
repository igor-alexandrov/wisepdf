if defined?(Rails) && Rails::VERSION::MAJOR > 2
  # Rails3 generator invoked with 'rails generate pdf'
  class PdfGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.dirname(__FILE__) + "/../../generators/pdf/templates"))
    def copy_initializer
      copy_file 'configure_pdf.rb', 'config/initializers/configure_pdf.rb'
    end
  end
end