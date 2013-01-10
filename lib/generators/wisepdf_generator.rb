if defined?(Rails) && Rails::VERSION::MAJOR > 2
  # Rails3 generator invoked with 'rails generate wisepdf'
  class WisepdfGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.dirname(__FILE__) + "/../../generators/pdf/templates"))
    def copy_initializer
      copy_file 'configure_wisepdf.rb', 'config/initializers/configure_wisepdf.rb'
    end
  end
end
