#!/usr/bin/ruby
chromosomes = Hash.new
File.open('meta_data.tsv').each do |line|
  chr_number, len, *rest = line.chomp.split(/\t/);
  chromosomes[chr_number] = len.to_i
end

chromosomes.keys.each do |chr|
  chr_number = chr
  len = chromosomes[chr]
  (len/500000).times do |n|
    pos = rand(len)
    distance = rand(1000000)
    lottery = rand(100)
    if lottery < 50
      chr2 = 1 + rand(23)
      if rand(2) == 1
        unless (pos + distance) > len
          puts chr_number + "\t" + (pos + distance).to_s + "\t" + chr2.to_s + "\t" + pos.to_s + "\tDIST"
        end
      else
        unless (pos + distance) > chromosomes[chr2.to_s]
          puts chr_number + "\t" + pos.to_s + "\t" + chr2.to_s + "\t" + (pos + distance).to_s + "\tDIST"
        end
      end
    end
    if distance > 500
      if (pos + distance) < len.to_i
        puts chr_number + "\t" + pos.to_s + "\t" + chr_number + "\t" + (pos + distance).to_s + "\tDIST"
      end
    end
    distance = rand(10000)
    lottery = rand(100)
    if lottery < 50 
      puts chr_number + "\t" + pos.to_s + "\t" + chr_number + "\t" + (pos + distance).to_s + "\tFF"
    else
      puts chr_number + "\t" + pos.to_s + "\t" + chr_number + "\t" + (pos + distance).to_s + "\tRR"
    end
  end

end
