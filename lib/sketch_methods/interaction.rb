class MySketch < Processing::App
  def mouse_moved
    @current_slice = @slices.sort_by{|s| s.start_pixel}.select{|s| s.start_pixel <= self.pixel_under_mouse}[-1]
    @chromosome_under_mouse, @base_under_mouse = self.find_position_under_mouse
    @formatted_position_under_mouse = @chromosome_under_mouse.nil? ? '' : [@chromosome_under_mouse, @base_under_mouse.format].join(':')
    redraw
  end

  def mouse_clicked
    if (@radius..@radius+10).include?(dist(mouse_x, mouse_y, @origin_x, @origin_y))
      Slice.add(self.pixel_under_mouse.pixel_to_cumulative_bp, 5_000_000)
      redraw
    end
  end

  def key_pressed
    if key == 'r' #reset
      @slices = Array.new
      @slices.push(Slice.new)

      @buffer_images[:zoomed] = self.draw_zoomed_buffer
      @buffer_images[:information_panel] = self.draw_information_panel
      redraw
    elsif key == 'b' #back
      if @history.length > 1
        @history.pop
        @slices = Array.new
        @slices = @history.pop

        @buffer_images[:zoomed] = self.draw_zoomed_buffer
        @buffer_images[:information_panel] = self.draw_information_panel
        redraw
      end
    elsif key == 'f' #toggle fixed
      @current_slice.fixed = !@current_slice.fixed
      @buffer_images[:information_panel] = self.draw_information_panel
      redraw
    elsif key == 'c' #collapse
      @current_slice.collapse
      redraw
    elsif key_code
      if key_code == LEFT
        @current_slice.pan(:left)
        redraw
      elsif key_code == RIGHT
        @current_slice.pan(:right)
        redraw
      elsif key_code == UP
        @current_slice.zoom(5)
        redraw
      elsif key_code == DOWN
        @current_slice.zoom(0.2)
        redraw
      end
    end

    if @history.length == 20
      @history.shift
    end
  end

  def mouse_pressed
    @dragged_slice = nil
    if (@radius+15..@radius+25).include?(dist(mouse_x, mouse_y, @origin_x, @origin_y))
      @slices.reject{|s| s.start_pixel == 1}.each do |slice| # We want to disable this for the first slice
#        STDERR.puts [slice.name, slice.start_pixel, pixel_under_mouse].join("\t")
        if (pixel_under_mouse - slice.start_pixel).abs <= 3
          @dragged_slice = slice
#          STDERR.puts "Clicked on slice " + slice.name
        end
      end
    end
  end

  def mouse_released
    unless @dragged_slice.nil?
      previous_slice = @slices.select{|s| s.stop_pixel < @dragged_slice.start_pixel}.sort_by{|s| s.start_pixel}[-1]
      @dragged_slice.start_pixel = pixel_under_mouse
      previous_slice.stop_pixel = pixel_under_mouse - 1
      [@dragged_slice, previous_slice].each do |slice|
        slice.length_pixel = slice.stop_pixel - slice.start_pixel + 1
        slice.resolution = slice.length_pixel.to_f/slice.length_bp
        slice.range_pixel = Range.new(slice.start_pixel, slice.stop_pixel)
      end
      @dragged_slice = nil

      @buffer_images[:zoomed] = self.draw_zoomed_buffer
      @buffer_images[:information_panel] = self.draw_information_panel
      redraw
    end
  end
end