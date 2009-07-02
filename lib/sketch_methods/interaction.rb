class MySketch < Processing::App
  def mouse_moved

    @current_slice = @slices.sort_by{|s| s.start_pixel}.select{|s| s.start_pixel <= self.pixel_under_mouse}[-1]
    @chromosome_under_mouse, @base_under_mouse = self.find_position_under_mouse
    @formatted_position_under_mouse = @current_slice.nil? ? '' : [@chromosome_under_mouse, @base_under_mouse.format].join(':')
    redraw
  end

  def mouse_clicked
    Slice.add(self.pixel_under_mouse.pixel_to_cumulative_bp, 5_000_000)

    @buffer_images[:zoomed] = self.draw_zoomed_buffer
    @buffer_images[:information_panel] = self.draw_information_panel

    redraw
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
      @buffer_images[:zoomed] = self.draw_zoomed_buffer
      @buffer_images[:information_panel] = self.draw_information_panel
      redraw
    elsif key_code
      if key_code == LEFT
        @current_slice.pan(10)
        @buffer_images[:zoomed] = self.draw_zoomed_buffer
        @buffer_images[:information_panel] = self.draw_information_panel
        redraw
      elsif key_code == RIGHT
        @current_slice.pan(10, :right)
        @buffer_images[:zoomed] = self.draw_zoomed_buffer
        @buffer_images[:information_panel] = self.draw_information_panel
        redraw
      elsif key_code == UP
        @current_slice.zoom(5)
        @buffer_images[:zoomed] = self.draw_zoomed_buffer
        @buffer_images[:information_panel] = self.draw_information_panel
        redraw
      elsif key_code == DOWN
        @current_slice.zoom(0.2)
        @buffer_images[:zoomed] = self.draw_zoomed_buffer
        @buffer_images[:information_panel] = self.draw_information_panel
        redraw
      end
    end

    if @history.length == 20
      @history.shift
    end
  end
end