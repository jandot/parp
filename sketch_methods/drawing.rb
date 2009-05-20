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
      b.translate(-self.width/2, -self.height/2)
    end
    @buffer_images[:zoomed] = buffer_zoomed.get(0, 0, buffer_zoomed.width, buffer_zoomed.height)
  end
end