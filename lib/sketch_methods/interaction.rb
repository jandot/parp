class MySketch < Processing::App

  def mouse_moved
    unless mouse_dragged
      @current_slice = @slices.sort_by{|s| s.start_pixel}.select{|s| s.start_pixel <= self.pixel_under_mouse}[-1]
      @chromosome_under_mouse, @base_under_mouse = self.find_position_under_mouse
      @formatted_position_under_mouse = @chromosome_under_mouse.nil? ? '' : [@chromosome_under_mouse, @base_under_mouse.format].join(':')
      redraw
    end
  end

  def mouse_pressed
    @dragged_slice = nil
    @selected_pixel = nil
    case mouse_button
    when LEFT then
      if (@radius-10..@radius+10).include?(dist(mouse_x, mouse_y, @origin_x, @origin_y))
        @user_action = :creating_new_slice
        @selected_pixel = self.pixel_under_mouse
      elsif (@radius+15..@radius+25).include?(dist(mouse_x, mouse_y, @origin_x, @origin_y))
        @slices.reject{|s| s.start_pixel == 1}.each do |slice| # We want to disable this for the first slice
          if (pixel_under_mouse - slice.start_pixel).abs <= 3
            @dragged_slice = slice
            @user_action = :moving_slice_boundary
            loop
          end
        end
      else
        @selected_pixel = self.pixel_under_mouse
        @current_slice = @slices.sort_by{|s| s.start_pixel}.select{|s| s.start_pixel <= self.pixel_under_mouse}[-1]
        @user_action = :panning_slice
      end
    when RIGHT then
      @right_mouse_click_menu_visible = true
      @user_action = :wanting_to_show_menu
    end
  end

  def mouse_released
    case @user_action
    when :creating_new_slice then
      if self.pixel_under_mouse == @selected_pixel # We want to emulate "click": mouse should not have moved between press and release
        length_bp =(@current_slice.length_bp.to_f/100).round
        Slice.add(self.pixel_under_mouse.pixel_to_cumulative_bp, length_bp)
        redraw
      end
    when :moving_slice_boundary then
      previous_slice = @slices.select{|s| s.stop_pixel < @dragged_slice.start_pixel}.sort_by{|s| s.start_pixel}[-1]
      @dragged_slice.start_pixel = pixel_under_mouse
      previous_slice.stop_pixel = pixel_under_mouse - 1
      [@dragged_slice, previous_slice].each do |slice|
        slice.length_pixel = slice.stop_pixel - slice.start_pixel + 1
        slice.resolution = slice.length_pixel.to_f/slice.length_bp
        slice.range_pixel = Range.new(slice.start_pixel, slice.stop_pixel)
      end
      @dragged_slice = nil
      no_loop

      @buffer_images[:zoomed] = self.draw_zoomed_buffer
      @buffer_images[:information_panel] = self.draw_information_panel
    when :panning_slice then
      delta_pixel = self.pixel_under_mouse - @selected_pixel
      @current_slice.pan(:left, (delta_pixel.to_f/@current_slice.resolution).round)
      @selected_pixel = nil
    end
    @user_action = nil
    redraw
  end
  
  def key_pressed
    if key == 'r' #reset
      @slices = Array.new
      @slices.push(Slice.new)

      @right_mouse_click_menu_visible = false

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
      if @right_mouse_click_menu_visible
        if key_code == ESC
          @right_mouse_click_menu_visible = false
        end
      elsif key_code == LEFT
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
end