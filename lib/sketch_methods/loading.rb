class MySketch < Processing::App
  def load_chromosomes
    @chromosomes = Hash.new
    File.open(@data_directory + '/meta_data.tsv').each do |line|
      chr, len, centr_start, centr_stop = line.chomp.split("\t")
      @chromosomes[chr] = Chromosome.new(chr, len.to_i, centr_start.to_i)
    end
  end

  def load_readpairs
    @readpairs = Array.new
    File.open(@data_directory + '/read_pairs.txt').each do |line|
      from_chr, from_pos, to_chr, to_pos, code, qual = line.chomp.split("\t")
      @readpairs.push(ReadPair.new(from_chr, from_pos, to_chr, to_pos, code, qual))
    end

    @chromosomes.values.each do |chr|
      chr.reads = chr.reads.sort_by{|r| r.as_string}
    end
    all_qualities = @readpairs.collect{|rp| rp.qual}
    @min_qual = all_qualities.min
    @max_qual = all_qualities.max
  end

  def load_copy_numbers
    File.open(@data_directory + '/copy_number.txt').each do |line|
      chr, start, stop, value = line.chomp.split("\t")
      CopyNumber.new(chr, start, stop, value)
    end

    @chromosomes.values.each do |chr|
      chr.copy_numbers = chr.copy_numbers.sort_by{|cn| cn.as_string}
    end
  end

  def load_segdups
    File.open(@data_directory + '/segdups.txt').each do |line|
      chr, start, stop = line.chomp.split("\t")
      SegDup.new(chr, start, stop)
    end

    @chromosomes.values.each do |chr|
      chr.segdups = chr.segdups.sort_by{|sd| sd.as_string}
    end
  end

  def load_genes
    File.open(@data_directory + '/genes.tsv').each do |line|
      name, chr, start, stop = line.chomp.split("\t")
      Gene.new(name, chr, start, stop)
    end

    @chromosomes.values.each do |chr|
      chr.genes = chr.genes.sort_by{|sd| sd.as_string}
    end
  end
end