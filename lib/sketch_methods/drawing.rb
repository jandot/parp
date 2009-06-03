class MySketch < Processing::App
  def draw_zoomed_buffer
    buffer_zoomed = buffer(self.width, self.height, JAVA2D) do |b|
      b.background 255
      b.smooth

      b.translate(@origin_x, @origin_y)
      @chromosomes.values.each do |chr|
        chr.draw(b)
      end
      @readpairs.each do |readpair|
        readpair.draw(b)
      end
      @slices.sort_by{|s| s.start_cumulative_bp}.each do |slice|
        slice.draw(b)
      end
      b.translate(-@origin_x, -@origin_y)
    end
    return buffer_zoomed.get(0, 0, buffer_zoomed.width, buffer_zoomed.height)
  end

  def draw_line_following_mouse
    if dist(@origin_x, @origin_y, mouse_x, mouse_y) < @radius*1.1
      stroke 100
      line @origin_x, @origin_y, cx(angle(mouse_x, mouse_y, @origin_x, @origin_y), @radius*1.1, @origin_x), cy(angle(mouse_x, mouse_y, @origin_x, @origin_y), @radius*1.1, @origin_y)
      unless @current_slice.nil?
        text_font @big_f
        fill 255, 200
        no_stroke
        rect mouse_x, mouse_y, [text_width(@current_slice.formatted_resolution),text_width(@formatted_position_under_mouse)].max + 10, 2*text_ascent + 10
        fill 0
        text @formatted_position_under_mouse, mouse_x + 5, text_ascent + mouse_y + 5
        text @current_slice.formatted_resolution, mouse_x + 5, mouse_y + 5 + 2*text_ascent
        text "pixel: " + self.pixel_under_mouse.to_s, mouse_x + 5, mouse_y + 5 + 3*text_ascent
        text "cumul bp: " + self.pixel_under_mouse.to_f.pixel_to_cumulative_bp.to_s, mouse_x + 5, mouse_y + 5 + 4*text_ascent
        text_font @f
      end
    end
  end
end
