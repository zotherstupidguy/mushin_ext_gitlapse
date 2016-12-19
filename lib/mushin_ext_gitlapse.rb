      require 'mushin'
      require_relative 'Gitlapse/version'


module Gitlapse
        class Ext 
        using Mushin::Ext 

	def initialize app=nil, opts={}, params={}
	  @app 		= app
	  @opts 	= opts
	  @params 	= params 
	end
	def call env 
	  env ||= Hash.new 
	  # write inbound code
	  if @opts[:cqrs] == :cqrs_query then
	    # write your code here if it is a cqrs query
	  else 
	    # write your code here if it is a cqrs command 
	  end
	  @app.call(env)
	  # write outbound code
	end
      end

end
