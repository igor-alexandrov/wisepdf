module Wisepdf
  class Parser
    include Singleton
    
    ESCAPED_OPTIONS = [
      :pdf, :layout, :template, :action, :partial,
      :object, :collection, :as, :spacer_template,
      :disposition, :locals, :status, :file, :text,
      :xml, :json, :callback, :inline, :location
    ]
       
    class << self
      def parse(options)
        options = self.escape(options)
        options = self.flatten(options)
        parsed_options = {}

        options.each do |key, value|
          unless( value == false || value.nil? )
            normalized_key = "--#{self.normalize_arg(key)}"
            parsed_options[normalized_key] = self.normalize_value(value)
          end
        end
        parsed_options
      end
            
    protected  
      def escape(options)
        options.delete_if{ |k,v| ESCAPED_OPTIONS.include?(k.to_sym) }    
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
    end  
  end
end