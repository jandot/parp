#!/usr/bin/ruby
DISTANCE = 250

@readpairs = Array.new
@from_clusters = Array.new
@to_clusters = Array.new

class ReadPair
  attr_accessor :from_chr, :from_pos, :to_chr, :to_pos, :code, :qual
  def initialize(from_chr, from_pos, to_chr, to_pos, code, qual)
    @from_chr, @from_pos, @to_chr, @to_pos, @code, @qual =
      from_chr, from_pos, to_chr, to_pos, code, qual
  end
end

class Cluster
  attr_accessor :chr, :start, :stop, :readpairs
end

#create clusters
ARGF.sort.each do |line|
  fields = line.chomp.split(/\t/)
  @readpairs.push(ReadPair.new(*fields))
end

#link clusters
@readpairs.each
STDERR.puts @readpairs.length