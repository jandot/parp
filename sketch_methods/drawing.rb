class MySketch < Processing::App
  def draw_overview_display
    buffer_overview = buffer(self.width/2, self.height, JAVA2D) do |b|
      b.background 255
      b.text_font @f
      b.text_align CENTER
      b.stroke_cap MySketch::SQUARE
      b.smooth

      b.translate(self.width.to_f/4, self.height.to_f/2)
      @displays[:overview].draw(b)
      b.translate(self.width.to_f/4, self.height.to_f/2)
    end
    @image_overview = buffer_overview.get(0, 0, buffer_overview.width, buffer_overview.height)
  end
end