module Roadmap
   def get_roadmap_id
      me = self.get_me
      roadmap_id = me["current_program_module"]["roadmap_id"]
   end

   def get_roadmap(roadmap_id)
      url = '/roadmaps/' + roadmap_id.to_s
      response = self.class.get(url, headers: { "authorization" => @auth_token}, body: { id: roadmap_id })
      JSON.parse response.body
   end

   def get_checkpoint(checkpoint_id)
      url = '/checkpoints/' + checkpoint_id.to_s
      response = self.class.get(url, headers: { "authorization" => @auth_token}, body: { id: checkpoint_id })
      JSON.parse response.body
   end
end
