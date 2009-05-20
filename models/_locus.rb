class Float
  def adjust_zoom(sketch)
    new_degree = self
    if self > (sketch.focus_degree - sketch.range_degree) and self < (sketch.focus_degree + sketch.range_degree)
#      if ( sketch.mouse_x < sketch.width - 50 )
        delta_degree = self - sketch.focus_degree
        input_value = sketch.map(delta_degree, -sketch.range_degree, sketch.range_degree, -5, 5)
        delta_degree = sketch.n.cumulativeProbability(input_value)
        delta_degree = sketch.map(delta_degree, sketch.n.cumulativeProbability(-5), sketch.n.cumulativeProbability(5), -sketch.range_degree, sketch.range_degree)
        new_degree = sketch.focus_degree + delta_degree
#      end
    end
    return new_degree
  end
end

module IsLocus
#  def calculate_degrees(display)
#    if self.respond_to?('degree')
#      @degree[display] = self.class.sketch.map(@pos, @chr.start_bp, @chr.stop_bp, @chr.start_degree[display], @chr.stop_degree[display])
#      @degree[display] = @degree[display].adjust_zoom(self.class.sketch)
#    else
#      @start_degree[display] = [@slices[display].start_degree[display], self.class.sketch.map(@start, @slices[display].start_bp, @slices[display].stop_bp, @slices[display].start_degree[display], @slices[display].stop_degree[display])].max
#      @stop_degree[display] = [@slices[display].stop_degree[display], self.class.sketch.map(@stop, @slices[display].start_bp, @slices[display].stop_bp, @slices[display].start_degree[display], @slices[display].stop_degree[display])].min
#
#      old = @start_degree[display]
#      @start_degree[display] = @start_degree[display].adjust_zoom(self.class.sketch)
#      @stop_degree[display] = @stop_degree[display].adjust_zoom(self.class.sketch)
#
#    end
#  end

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