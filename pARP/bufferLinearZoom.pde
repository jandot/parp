// buffer_linear_zoom contains the green zooming overlay on the ideograms as well as the readpairs (not highlighted)
void drawBufferLinearZoom() {
  linearPanel.drawBufferLinearZoom();
  
  img_linear_zoom = buffer_linear_zoom.get(0, 0, buffer_linear_zoom.width, buffer_linear_zoom.height);
}
