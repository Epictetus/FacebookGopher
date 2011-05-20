# Copyright (c) 2011 Nicholas Johnson
# http://www.twitter.com/goldfidget
# http://webofawesome.com
# released under the MIT license



class FacebookGopher

  require "net/https"
  require 'crack/json'

  attr_accessor :code, :client_id, :secret, :return_url, :scope, :token

  def initialize(args = {})
    parse_args(args)
  end
  
  def oauth_url(args = {})
    parse_args(args)
    self.validate_args([:client_id,:return_url])
    url = "http://graph.facebook.com/oauth/authorize?client_id=#{self.client_id}&redirect_uri=#{self.return_url}"
    url << "&scope=#{self.scope}" if self.scope
    url
  end

  def get_token(args = {})
    parse_args(args)
    self.validate_args([:client_id,:return_url,:secret,:code])
    host = "graph.facebook.com"
    port = "443"
    request_uri = "/oauth/access_token" +
                  "?client_id=#{client_id}" +
                  "&redirect_uri=#{return_url}" +
                  "&client_secret=#{secret}" +
                  "&code=#{code}"
    http = Net::HTTP.new(host, port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(request_uri)
    response = http.request(request)
    output = response.body.split("&")[0].split("=")
    self.token = output[0] == "access_token" ? output[1] : nil
    return self.token
  end

  def get(graph_path = "me", args = {})
    parse_args(args)
    host = "graph.facebook.com"
    port = "443"
    request_uri = "/#{graph_path}"
    request_uri << "?access_token=#{self.token}" if self.token
    http = Net::HTTP.new(host, port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(request_uri)
    response = http.request(request)
    json = response.body
    return ActiveSupport::JSON.decode(json)
  end
  
  # typical user_hash: {"name"=>"Nicholas Johnson", "timezone"=>1, "gender"=>"male", "id"=>"539828178", "last_name"=>"Johnson", "updated_time"=>"2011-04-27T09:37:13+0000", "verified"=>true, "locale"=>"en_GB", "link"=>"http://www.facebook.com:443/profile.php?id=539828178", "education"=>[{"school"=>{"name"=>"Beauchamp College", "id"=>"108000602566420"}, "type"=>"High School", "year"=>{"name"=>"1994", "id"=>"135676686463386"}}, {"school"=>{"name"=>"University of Edinburgh", "id"=>"108598582497363"}, "concentration"=>[{"name"=>"Artificial Intelligence with Psychology", "id"=>"105789466167731"}], "type"=>"College"}, {"school"=>{"name"=>"Uni. Sussex", "id"=>"102005019841664"}, "concentration"=>[{"name"=>"Computer Science with Artificial Intelligence", "id"=>"197313173628001"}], "type"=>"College", "year"=>{"name"=>"2001", "id"=>"132393000129123"}}], "work"=>[{"employer"=>{"name"=>"Higgidy Pies", "id"=>"101984036517278"}}], "first_name"=>"Nicholas"}  
  def get_facebook_details
    return this.get()
  end
  
  def parse_args(args)
    bad_args = args.keys - self.accepable_args
    raise ArgumentError, "Gopher Doesn't undertand: #{bad_args.inspect}" if bad_args.length > 0
    args.map { |(key, val)| send("#{key}=", val) }
    self.client_id = args[:app_id] if args[:app_id] && !args[:client_id]
  end
  
  def accepable_args()
    [:code, :client_id, :secret, :return_url, :scope, :token]
  end
  
  def validate_args(args)
    args.each do |arg|
      arg_val = send "#{arg}"
      if !arg_val || arg_val == ""
        raise ArgumentError, "Gopher needs: #{arg} to be set to fulfil this request"
      end
    end
  end
  
end
