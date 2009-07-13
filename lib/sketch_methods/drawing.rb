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
    buffer_information_panel = buffer(500, self.height, JAVA2D) do |b|
      b.background 255
      b.smooth

      b.fill 250
      b.no_stroke
      b.rect 10,10,b.width-20,b.height-20

      b.text_font @f12
      x = 80
      y = (b.height.to_f/2 - 255).floor
      b.no_fill
      510.times do |number|
        b.stroke 255, number.to_f/2, number.to_f/2
        b.line x, y + number, x + 10, y + number
      end
      b.no_stroke
      b.fill 0
      b.text_align RIGHT
      x = 75
      y = map(Math.log(1), Math.log(1E-6), Math.log(1), b.height.to_f/2 + 255, b.height.to_f/2 - 255)
      b.text "1bp/pixel", x, y + text_ascent.to_f/2
      y = map(Math.log(1E-1), Math.log(1E-6), Math.log(1), b.height.to_f/2 + 255, b.height.to_f/2 - 255)
      b.text "10bp/pixel", x, y + text_ascent.to_f/2
      y = map(Math.log(1E-2), Math.log(1E-6), Math.log(1), b.height.to_f/2 + 255, b.height.to_f/2 - 255)
      b.text "100bp/pixel", x, y + text_ascent.to_f/2
      y = map(Math.log(1E-3), Math.log(1E-6), Math.log(1), b.height.to_f/2 + 255, b.height.to_f/2 - 255)
      b.text "1kb/pixel", x, y + text_ascent.to_f/2
      y = map(Math.log(1E-4), Math.log(1E-6), Math.log(1), b.height.to_f/2 + 255, b.height.to_f/2 - 255)
      b.text "10kb/pixel", x, y + text_ascent.to_f/2
      y = map(Math.log(1E-5), Math.log(1E-6), Math.log(1), b.height.to_f/2 + 255, b.height.to_f/2 - 255)
      b.text "100kb/pixel", x, y + text_ascent.to_f/2
      y = map(Math.log(1E-6), Math.log(1E-6), Math.log(1), b.height.to_f/2 + 255, b.height.to_f/2 - 255)
      b.text ">1Mb/pixel", x, y + text_ascent.to_f/2

      b.text_align LEFT
      x = 200
      slice_start_y = 20
      b.fill 0
      @slices.each do |slice|
        start_chr, start_pos = slice.start_cumulative_bp.cumulative_bp_to_chr_bp
        start_text = start_chr.name + ':' + start_pos.format
        stop_chr, stop_pos = slice.stop_cumulative_bp.cumulative_bp_to_chr_bp
        stop_text = stop_chr.name + ':' + stop_pos.format

        y = slice_start_y
        b.text_font @f24
        b.text slice.label, x, y + 50 unless slice.label.nil?
        b.text_font @f12
        y += text_ascent + 5
        x += 5
        y += text_ascent + 3
        b.text "Locus = " + start_text + '-' + stop_text, x+20, y
        y += text_ascent + 3
        b.text  "Length (bp) = " + slice.length_bp.format, x+20, y
        y += text_ascent + 3
        b.text  "Pixel range = " + slice.start_pixel.format + '-' + slice.stop_pixel.format, x+20, y
        y += text_ascent + 3
        b.text  "Length (pixel) = " + slice.length_pixel.format, x+20, y
        y += text_ascent + 3
        b.text  "Resolution = " + slice.formatted_resolution, x+20, y
        y += text_ascent + 3
        b.text "Fixed? = " + slice.fixed.to_s, x+20, y

        # Draw line from slice description to zoom scale
        y_on_scale = nil
        if slice.resolution < 1E-6
          y_on_scale = b.height.to_f/2 + 255
        elsif slice.resolution > 1
          y_on_scale = b.height.to_f/2 - 255
        else
          y_on_scale = map(Math.log(slice.resolution), Math.log(1E-6), Math.log(1), b.height.to_f/2 + 255, b.height.to_f/2 - 255)
        end
        b.ellipse x, slice_start_y + 60, 3, 3
        b.ellipse 100, y_on_scale, 3, 3
        b.no_fill
        b.stroke rand(200)
        b.bezier x, slice_start_y + 60, x-50, slice_start_y + 60, 150, y_on_scale, 100, y_on_scale
        b.no_stroke
        b.fill 0

        x -= 5
        slice_start_y += 7*text_ascent + 23
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

  def draw_sequence_colour_scheme
    buffer_sequence_colour_scheme = buffer(200, 100, JAVA2D) do |b|
      b.background 255
      b.smooth

      b.no_stroke
      b.text_font @f12
      x = 10
      y = 10
      @seq_colour.keys.sort.each do |base|
        b.fill @seq_colour[base]
        b.rect x, y, 10, 10
        b.fill 0
        b.text base, x+15, y + text_ascent
        y += 15
      end

      directions = "LEFT => clockwise\nRIGHT => counterclockwise"
      b.text directions, 50, 50
    end

    return buffer_sequence_colour_scheme.get(0,0,buffer_sequence_colour_scheme.width, buffer_sequence_colour_scheme.height)
  end

  def draw_right_mouse_click_menu
    b = create_graphics 400, 400, JAVA2D
    b.begin_draw
      b.background 255, 200
      b.smooth
      b.stroke 255, 0, 0
      b.stroke_weight 3
      b.no_fill
      b.rect 20, 20, 380, 380
      b.fill 0
      b.text_font @f12
      b.text "Test text", 100, 100
      b.text "Test text", 300, 300
    b.end_draw
    return b
  end
end
