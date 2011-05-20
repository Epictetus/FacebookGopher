require 'test_helper'
require 'mocha'
require 'webmock/test_unit'

class FacebookGopherTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  
  def test_gopher_can_be_initialised
    gopher = FacebookGopher.new
    assert gopher, "gopher is initialised with no arguments"
    gopher = FacebookGopher.new :code => '1', :client_id => '2', :secret => '3', :return_url => '4', :scope => '5', :token => '6'
    assert gopher, "gopher is initialised with arguments"
    assert_equal gopher.code, '1', "gopher code is instantiated"
    assert_equal gopher.client_id, '2', "gopher client_id is instantiated"
    assert_equal gopher.secret, '3', "gopher secret is instantiated"
    assert_equal gopher.return_url, '4', "gopher return_url is instantiated"
    assert_equal gopher.scope, '5', "gopher scope is instantiated"
    assert_equal gopher.token, '6', "gopher token is instantiated"
  end
  
  def test_gopher_raises_argument_exception_if_incorrectly_initialised
     assert_raise(ArgumentError) do
       FacebookGopher.new :chunky_bacon => '1'
     end
  end
  
  def test_gopher_constructs_oauth_url
    client_id = "123"
    return_url = "http://www.myapp.com/oauth"
    scope = "full_access"
    expected_url = "http://graph.facebook.com/oauth/authorize?client_id=#{client_id}&redirect_uri=#{return_url}"
    gopher = FacebookGopher.new :client_id => client_id, :return_url => return_url
    assert_equal gopher.oauth_url, expected_url, "gopher is able to generate a url without scope"
    gopher = FacebookGopher.new :client_id => client_id, :return_url => return_url, :scope => scope
    assert_equal gopher.oauth_url, expected_url << "&scope=#{scope}", "gopher is able to generate a url with scope"
  end
  
  def test_gopher_fails_to_constructs_oauth_url_if_args_are_not_present
    gopher = FacebookGopher.new
    assert_raise(ArgumentError) do
      gopher.oauth_url
    end
  end
  
  def test_get_token_should_return_a_token
    client_id = "123"
    return_url = "http://www.myapp.com/oauth"
    secret = "456"
    code = "789"
    request_url = "https://graph.facebook.com" +
                  "/oauth/access_token" +
                  "?client_id=#{client_id}" +
                  "&redirect_uri=#{return_url}" +
                  "&client_secret=#{secret}" +
                  "&code=#{code}"
    stub_request(:get, request_url).
    with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "access_token=123", :headers => {})

    gopher = FacebookGopher.new :client_id => client_id, :return_url => return_url, :secret => secret, :code => code
    assert_equal gopher.get_token, "123", "token was returned"
  end
  
  def test_gopher_fails_to_get_token_if_args_are_not_present
    gopher = FacebookGopher.new
    assert_raise(ArgumentError) do
      gopher.get_token
    end
  end
  
  def test_gopher_makes_an_api_call
    token = "123"
    request_url = "https://graph.facebook.com/me?access_token=#{token}"
    return_json = '{"name":"Nicholas Johnson", "timezone":1, "gender":"male"}'
    stub_request(:get, "https://graph.facebook.com/me").
  with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => return_json, :headers => {})

    me = FacebookGopher.new.get
    assert me, "gopher made an API call"
    assert_equal me['name'], "Nicholas Johnson", "gopher retrieved my name"
  end
  
  
end
