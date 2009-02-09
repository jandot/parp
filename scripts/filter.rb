#!/usr/bin/ruby
DISTANCE = 250

@readpairs = Array.new
@clusters = Array.new

class ReadPair
  attr_accessor :from_chr, :from_pos, :to_chr,  :to_pos
end

class Cluster
  attr_accessor :chr, :start, :stop, :readpairs
end

#create clusters
ARGF.sort.each do |line|
  chr1, pos1, chr2, pos2, code, qual = line.chomp.split(/\t/)
  STDERR.puts chr1 + "\t" + pos1
end

#link clusters