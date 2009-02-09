#!/usr/bin/ruby
File.open('Trio-CEU_libSC_NA12892_2.txt').each do |line|
  chr1, pos1, strand, dist, code, qual, one = line.chomp.split(/\t/)
  next if code == '32' or code == '130' or code == '18'
  my_code = nil
  if code == '1'
    my_code = 'FF'
  elsif code == '2'
    my_code = 'DIST'
  elsif code == '4'
    my_code = 'RF'
  elsif code == '8'
    my_code = 'RR'
  end
  puts [chr1, pos1, chr1, (pos1.to_i + dist.to_i), my_code, qual].join("\t")
end
