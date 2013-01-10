require 'helper'

HTML_DOCUMENT = "<html><body>Hello World</body></html>"

class Wisepdf::Writer
  public :command
end

class WriterTest < Test::Unit::TestCase
  context "PDF generation" do
    should "generate PDF from html document" do
      writer = Wisepdf::Writer.new
      pdf = writer.to_pdf(HTML_DOCUMENT)
      assert pdf.start_with?("%PDF-1.4")
      assert pdf.rstrip.end_with?("%%EOF")
      assert pdf.length > 100
    end

    should "raise exception when no path to wkhtmltopdf" do
      assert_raise Wisepdf::NoExecutableError do
        writer = Wisepdf::Writer.new(" ")
        writer.to_pdf(HTML_DOCUMENT)
      end
    end

    should "raise exception when wkhtmltopdf path is wrong" do
      assert_raise Wisepdf::NoExecutableError do
        writer = Wisepdf::Writer.new("/i/do/not/exist/notwkhtmltopdf")
        writer.to_pdf(HTML_DOCUMENT)
      end
    end

    should "raise exception when wkhtmltopdf is not executable" do
      begin
        tmp = Tempfile.new('wkhtmltopdf')
        fp = tmp.path
        File.chmod 0000, fp
        assert_raise Wisepdf::WriteError do
          writer = Wisepdf::Writer.new(fp)
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
        assert_raise Wisepdf::WriteError do
          writer = Wisepdf::Writer.new(fp)
          writer.to_pdf(HTML_DOCUMENT)
        end
      ensure
        tmp.delete
      end
    end
  end
end
