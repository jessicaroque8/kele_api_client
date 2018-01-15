require 'httparty'
require 'json'
require 'roadmap'

class Kele
   include HTTParty
   include Roadmap
   base_uri 'https://www.bloc.io/api/v1'

   def initialize(email, password)
      response = self.class.post(
         '/sessions',
         body: { "email" => email, "password" => password }
      )
      @auth_token = response["auth_token"]

      case response.code
         when 404
            puts "A user with that username was not found."
         when 401
            puts "Invalid username and password combination."
      end
   end

   def get_me
      response = self.class.get(
         '/users/me',
         headers: { "authorization" => @auth_token }
      )
      JSON.parse response.body
   end

   def get_mentor_id
      me = self.get_me
      mentor_id = me["current_enrollment"]["mentor_id"]
   end

   def get_mentor_availability(mentor_id)
      url = '/mentors/' + mentor_id.to_s + '/student_availability'
      response = self.class.get(
         url,
         headers: { "authorization" => @auth_token },
         body: { "id" => mentor_id }
      )
      JSON.parse response.body
   end

   def get_messages(p = nil)
      if p.nil?
         puts 'Getting all messages...'
         all_msgs = []
         first_page = self.class.get(
            '/message_threads',
            headers: { "authorization" => @auth_token },
            body: { "page" => 1 }
         )
         first_msgs = JSON.parse(first_page.body)
         all_msgs << first_msgs

         iterations = (first_msgs["count"].to_f/10).ceil - 1

         iterations.times do |n|
            next_page = self.class.get(
               '/message_threads',
               headers: { "authorization" => @auth_token },
               body: { "page" => n + 2 }
            )
            all_msgs << JSON.parse(next_page.body)
         end

         all_msgs
      else
         puts 'Getting messages on page ' + p.to_s + ' ...'
         response = self.class.get(
            '/message_threads',
            headers: { "authorization" => @auth_token },
            body: { "page" => p }
         )
         JSON.parse(response.body)
      end
   end

   def create_message(recipient_id, token = nil, subject, message)
      me = self.get_me
      email = me["email"]

      if token.nil?
         response = self.class.post(
            '/messages',
            headers: { "authorization" => @auth_token },
            body: { "sender" => email, "recipient_id" => recipient_id, "subject" => subject, "stripped-text" => message }
         )

      else
         response = self.class.post(
            '/messages',
            headers: { "authorization" => @auth_token },
            body: { "sender" => email, "recipient_id" => recipient_id, "token" => token, "subject" => subject, "stripped-text" => message }
         )
      end

      if response.code == 200
         "Message sent successfully."
      else
         "There was an error when sending that message."
      end
   end

end
