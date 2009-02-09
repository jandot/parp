#!/usr/bin/ruby
class Chromosome
  attr_accessor :nr, :first_line, :last_line
end

max_value = -999999999
min_value = 999999999

counter = 0
prev_chr = Chromosome.new
prev_chr.nr = 0
File.open('bindepth-500').each do |l|
  counter += 1
  chr, pos, value = l.split(/\t/)
  
  min_value = ( value.to_i < min_value ) ? value.to_i : min_value
  max_value = ( value.to_i > max_value ) ? value.to_i : max_value
  if chr != prev_chr.nr
    prev_chr.last_line = counter - 1
    puts [prev_chr.nr, prev_chr.first_line, prev_chr.last_line].join("\t")
    prev_chr = Chromosome.new
    prev_chr.nr = chr
    prev_chr.first_line = counter
  end 
end
prev_chr.last_line = counter
puts [prev_chr.nr, prev_chr.first_line, prev_chr.last_line].join("\t")

STDERR.puts [min_value, max_value].join(',')
