prev_chr = 0
prev_pos = 0
prev_line = ''
File.open('trio_NA12892_all.tsv').each do |line|
  line.chomp!
  chr1, pos1, chr2, pos2, code, qual = line.split(/\t/)
  
  if pos2.to_i - prev_pos < 100
    puts prev_line
    puts line
  end

  prev_chr = chr1
  prev_pos = pos1.to_i
  prev_line = line
end

