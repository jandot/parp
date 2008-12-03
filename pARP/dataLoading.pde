void loadChromosomes() {
  String[] rows = loadStrings("meta_data.tsv");
  for ( int i = 0; i < rows.length; i++ ) {
    String[] fields = split(rows[i], TAB);

    Chromosome chr = new Chromosome(int(fields[0]), int(fields[1]), int(fields[2]), int(fields[3]));
    chromosomes.put(int(fields[0]),chr);
  }
  for ( int i = 1; i <= 24; i++ ) {
    Chromosome chr = (Chromosome) chromosomes.get(i);
    chr.calculateRadians();
    chr.addLabel();
  }
}

void loadReadPairs() {
  String[] rows = loadStrings(INPUT_FILE);
  for ( int i = 0; i < rows.length; i++ ) {
    String[] fields = split(rows[i], TAB);

    ReadPair rp;
    if ( fields.length == 5 ) {
      rp = new ReadPair(fields[0], int(fields[1]), fields[2], int(fields[3]), fields[4], 0);
    } else {
      rp = new ReadPair(fields[0], int(fields[1]), fields[2], int(fields[3]), fields[4], int(fields[5]));
    }
    read_pairs.put(rp.id, rp);
  }
  qual_cutoff = int(min_qual);
}

void loadFeatures() {
  String[] rows = loadStrings(FEATURE_FILE);
  for ( int i = 0; i < rows.length; i++ ) {
    String[] fields = split(rows[i], TAB);
    
    Feature f = new Feature(fields[0], int(fields[1]), int(fields[2]));
    features.put(f.id, f);
  }
}

