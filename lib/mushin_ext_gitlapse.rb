require 'mushin'
require 'rugged' #TODO to be extracted to Ruggy mushin ext
require_relative 'Gitlapse/lapse'
require_relative 'Gitlapse/version'


module Gitlapse
  class Ext 
    using Mushin::Ext 

    def initialize app=nil, opts={}, params={}
      @app 	= app
      @opts 	= opts
      @params 	= params 
    end


    def call env 
      env ||= Hash.new 

      case @opts[:cqrs]
      when :cqrs_query 
	#inbound code
	@app.call(env)
	#outbound code
      when :cqrs_command
	#inbound code

	# env[:lapses] is a hash that contains hashs of hash_id("start_blob_sha"_"finish_blob_sha", start_blob_content, finish_blob_content)
	#lapses(env[:lapses]) 
	# env[:lapses] is a hash that contains hashs of hash_id("start_blob_sha"_"finish_blob_sha", start_blob_content, finish_blob_content, lapse)
	## it is a cqrs_command, must not return value to test, test via a seperate query in the spec!
	#render_lapse(@params[:local_repo_path], @params[:start_blob_sha], @params[:finish_blob_sha])
	#params 	= {:single_lapse => {:start_blob_sha => start_blob_sha, :finish_blob_sha => finish_blob_sha}}
	
	p @params
	p (@params[:single_lapse][:start_blob_sha])
	p (@params[:single_lapse][:finish_blob_sha])
	start_blob_content 	= env[@opts[:repo]].lookup(@params[:single_lapse][:start_blob_sha])
	finish_blob_content 	= env[@opts[:repo]].lookup(@params[:single_lapse][:finish_blob_sha])

	render_lapse(start_blob_content, finish_blob_content)

	#render_lapse(env[:rugged_repo].lookup(@params[:single_lapse][:start_blob_content]), env[:rugged_repo].lookup(@params[:single_lapse][:finish_blob_content]))

	#env[:lapse_meta] 	= @lapse.to_json 
	#env[:lapse_content] 	= @lapse.content
	@app.call(env)
	#outbound code
      else
	raise "you must specifiy if your cqrs call is command or query?"
      end
    end

    def lapses lapses = Hash.new
      lapses.each do |lapse|
	render_lapse(lapse[:start_blob_sha], lapse[:finish_blob_content])
      end
    end

    #def render_lapse local_repo_path, start_blob_sha, finish_blob_sha
    def render_lapse start_blob_content, finish_blob_content
      @lapse 			= Gitlapse::Lapse.new
      #@repo 			= Rugged::Repository.new(local_repo_path)
      #@start_blob    		= @repo.lookup start_blob_sha
      #@finish_blob   		= @repo.lookup finish_blob_sha

      # building the lapse.start_blob & lapse.finish_blob
      @lapse.start_blob 	= start_blob_content 
      @lapse.finish_blob 	= finish_blob_content
      @lapse.render
    end
  end
end

    
=begin
    # lapse duration is an interval of diff between two git blob objects.
    # you give startblob and endblob and rugged.
    # diff is used to get the diff object, configure it and fire emacs based on it.
    # After lapse is stored in DATA/username/repo_name_lapses 
    # with with the schema startblobfirst8SHAnumbers_Endblobfirst4charachters
    # Example 4idf_34x9
    def duration start_blob_sha, finish_blob_sha
      @repo = Rugged::Repository.new(@host.local_repo_path)
      @start_blob               = @repo.lookup start_blob_sha
      @finish_blob              = @repo.lookup finish_blob_sha
      # building the lapse.start_blob & lapse.finish_blob
      @lapse.start_blob, @lapse.finish_blob = @start_blob, @finish_blob
      @lapse.render
      p "duration between #{@lapse.start_blob} & #{@lapse.finish_blob}"
    end 
=end
