module IsLocus
  def calculate_degrees
    if self.respond_to?('degree')
      @degree = (@chr.start_cumulative_bp + @pos)*BP_TO_DEGREE_FACTOR
    else
      @start_degree = (@chr.start_cumulative_bp + @start)*BP_TO_DEGREE_FACTOR
      @stop_degree = (@chr.start_cumulative_bp + @stop)*BP_TO_DEGREE_FACTOR
    end
  end

  def self.included mod
    class << mod
      def fetch_region(start, stop) #start and stop must be in 05_000123456 format
        chr = self.sketch.chromosomes[start.split(/_/)[0].sub(/^0+/,'')]
        from_index = self.get_index(start)
        to_index = self.get_index(stop) - 1
        if to_index >= from_index
          if self == CopyNumber
            return chr.copy_numbers[[0, from_index - 1].max, to_index - from_index + 2]
          elsif self == SegDup
            return chr.segdups[[0, from_index - 1].max, to_index - from_index + 2]
          elsif self == Read
            return chr.reads[from_index, to_index - from_index + 1]
          end
        else
          return []
        end
      end

      def get_index(value)
        chr = self.sketch.chromosomes[value.split(/_/)[0].sub(/^0+/,'')]
        if self == CopyNumber
          return chr.copy_numbers.collect{|r| r.as_string}.bsearch_lower_boundary{|x| x <=> value}
        elsif self == SegDup
          return chr.segdups.collect{|r| r.as_string}.bsearch_lower_boundary{|x| x <=> value}
        elsif self == Read
          return chr.reads.collect{|r| r.as_string}.bsearch_lower_boundary{|x| x <=> value}
        end
      end
    end
  end
end