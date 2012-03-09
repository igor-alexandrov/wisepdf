require 'test_helper'

HTML_DOCUMENT = "<html><body>Hello World</body></html>"

# Provide a public accessor to the normally-private parse_options function
class Pdf::Writer
  public :parse_options
end

class WriterTest < Test::Unit::TestCase    
  context "Default configuration" do
    setup do
      Pdf::Configuration.reset!
    end
    
    should 'read default configuration' do
      assert_equal 'pdf.html', Pdf::Configuration.options[:layout]
      assert_equal false, Pdf::Configuration.options[:use_xserver]
    end
    
    if RbConfig::CONFIG['target_os'] != 'mingw32'
      should 'try to find wkhtmltopdf if not on windows' do
        path = (defined?(Bundler) ? `bundle exec which wkhtmltopdf` : `which wkhtmltopdf`).chomp
        
        assert_equal path, Pdf::Configuration.wkhtmltopdf
      end
    end
  end
  
  context "Configuration" do
    setup do
      Pdf::Configuration.reset!
    end
    
    should 'accept and override default configuration' do
      Pdf::Configuration.configure do |config|
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
      assert_equal '/path/to/wkhtmltopdf', Pdf::Configuration.wkhtmltopdf
      
      assert_equal 'layout.html', Pdf::Configuration.options[:layout]
      assert_equal true, Pdf::Configuration.options[:use_xserver]
      assert_equal "#{Date.today.year}", Pdf::Configuration.options[:footer][:right]
      assert_equal 8, Pdf::Configuration.options[:footer][:font_size]
      assert_equal 8, Pdf::Configuration.options[:footer][:spacing]
      assert_equal 15, Pdf::Configuration.options[:margin][:bottom]
    end
  end  
  
  context "Option parsing" do
    setup do
      Pdf::Configuration.reset!
    end
    
    should "parse header and footer options" do
      wp = Pdf::Writer.new
  
      [:header, :footer].each do |hf|
        [:center, :font_name, :left, :right].each do |o|
          assert_equal  "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} \"header_footer\"",
                        wp.parse_options(hf => {o => "header_footer"}).strip
        end
  
        [:font_size, :spacing].each do |o|
          assert_equal  "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} 12",
                        wp.parse_options(hf => {o => "12"}).strip
        end
  
        assert_equal  "--#{hf.to_s}-line",
                      wp.parse_options(hf => {:line => true}).strip
        assert_equal  "--#{hf.to_s}-html \"http://www.abc.com\"",
                      wp.parse_options(hf => {:html => {:url => 'http://www.abc.com'}}).strip
      end
    end

    should "parse toc options" do
      wp = Pdf::Writer.new
      
      [:level_indentation, :header_text].each do |o|
        assert_equal  "toc --toc-#{o.to_s.gsub('_', '-')} \"toc\"",
                      wp.parse_options(:toc => {o => "toc"}).strip
      end
  
      [:text_size_shrink].each do |o|
        assert_equal  "toc --toc-#{o.to_s.gsub('_', '-')} 5",
                      wp.parse_options(:toc => {o => 5}).strip
      end
  
      [:disable_toc_links, :disable_dotted_lines].each do |o|
        assert_equal  "toc --#{o.to_s.gsub('_', '-')}",
                      wp.parse_options(:toc => {o => true}).strip
      end
    end
  
    should "parse outline options" do
      wp = Pdf::Writer.new
  
      assert_equal "--outline", wp.parse_options(:outline => {:outline => true}).strip
      assert_equal "--outline-depth 5", wp.parse_options(:outline => {:outline_depth => 5}).strip
    end
  
    should "parse margins options" do
      wp = Pdf::Writer.new
  
      [:top, :bottom, :left, :right].each do |o|
        assert_equal "--margin-#{o.to_s} 12", wp.parse_options(:margin => {o => "12"}).strip
      end
    end

    should "parse other options" do
      wp = Pdf::Writer.new
  
      [ :orientation, :page_size, :proxy, :username, :password, :cover, :dpi,
        :encoding, :user_style_sheet
      ].each do |o|
        assert_equal "--#{o.to_s.gsub('_', '-')} \"opts\"", wp.parse_options(o => "opts").strip
      end
  
      [:cookie, :post].each do |o|
        assert_equal "--#{o.to_s.gsub('_', '-')} name value", wp.parse_options(o => "name value").strip
  
        nv_formatter = ->(number){ "--#{o.to_s.gsub('_', '-')} par#{number} val#{number}" }
        assert_equal "#{nv_formatter.call(1)} #{nv_formatter.call(2)}", wp.parse_options(o => ['par1 val1', 'par2 val2']).strip
      end
  
      [:redirect_delay, :zoom, :page_offset].each do |o|
        assert_equal "--#{o.to_s.gsub('_', '-')} 5", wp.parse_options(o => 5).strip
      end
  
      [ :book, :default_header, :disable_javascript, :greyscale, :lowquality,
        :enable_plugins, :disable_internal_links, :disable_external_links,
        :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background
      ].each do |o|
        assert_equal "--#{o.to_s.gsub('_', '-')}", wp.parse_options(o => true).strip
      end
    end
    
  end
  
  context "PDF generation" do  
    should "generate PDF from html document" do
      writer = Pdf::Writer.new
      pdf = writer.to_pdf(HTML_DOCUMENT)
      assert pdf.start_with?("%PDF-1.4")
      assert pdf.rstrip.end_with?("%%EOF")
      assert pdf.length > 100
    end

    should "raise exception when no path to wkhtmltopdf" do
      assert_raise Pdf::NoExecutableError do
        writer = Pdf::Writer.new(" ")
        writer.to_pdf(HTML_DOCUMENT)
      end
    end

    should "raise exception when wkhtmltopdf path is wrong" do
      assert_raise Pdf::NoExecutableError do
        writer = Pdf::Writer.new("/i/do/not/exist/notwkhtmltopdf")
        writer.to_pdf(HTML_DOCUMENT)
      end
    end
  
    should "raise exception when wkhtmltopdf is not executable" do
      begin
        tmp = Tempfile.new('wkhtmltopdf')
        fp = tmp.path
        File.chmod 0000, fp
        assert_raise Pdf::WriteError do
          writer = Pdf::Writer.new(fp)
          writer.to_pdf(HTML_DOCUMENT)          
        end
      ensure
        tmp.delete
      end
    end

  
    should "raise exception when pdf generation fails" do
      begin
        tmp = Tempfile.new('wkhtmltopdf')
        fp = tmp.path
        File.chmod 0777, fp
        assert_raise Pdf::WriteError do
          writer = Pdf::Writer.new(fp)
          writer.to_pdf(HTML_DOCUMENT)          
        end
      ensure
        tmp.delete
      end
    end  
  end    
end
