class WisepdfGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "configure_wisepdf.rb", "config/initializers/configure_wisepdf.rb"
    end
  end
end
