class MySketch < Processing::App
  def mouse_moved
    redraw
  end

  def mouse_clicked
    button = mouseEvent.get_button
    focus = angle(mouse_x, mouse_y, width/2, height/2)
    STDERR.puts "MOUSE IS CLICKED ON " + focus.to_s
    STDERR.puts "BUTTON WAS NR " + button.to_s
    updating_existing_lens = false
    @lenses.each do |lens|
      if lens.covers?(focus)
        updating_existing_lens = true
        if button == 1
          lens.update(focus)
        else
          lens.update(focus, 1)
        end
      end
    end
    unless updating_existing_lens
      @lenses.push Lens.new(focus, 20, 0, 0.1)
    end
    self.draw_zoomed_buffer
    STDERR.puts "BUFFER IS FINISHED"
    redraw
  end

  def key_pressed
    if key == 'r' #reset
      @lenses = Array.new
      Lens.initialize_matrix
      self.draw_zoomed_buffer
      redraw
#    elsif key_code == SHIFT
#      STDERR.puts "PRESSED SHIFT"
    end
  end
end