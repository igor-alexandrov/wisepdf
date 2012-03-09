module Pdf
  module Rails
    if ::Rails::VERSION::MAJOR == 2
      require 'pdf/rails/legacy'
    elsif ::Rails::VERSION::MAJOR > 2
      if ::Rails::VERSION::MINOR < 1
        require 'pdf/rails/railtie'
      else
        require 'pdf/rails/engine'
      end  
    end  
    
    if Mime::Type.lookup_by_extension(:pdf).nil?
      Mime::Type.register('application/pdf', :pdf)
    end
  end
end
