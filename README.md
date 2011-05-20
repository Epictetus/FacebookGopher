# Facebook Gopher #

**A little library that lets you connect to the Facebook Graph API.**

Rather more lightweight than the excellent Facebooker, it helps with Facebook OAuth, provides methods to access the graph API, and gives lots of feedback should you go wrong. Simply instantiate a Gopher, pass it the necessary parameters, and make your call. 

I'm a big fan of staying close to the API, so Gopher doesn't give you too much abstraction. You make your call and you get back a hash to do with as you wish. If your call needs authentication, pass in your token.

It works in Rails 3, but should work in Rails 2 just as well.

##Facebook OAuth

OAuth is a three step process. 

1. First you must direct your user to a facebook page where they authorise your app. 
2. Facebook then redirects back to a URL you provide and passes a code in the URL string. 
3. Finally you swap the code for a token which you can save and use to make API calls.

Gopher helps with steps 1 and 3.

### The OAuth URL method: oauth_url ###

This method returns an oauth url that you can redirect your user to. The user will be validated and Facebook will redirect them to your return URL.

    def new
      gopher = FacebookGopher.new :client_id => @client_id, :redirect_uri => @return_url, :scope => @scope
      redirect_to gopher.oauth_url
    end
  
### Swapping a code for a token with: get_token ###

Before it can be used, you need to swap the code for a token. Facebook Gopher handles this. In your controller, you might do something like:

    def create
      code = params[:code]
      if (code)
        gopher = FacebookGopher.new :code => code, :redirect_uri => @return_url, :app_id => @app_id, :secret => @secret
        @token = gopher.get_token
        # Store the token if you wish and make your API calls using the gopher. Everything is set up.
        redirect_to thanks_path # Thank the user.
      else
        redirect_to no_thanks_path # The user didn't authenticate your app...
      end
    end


## Making API calls ##

Making API calls is easy. The default call simply pulls 'me' returning all the user's details that we are authorised to see.

    gopher = FacebookGopher.new :token => token
    user_data = gopher.get
    
    user_data['name']
    user_data['timezone']
    user_data.inspect
    
You can see any other part of the API, just pass it as a string:
    
    gopher = FacebookGopher.new :token => token
    user_data = gopher.get('me/posts')



## Testing ##

The test suite uses Test::Unit and requires the mocha and webmock gems to work.

## About Me ##

**Copyright (c) 2011 Nicholas Johnson**

http://www.twitter.com/goldfidget

http://webofawesome.com)

Released under the MIT license

Please do feel free to get in touch.