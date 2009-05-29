class MySketch < Processing::App
  def mouse_moved
#    STDERR.puts angle(mouse_x, mouse_y, @origin_x, @origin_y).to_s
    
    @chromosome_under_mouse, @base_under_mouse = self.find_position_under_mouse
    @formatted_position_under_mouse = [@chromosome_under_mouse, @base_under_mouse.format].join(':')
#    STDERR.puts @formatted_position_under_mouse
    redraw
  end

#  def mouse_clicked
#    focus = angle(mouse_x, mouse_y, width/2, height/2)
#    STDERR.puts "MOUSE IS CLICKED ON " + focus.to_s
##    @lenses.push Lens.new(focus, 30, 0, 0.05)
#    self.draw_zoomed_buffer
#    STDERR.puts "BUFFER IS FINISHED"
#    redraw
#  end

  def key_pressed
    if key == 'r' #reset
      @lenses = Array.new
      Lens.initialize_matrix
      self.draw_zoomed_buffer
      redraw
    end
  end
end