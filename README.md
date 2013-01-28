[![Build Status](https://secure.travis-ci.org/igor-alexandrov/wisepdf.png)](http://travis-ci.org/igor-alexandrov/wisepdf)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/igor-alexandrov/wisepdf)

# wisepdf

Wkhtmltopdf wrapper done right.

**Wisepdf** uses the shell utility [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) to serve a PDF file to a user from HTML.  In other words, rather than dealing with a PDF generation DSL of some sort, you simply write an HTML view as you would normally, then let PDF take care of the hard stuff.

**Wisepdf** is inspired by [Wicked PDF](https://github.com/mileszs/wicked_pdf) and [PDFKit](https://github.com/jdpace/PDFKit). PDF is optimized to use with Rails 3.1 (3.2), Ruby 1.9.2 and wkhtmltopdf 0.10.0 (and above).

## Installation

First, be sure to install [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/).
Note that versions before 0.9.0 [have problems](http://code.google.com/p/wkhtmltopdf/issues/detail?id=82&q=vodnik) on some machines with reading/writing to streams.
This plugin relies on streams to communicate with wkhtmltopdf.

More information about [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) could be found [here](http://madalgo.au.dk/~jakobt/wkhtmltoxdoc/wkhtmltopdf_0.10.0_rc2-doc.html).

Add this to your Gemfile:

    gem 'wisepdf'

then do:
    
    bundle install

## How does it work?

### Basic Usage

    class ThingsController < ApplicationController
      def show
        respond_to do |format|
          format.html
          format.pdf do
            render :pdf => "file_name"
          end
        end
      end
    end

### Advanced Usage with all available options

    class ThingsController < ApplicationController
      def show
        respond_to do |format|
          format.html
          format.pdf do
            render :pdf                            => 'file_name',
                   :template                       => 'things/show.pdf.erb',
                   :layout                         => 'pdf.html',                   # use 'pdf.html' for a pdf.html.erb file
                   :show_as_html                   => params[:debug].present?,      # allow debuging based on url param
                   :orientation                    => 'Landscape',                  # default Portrait
                   :page_size                      => 'A4, Letter, ...',            # default A4
                   :save_to_file                   => Rails.root.join('pdfs', "#{filename}.pdf"),
                   :save_only                      => false,                        # depends on :save_to_file being set first
                   :proxy                          => 'TEXT',
                   :basic_auth                     => false                         # when true username & password are automatically sent from session
                   :username                       => 'TEXT',
                   :password                       => 'TEXT',
                   :cover                          => 'URL',
                   :dpi                            => 'dpi',
                   :encoding                       => 'TEXT',
                   :user_style_sheet               => 'URL',
                   :cookie                         => ['_session_id SESSION_ID'], # could be an array or a single string in a 'name value' format
                   :post                           => ['query QUERY_PARAM'],    # could be an array or a single string in a 'name value' format
                   :redirect_delay                 => NUMBER,
                   :zoom                           => FLOAT,
                   :page_offset                    => NUMBER,
                   :book                           => true,
                   :default_header                 => true,
                   :disable_javascript             => false,
                   :greyscale                      => true,
                   :lowquality                     => true,
                   :enable_plugins                 => true,
                   :disable_internal_links         => true,
                   :disable_external_links         => true,
                   :print_media_type               => true,
                   :disable_smart_shrinking        => true,
                   :use_xserver                    => true,
                   :no_background                  => true,
                   :margin => {:top                => SIZE,                         # default 10 (mm)
                               :bottom             => SIZE,
                               :left               => SIZE,
                               :right              => SIZE},
                   :header => {:html => { :template => 'users/header.pdf.erb',  # use :template OR :url
                                          :layout   => 'pdf_plain.html',        # optional, use 'pdf_plain.html' for a pdf_plain.html.erb file, defaults to main layout
                                          :url      => 'www.example.com',
                                          :locals   => { :foo => @bar }},
                               :center             => 'TEXT',
                               :font_name          => 'NAME',
                               :font_size          => SIZE,
                               :left               => 'TEXT',
                               :right              => 'TEXT',
                               :spacing            => REAL,
                               :line               => true},
                   :footer => {:html => { :template => 'shared/footer.pdf.erb', # use :template OR :url
                                          :layout   => 'pdf_plain.html',        # optional, use 'pdf_plain.html' for a pdf_plain.html.erb file, defaults to main layout
                                          :url      => 'www.example.com',
                                          :locals   => { :foo => @bar }},
                               :center             => 'TEXT',
                               :font_name          => 'NAME',
                               :font_size          => SIZE,
                               :left               => 'TEXT',
                               :right              => 'TEXT',
                               :spacing            => REAL,
                               :line               => true},
                   :outline => {:outline           => true,
                                :outline_depth     => LEVEL}
          end
        end
      end
    end

By default, it will render without a layout (:layout => false) and the template for the current controller and action.

### Super Advanced Usage ###

If you need to just create a pdf and not display it:

    # create a pdf from a string
    pdf = Wisepdf::Writer.new.to_pdf('<h1>Hello There!</h1>')
		
    # or from your controller, using views & templates and all other options as normal
    pdf = render_to_string :pdf => "some_file_name"
		
    # then save to a file
    save_path = Rails.root.join('pdfs','filename.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end

If you need to display utf encoded characters, add this to your pdf views or layouts:

    <meta http-equiv="content-type" content="text/html; charset=utf-8" />

### Styles

You must define absolute paths to CSS files, images, and javascripts; the best option is to use the *wisepdf_stylesheet_tag*, *wisepdf_image_tag*, and *wisepdf_javascript_tag* helpers.

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <%= wisepdf_stylesheet_tag "pdf" -%>
        <%= wisepdf_javascript_tag "number_pages" %>
      </head>
      <body onload='number_pages'>
        <div id="header">
          <%= wisepdf_image_tag 'mysite.jpg' %>
        </div>
        <div id="content">
          <%= yield %>
        </div>
      </body>
    </html>

### Page Numbering

A bit of javascript can help you number your pages. Create a template or header/footer file with this:

    <html>
      <head>
        <script>
          function number_pages() {
            var vars={};
            var x=document.location.search.substring(1).split('&');
            for(var i in x) {var z=x[i].split('=',2);vars[z[0]] = unescape(z[1]);}
            var x=['frompage','topage','page','webpage','section','subsection','subsubsection'];
            for(var i in x) {
              var y = document.getElementsByClassName(x[i]);
              for(var j=0; j<y.length; ++j) y[j].textContent = vars[x[i]];
            }
          }
        </script>
      </head>
      <body onload="number_pages()">
        Page <span class="page"></span> of <span class="topage"></span>
      </body>
    </html>

Anything with a class listed in "var x" above will be auto-filled at render time.

If you do not have explicit page breaks (and therefore do not have any "page" class), you can also use wkhtmltopdf's built in page number generation by setting one of the headers to "[page]":

    render :pdf => 'filename', :header => { :right => '[page] of [topage]' }

### Configuration

You can put your default configuration, applied to all pdf's at "configure_wisepdf.rb" initializer.

    Wisepdf::Configuration.configure do |c|
      c.wkhtmltopdf = '/path/to/wkhtmltopdf'
      c.options = {
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
      

### Debugging

You can use a debug param on the URL that shows you the content of the pdf in plain html to design it faster.

First of all you must configure the render parameter `:show_as_html => params[:debug]` and then just use it like normally but adding `debug=1` as a param:

    http://localhost:3001/CONTROLLER/X.pdf?debug=1

However, the wisepdf_* helpers will use file:// paths for assets when using :show_as_html, and your browser's cross-domain safety feature will kick in, and not render them. To get around this, you can load your assets like so in your templates:

    <%= params[:debug].present? ? image_tag('foo') : wisepdf_image_tag('foo') %>

## Production?  

**wisepdf** is used at:

* [www.sdelki.ru](http://www.sdelki.ru)
* [www.lienlog.com](http://www.lienlog.com)

Know other projects? Then contact me and I will add them to the list.

## Note on Patches / Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Credits

![JetRockets](http://www.jetrockets.ru/public/logo.png)

Wisepsd is maintained by [JetRockets](http://www.jetrockets.ru/en).

Contributors:

* [Igor Alexandrov](http://igor-alexandrov.github.com/)
* [Alexey Solilin](https://github.com/solilin)

## License

It is free software, and may be redistributed under the terms specified in the LICENSE file.
