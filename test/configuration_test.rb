require 'helper'

class ConfigurationTest < Test::Unit::TestCase
  context "Default configuration" do
    setup do
      Wisepdf::Configuration.reset!
    end

    should 'read default configuration' do
      assert_equal "UTF-8", Wisepdf::Configuration.options[:encoding]
      assert_equal false, Wisepdf::Configuration.options[:use_xserver]
    end

    if RbConfig::CONFIG['target_os'] != 'mingw32'
      should 'try to find wkhtmltopdf if not on windows' do
        path = (defined?(Bundler) ? `bundle exec which wkhtmltopdf` : `which wkhtmltopdf`).chomp

        assert_equal path, Wisepdf::Configuration.wkhtmltopdf
      end
    end
  end

  context "Configuration" do
    setup do
      Wisepdf::Configuration.reset!
    end

    should 'accept and override default configuration' do
      Wisepdf::Configuration.configure do |config|
        config.wkhtmltopdf = '/path/to/wkhtmltopdf'
        config.options = {
          :layout => "layout.html",
          :use_xserver => true,
          :footer => {
            :right => "#{Date.today.year}",
            :font_size => 8,
            :spacing => 8
          },
          :margin => {
            :bottom => 15
          }
        }
      end
      assert_equal '/path/to/wkhtmltopdf', Wisepdf::Configuration.wkhtmltopdf

      assert_equal 'layout.html', Wisepdf::Configuration.options[:layout]
      assert_equal true, Wisepdf::Configuration.options[:use_xserver]
      assert_equal "#{Date.today.year}", Wisepdf::Configuration.options[:footer][:right]
      assert_equal 8, Wisepdf::Configuration.options[:footer][:font_size]
      assert_equal 8, Wisepdf::Configuration.options[:footer][:spacing]
      assert_equal 15, Wisepdf::Configuration.options[:margin][:bottom]
    end
  end

  context "Asset pipeline configuration" do
    setup do
      Wisepdf::Configuration.reset!
    end

    should "use the asset pipeline if assets.enabled is nil" do
      ::Rails.configuration.assets.enabled = nil
      assert(Wisepdf::Configuration.use_asset_pipeline?)
    end

    should "use the asset pipeline if assets.enabled is true" do
      ::Rails.configuration.assets.enabled = true
      assert(Wisepdf::Configuration.use_asset_pipeline?)
    end

    should "not use the asset pipeline if assets.enabled is false" do
      ::Rails.configuration.assets.enabled = false
      assert(!Wisepdf::Configuration.use_asset_pipeline?)
    end
  end
end
