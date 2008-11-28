// buffer_linear_ideograms contains the ideograms of the linear display as well as the horizontal line
void drawBufferLinearIdeograms() {
  linearPanel.drawBufferLinearIdeograms();
  img_linear_ideograms = buffer_linear_ideograms.get(0, 0, buffer_linear_ideograms.width, buffer_linear_ideograms.height);
}
