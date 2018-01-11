require 'httparty'

class Kele
   include HTTParty
   base_uri 'https://www.bloc.io/api/v1'

   def initialize(email, password)
      response = self.class.post('/sessions', body: { email: email, password: password })
      @auth_token = response["auth_token"]

      case response.code
         when 404
            puts "A user with that username was not found."
         when 401
            puts "Invalid username and password combination."
      end
   end
end
