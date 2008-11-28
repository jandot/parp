// buffer_linear_highlighted contains the dynamic part of the linear display: the highlighted read pairs
void drawBufferLinearHighlighted() {
  linearPanel.drawBufferLinearHighlighted();
  img_linear_highlighted = buffer_linear_highlighted.get(0, 0, buffer_linear_highlighted.width, buffer_linear_highlighted.height);
}
