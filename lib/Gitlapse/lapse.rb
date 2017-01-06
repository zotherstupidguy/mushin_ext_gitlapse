require 'rugged'
#require 'find'
#require 'ssd' #include SSD
require 'base64'
require 'json'

module Gitlapse 

  class Lapse

    attr_accessor :host,
      :start_blob,
      :finish_blob,

      :patch,

      :line_additions_count,
      :line_deletions_count,

      :lines,
      :data,

      :local_path

    #TODO generate hunk lapses, that way a lapse has a meta.json file that contain paths to all the hunk json files\lapses

    def info
    end

    # generates and stores meta.json file
    def meta
      @patch = @start_blob.diff(@finish_blob)
      @line_additions_count = @patch.additions
      @line_deletions_count = @patch.deletions

      # Populate data{} hash with all the lines in the rugged patch object
      @data 	= {}
      @lines 	= []

      @separator = Random.new_seed
      p "separator: #{@separator}"

      @patch.each_hunk do |hunk|
	hunk.each_line do |line|
	  content = encode(line.content)

	  p @encoding = content.encoding
	  #ec = Encoding::Converter.new(@encoding, "utf-8")
	  #p ec.convert(content).dump     #=> "\xA4\xA2"
	  #p content =  ec.finish.dump                #=> ""

	  #p line.content.force_encoding(Encoding.default_external) 
	  if line.deletion? then
	    @lines << {"operation":"deletion", "number": line.old_lineno.to_s, "content": content}
	  end
	  if line.addition? then
	    @lines << {"operation":"addition", "number": line.new_lineno.to_s, "content": content}
	  end
	  #p @encoding = content.to_s.encoding
	end
      end
      #p @data
      #p @lines
      # build the data hash and turn it into json
      #Encoding.default_external = Encoding::UTF_8
      p @data[:seperator] = @seperator
      p @data[:start_blob_content] = encode(@start_blob.content)
      p @data[:blob_language] = "ruby"
      p @data[:lines] = @lines
      p "data"
      p @data
      p "data.json"
      p @data.to_json
      #p "base64 encoded data.json"
      #p @encoded_data = encode(@data.to_json)

      #FileUtils::mkdir_p "./DATA/#{@host.user.login}/#{"lapses/"}" 
      FileUtils::mkdir_p "./DATA/#{"lapses/"}" 
      #@local_path = "./DATA/#{@host.user.login}/#{"lapses/"}#{@start_blob.oid.to_s + "_" + @finish_blob.oid.to_s}"
      @local_path = "./DATA/#{"lapses/"}#{@start_blob.oid.to_s + "_" + @finish_blob.oid.to_s}"
      @local_meta_path = @local_path + ".json"

      # JSON's primitive values are strings, numbers, and the keywords true, false, and null.
      File.open(@local_meta_path, 'w') do |f|
	f.puts JSON.pretty_generate(@data)
      end
    end

    def to_json
      return (@data.to_json)
    end

    def content
      #@local_path = "./DATA/#{"lapses/"}#{@start_blob.oid.to_s + "_" + @finish_blob.oid.to_s}"
      return (File.open(@local_path).read)
    end

    # base64 encoding is used to avoid delimiter collisions 
    # ref: https://en.wikipedia.org/wiki/Delimiter#Delimiter_collision
    # Render a lapse via taking a path to its meta.json file and where to store it save the lapse after rendering done.
    def render 
      meta
      system("ttyrec -e \"emacs -nw --load lib/Gitlapse/render.el  \'#{@local_meta_path}\' \" #{@local_path}")
      #if !@start_blob.binary? and !@finish_blob.binary? then 
      #else
      #p "#####################################################"
      #p "rendering a binary lapse is not permitted!".capitalize
      #p "#####################################################"
      #end
    end

    private 
    def encode value
      #value.force_encoding(Encoding::UTF_8) #doesn't works
      #value.force_encoding("ISO-8859-1").encode("UTF-8") #works for holding encoded data in json format but ttyrec sh hates it
      #Base64.encode64(value) #works json doesn't hate it, ttyrec doesn't hate it, but maybe emacs hates its encoding!?
      Base64.encode64(value.force_encoding("ISO-8859-1").encode("UTF-8")) #works json doesn't hate it, ttyrec doesn't hate and cant tell emacs to only use UTF-8 and decode base64
    end

  end
end
