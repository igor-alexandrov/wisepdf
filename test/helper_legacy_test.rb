require 'helper'
 
class LegacyHelperTest < ActionView::TestCase
  include Wisepdf::Helper::Legacy
    
  context "wisepdf_stylesheet_tag" do  
    should 'include stylesheet if no extension is given' do
      assert_match wisepdf_stylesheet_tag('wisepdf').strip, /Wisepdf styles/
    end
  
    should 'include stylesheet if .css extension is given' do
      assert_match wisepdf_stylesheet_tag('wisepdf.css').strip, /Wisepdf styles/
    end
  end  
  
  context "wisepdf_javascript_tag" do  
    should 'include javascript if no extension is given' do
      assert_match wisepdf_javascript_tag('wisepdf').strip, /Wisepdf javascript/
    end
  
    should 'include javascript if .js extension is given' do
      assert_match wisepdf_javascript_tag('wisepdf.js').strip, /Wisepdf javascript/
    end
  end  
end
