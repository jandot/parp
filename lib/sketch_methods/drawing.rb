class MySketch < Processing::App
  def draw_zoomed_buffer
    # We're adding the existing slices to the history here.
    # For some reason we can't do @history.push(@slices), or even
    # a @history.push(@slices.clone). We have to loop over all current slices
    # individually.
    @history.push(Array.new)
    @slices.each do |slice|
      @history[-1].push(slice.clone)
    end

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

  def draw_information_panel
    buffer_information_panel = buffer(300, self.height, JAVA2D) do |b|
      b.background 255
      b.smooth

      b.fill 250
      b.no_stroke
      b.rect 20,20,b.width-40,b.height-40

      x = 20
      y = 20
      b.text_font @f16
      b.fill 0
      y += text_ascent
      b.text "Slices:", x, y
      b.line x, y+3, x+text_width("Slices:"), y+3
      b.text_font @f12
      x += 10
      @slices.each do |slice|
        start_chr, start_pos = slice.start_cumulative_bp.cumulative_bp_to_chr_bp
        start_text = start_chr.name + ':' + start_pos.format
        stop_chr, stop_pos = slice.stop_cumulative_bp.cumulative_bp_to_chr_bp
        stop_text = stop_chr.name + ':' + stop_pos.format

        y += text_ascent + 5
        b.text "Slice", x, y
        b.fill slice.colour
        b.rect(x + text_width("Slice "), y - text_ascent, text_ascent, text_ascent)
        b.fill 0
        x += 5
        y += text_ascent + 3
        b.text "Locus = " + start_text + '-' + stop_text, x, y
        y += text_ascent + 3
        b.text  "Length (bp) = " + slice.length_bp.format, x, y
        y += text_ascent + 3
        b.text  "Pixel range = " + slice.start_pixel.format + '-' + slice.stop_pixel.format, x, y
        y += text_ascent + 3
        b.text  "Length (pixel) = " + slice.length_pixel.format, x, y
        y += text_ascent + 3
        b.text  "Resolution = " + slice.formatted_resolution, x, y
        y += text_ascent + 3
        b.text "Fixed? = " + slice.fixed.to_s, x, y
        x -= 5
      end
    end
    return buffer_information_panel.get(0,0,buffer_information_panel.width, buffer_information_panel.height)
  end

  def draw_line_following_mouse
    if dist(@origin_x, @origin_y, mouse_x, mouse_y) < @radius*1.1
      stroke 100
      line @origin_x, @origin_y, cx(angle(mouse_x, mouse_y, @origin_x, @origin_y), @radius*1.1, @origin_x), cy(angle(mouse_x, mouse_y, @origin_x, @origin_y), @radius*1.1, @origin_y)
      unless @current_slice.nil?
        text_font @f16
        fill 255, 200
        no_stroke
        rect mouse_x, mouse_y, [text_width(@current_slice.formatted_resolution),text_width(@formatted_position_under_mouse)].max + 10, 2*text_ascent + 10
        fill 0
        text @formatted_position_under_mouse, mouse_x + 5, text_ascent + mouse_y + 5
        text @current_slice.formatted_resolution, mouse_x + 5, mouse_y + 5 + 2*text_ascent
#        text "pixel: " + self.pixel_under_mouse.to_s, mouse_x + 5, mouse_y + 5 + 3*text_ascent
#        text "cumul bp: " + self.pixel_under_mouse.to_f.pixel_to_cumulative_bp.to_s, mouse_x + 5, mouse_y + 5 + 4*text_ascent
        text_font @f12
      end
    end
  end
end
