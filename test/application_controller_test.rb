require 'helper'
 
class ApplicationControllerTest < ActionController::TestCase
  tests ApplicationController
 
  context "The controller" do
    setup do
      module Wisepdf::Render
        public :make_pdf
        public :make_and_send_pdf
        public :prerender_header_and_footer
      end
    end
    
    should "respond to #make_pdf" do
      assert_respond_to @controller, :make_pdf
    end
    
    should "respond to #make_and_send_pdf" do
      assert_respond_to @controller, :make_and_send_pdf
    end    
    
    should "respond to #prerender_header_and_footer" do
      assert_respond_to @controller, :prerender_header_and_footer
    end        
    
    should 'render pdf' do
      get :index, :format => :pdf
      assert_response 200
    end
  end
end