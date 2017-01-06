require 'rugged'

# this gets a list of all the blob objects along with their filename, can use that to allow user to search by filename!
#$ git rev-list --objects --all | git cat-file --batch-check='%(objectname) %(objecttype) %(rest)' | grep '^[^ ]* blob' | cut -d" " -f1,3-
#
result = system("git rev-list --objects --all | git cat-file --batch-check='%(objectname) %(objecttype) %(rest)'")
p result
# then run grep on the result to only select the blobs 

repo = Rugged::Repository.new('.')
walker = Rugged::Walker.new(repo)
walker.sorting(Rugged::SORT_DATE)
walker.push(repo.last_commit)
walker.each_oid do |c| 
  p c
end

#commits = []
#walker.each do |o|
#  commits << o
#end

#p "all commits"
#p commits
#                @commits = commits
#
p walker.to_a
p walker.to_h
p walker.entries
p walker.methods

#all = `git rev-list --objects --all`  
#system(all + " | " + "git cat-file --batch-check='%(objectname) %(objecttype) %(rest)'")
#| grep '^[^ ]* blob' | cut -d" " -f1,3-")

