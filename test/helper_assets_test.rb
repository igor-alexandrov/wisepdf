require 'helper'

class AssetsHelperTest < ActionView::TestCase
  include Wisepdf::Helper::Assets

  context "wisepdf_stylesheet_tag" do
    should 'include stylesheet if no extension is given' do
      assert_match /Wisepdf styles/, wisepdf_stylesheet_tag('wisepdf').strip
    end

    should 'include stylesheet if .css extension is given' do
      assert_match /Wisepdf styles/, wisepdf_stylesheet_tag('wisepdf.css').strip
    end
  end

  context "wisepdf_javascript_tag" do
    should 'include javascript if no extension is given' do
      assert_match /Wisepdf javascript/, wisepdf_javascript_tag('wisepdf').strip
    end

    should 'include javascript if .js extension is given' do
      assert_match /Wisepdf javascript/, wisepdf_javascript_tag('wisepdf.js').strip
    end
  end
end
