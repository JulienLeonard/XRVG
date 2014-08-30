package jp.ne.cappuccino.keisuken.tools.pureimage;

import java.awt.*;
import java.awt.font.*;
import java.awt.geom.*;
import javax.swing.*;

public class FontTest {
  public static void main(String[] args) throws Exception {
    JFrame frame = new JFrame();
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    Container pane = frame.getContentPane();
    pane.add(new JComponent() {
      public void paint(Graphics g) {
        Graphics2D g2d = (Graphics2D)g;

    Font font = new Font("Serif", Font.PLAIN, 64);
System.out.println("Font=" + font);
    AffineTransform tx = new AffineTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
System.out.println("Affine transform=" + tx);
    FontRenderContext frc = new FontRenderContext(tx, true, false);
System.out.println("Font render context=" + frc);
    GlyphVector gvec = font.createGlyphVector(frc, "Hello");
System.out.println("Glyph vector=" + gvec);
    Shape shape = gvec.getOutline();
System.out.println("Shape=" + shape);

        g2d.translate(100.0, 100.0);
        g2d.draw(shape);

      }
    });
    frame.setSize(320, 240);
    frame.setVisible(true);
  }
}
