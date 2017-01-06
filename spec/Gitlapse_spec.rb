require_relative 'spec_helper'
require 'rugged'
#TODO rugged stuff should be refactored out into an external mushin-ext to be used with others as well.
#TODO developing exts is like developing methods, first you put all one place then refactor out based on common sense.

describe "Gitlapse" do
  before do
    #`rm -rf  DATA` #NOTE flush all previous test data
    @env 		= Hash.new
    @slug 		= "pengwynn/pingwynn"
    @clone_url 		= "https://github.com/#{@slug}.git"
    @local_repo_path 	= ("./DATA/#{@slug}")
  end

  after do
    `rm -rf  DATA` #NOTE flush all previous test data
  end

  it 'makes a single_lapse via taking two blob_shas and returns the contents of their gitlapse' do 
    start_blob_sha 	= "a48ef87480c687bb698d5b44c9d85842ae7e3c63"
    finish_blob_sha 	= "b495a649e1219b0314116325b25b328a7e6dff7c"


    Rugged::Repository.clone_at(@clone_url, @local_repo_path)
    repo = Rugged::Repository.new(@local_repo_path)
    #@env[:repo_local_path].must_be_nil
    @env[@slug].must_be_nil
    @env[@slug] = repo

    opts 	= {:cqrs => :cqrs_command, :repo => @slug}
    #lapse env[:local_repo_path], env[:start_blob_sha], env[:finish_blob_sha]
    #params 	= {:local_repo_path => @local_repo_path, :start_blob_sha => start_blob_sha, :finish_blob_sha => finish_blob_sha}
    params 	= {:single_lapse => {:start_blob_sha => start_blob_sha, :finish_blob_sha => finish_blob_sha}}
    @ext 	= Gitlapse::Ext.new(Proc.new {}, opts, params)

    #@env[:repo_local_path] = ""
    #@env[:start_blob_sha] = ""
    #@env[:finish_blob_sha] = ""
    p "env is "
    p @env
    @ext.call(@env)
    #@env[:lapse_meta].must_equal "this test works"
    #@env[:lapse_content].must_equal "this test works"

    #@blob_sha = ""
    #blob = repo.lookup params[:sha]
  end


  it 'makes a multiple_lapses via taking an array of start_blobs & finish_blobs and returns a hash of their contents of their gitlapses' do 
    skip
    start_blob_sha 	= "a48ef87480c687bb698d5b44c9d85842ae7e3c63"
    finish_blob_sha 	= "b495a649e1219b0314116325b25b328a7e6dff7c"

    Rugged::Repository.clone_at(@clone_url, @local_repo_path)
    repo = Rugged::Repository.new(@local_repo_path)

    opts 	= {:cqrs => :cqrs_command}
    params 	= {:multiple_lapses => [{:start_blob_sha => start_blob_sha, :finish_blob_sha => finish_blob_sha}]}
    @ext 	= Gitlapse::Ext.new(Proc.new {}, opts, params)

    @env[:repo_local_path].must_be_nil
    p "env is "
    p @env
    @ext.call(@env)
    p @env
  end


  it 'takes a commit, and a path to a file, then returns all its lapses' do 
    # lapses is a recursive problem, to solve its smallest form all 
    # that is needed is the latest commit whatever it was and a path to a file.
    # then we go check if this same path exists (matches a blob) in the previous 
    # commit(parent commit) if yes then we grap the blob_id that corponds to the 
    # file path in the current commit and in the previous commit and build the lapse. 
    # Using this algorithm, the user interface can traverse over the whole repo in 
    # any branch with ease, but we opt to let the mainpulation done via the interface 
    # to keep the implmentation simple from the numerous usecases were full lapses of 
    # all branches of the whole repo is needed, etc.
  end

end
