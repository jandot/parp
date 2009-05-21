class MySketch < Processing::App
  def draw_zoomed_buffer
    buffer_zoomed = buffer(self.width, self.height, JAVA2D) do |b|
      b.background 255
      b.smooth
      b.translate(self.width/2, self.height/2)
      @chromosomes.values.each do |chr|
        chr.draw(b)
      end
      @readpairs.each do |readpair|
        readpair.draw(b)
      end
      Lens.draw(b)
      b.translate(-self.width/2, -self.height/2)
      @lenses.each do |lens|
        STDERR.puts lens.to_s
      end
    end
    @buffer_images[:zoomed] = buffer_zoomed.get(0, 0, buffer_zoomed.width, buffer_zoomed.height)
  end

  def draw_line_following_mouse
    if dist(width/2, height/2, mouse_x, mouse_y) < @radius*1.1
      stroke 100
      line width/2, height/2, cx(angle(mouse_x, mouse_y, width/2, height/2), @radius*1.1, width/2), cy(angle(mouse_x, mouse_y, width/2, height/2), @radius*1.1, height/2)
#      text_font @big_f
#      fill 255, 200
#      no_stroke
#      rect mouse_x, mouse_y - text_ascent, text_width(@formatted_position) + 10, text_ascent + 10
#      fill 0
#      text @formatted_position, mouse_x + 5, mouse_y + 5
#      text_font @f
    end
  end
end