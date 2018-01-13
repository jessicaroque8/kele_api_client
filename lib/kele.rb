require 'httparty'
require 'json'
require 'roadmap'

class Kele
   include HTTParty
   include Roadmap
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

   def get_me
      response = self.class.get('/users/me', headers: { "authorization" => @auth_token})
      JSON.parse response.body
   end

   def get_mentor_id
      me = self.get_me
      mentor_id = me["current_enrollment"]["mentor_id"]
   end

   def get_mentor_availability(mentor_id)
      url = '/mentors/' + mentor_id.to_s + '/student_availability'
      response = self.class.get(url, headers: { "authorization" => @auth_token}, body: { id: mentor_id })
      JSON.parse response.body
   end

end
