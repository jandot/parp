module IsLocus
  def calculate_degree(display)
    if self.respond_to?('degree')
      @degree[display] = self.class.sketch.map(@pos, @slices[display].start_bp, @slices[display].stop_bp, @slices[display].start_degree[display], @slices[display].stop_degree[display])
    else
      @start_degree[display] = [@slices[display].start_degree[display], self.class.sketch.map(@start, @slices[display].start_bp, @slices[display].stop_bp, @slices[display].start_degree[display], @slices[display].stop_degree[display])].max
      @stop_degree[display] = [@slices[display].stop_degree[display], self.class.sketch.map(@stop, @slices[display].start_bp, @slices[display].stop_bp, @slices[display].start_degree[display], @slices[display].stop_degree[display])].min
    end
  end
end