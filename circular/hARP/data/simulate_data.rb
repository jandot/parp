#!/usr/bin/ruby
File.open('meta_data.tsv').each do |line|
  chr_number, size, *rest = line.chomp.split(/\t/);
  (size.to_i/500000).times do |n|
    pos = rand(size)
    distance = rand(10000000)
    lottery = rand(100)
    if lottery < 20
      chr2 = 1 + rand(23)
      puts chr_number + "\t" + pos.to_s + "\t" + chr2.to_s + "\t" + (pos + distance).to_s + "\tDIST"
    end
    if distance > 500
      if (pos + distance) < size.to_i
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
