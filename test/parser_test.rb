class ParserTest < Test::Unit::TestCase    
  context "Options normalization" do
    setup do
      Wisepdf::Configuration.reset!
      
      @options = { Wisepdf::Parser::ESCAPED_OPTIONS.sample => 'value' }
    end
            
    should 'escape and parse digit options' do
      @options.merge!({
        :key => 10
      })
      expected = {
        '--key' => '10'
      }
      
      assert_equal expected, Wisepdf::Parser.parse(@options)
    end
    
    should 'escape and parse string options' do
      @options.merge!({
        :key => 'value'
      })
      expected = {
        '--key' => 'value'
      }
      
      assert_equal expected, Wisepdf::Parser.parse(@options)
    end
    
    should 'escape and parse boolean (true) options' do
      @options.merge!({
        :key => true
      })
      expected = {
        '--key' => nil
      }
      
      assert_equal expected, Wisepdf::Parser.parse(@options)
    end
    
    should 'escape and parse boolean (false) options' do
      @options.merge!({
        :key => false
      })
      expected = {}
      
      assert_equal expected, Wisepdf::Parser.parse(@options)
    end
    
    should 'escape and parse nested options' do
      @options.merge!({
        :key => 'value',
        :nested => {
          :key => 'value'
        }
      })
      expected = {
        '--key' => 'value',
        '--nested-key' => 'value'
      }
      
      assert_equal expected, Wisepdf::Parser.parse(@options)
    end    
  end
end