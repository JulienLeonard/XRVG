/*
 * FontCreator.java
 */

package jp.ne.cappuccino.keisuken.tools.pureimage;

import java.awt.*;
import java.awt.image.*;
import java.io.*;
import java.util.*;
import javax.swing.*;

/**
 * Font creator.
 * @author   NISHIMOTO Keisuke.
 * @version  0.1.0, 2005/06/27, 2005/06/27.
 */
public class FontCreator extends JFrame {

  /**
   * Execute to create font file.
   * @param  args  arguments.
   */
  public static void main(String[] args) {
    if(args.length >= 3) {
      try {
        File tableFile = new File(args[0]);
        String fontName = args[1];
        int fontSize = Integer.parseInt(args[2]);
        Font font = new Font(fontName, Font.PLAIN, fontSize);
        String fontFileName = args[3];
        FontCreator creator = new FontCreator();
        creator.setVisible(true);
        creator.pack();
        creator.create(tableFile, font, fontFileName);
        creator.setVisible(false);
        System.exit(0);
      } catch(Exception e) {
        e.printStackTrace();
        System.exit(1);
      }
    } else {
      printUsage();
    }
  }

  private static void printUsage() {
    System.err.println(
      "Usage: font_creator table_file font_name font_size font_file_name");
  }

  private static final int BYTE_SIZE  = 1;
  private static final int SHORT_SIZE = 2;
  private static final int INT_SIZE   = 4;

  private static final int IMAGE_WIDTH  = 200;
  private static final int IMAGE_HEIGHT = 200;

  class CharImage {

    public int size;
    public char code;
    public int width;
    public int height;
    public int ascent;
    public int[] pixels;

    public CharImage(
      BufferedImage image, char c, FontMetrics fm, int x, int y) {
      code = c;
      width = fm.charWidth(c);
      height = fm.getHeight();
      ascent = fm.getAscent();
      pixels = new int[width * height];
      size = SHORT_SIZE + pixels.length * BYTE_SIZE;
      int xs = x;
      int ys = y - ascent;
      for(int j = 0, index = 0; j < height; j++) {
        for(int i = 0; i < width; i++, index++) {
          pixels[index] = image.getRGB(xs + i, ys + j);
        }
      }
    }

    public void writeTo(OutputStream out) throws IOException {
      writeShort(out, width);
      for(int i = 0; i < pixels.length; i++) {
        out.write(pixels[i] & 0xff);
      }
    }

    public String toString() {
      StringBuffer buf = new StringBuffer();
      buf.append("CharImage[width=" + width);
      buf.append(",height=" + height);
      buf.append(",ascent=" + ascent);
      buf.append(",size=" + pixels.length);
      buf.append("]\n");
      for(int j = 0, index = 0; j < height; j++) {
        for(int i = 0; i < width; i++, index++) {
          buf.append((pixels[index] & 0xffffff) > 0 ? "**" : "::");
        }
        buf.append("\n");
      }
      return new String(buf);
    }
  }

  class ImageCanvas extends JComponent {

    private BufferedImage image = new BufferedImage(
      IMAGE_WIDTH, IMAGE_HEIGHT, BufferedImage.TYPE_INT_RGB);

    public ImageCanvas() {
      setPreferredSize(new Dimension(IMAGE_WIDTH, IMAGE_HEIGHT));
    }

    public CharImage drawChar(Font font, char c) {
      Graphics2D g2d = (Graphics2D)image.getGraphics();
      g2d.setRenderingHint(
        RenderingHints.KEY_ANTIALIASING,
        RenderingHints.VALUE_ANTIALIAS_ON);
      g2d.setRenderingHint(
        RenderingHints.KEY_RENDERING,
        RenderingHints.VALUE_RENDER_QUALITY);
      g2d.setRenderingHint(
        RenderingHints.KEY_TEXT_ANTIALIASING,
        RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
      g2d.setColor(Color.black);
      g2d.fillRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
      g2d.setColor(Color.white);
      g2d.setFont(font);
      FontMetrics fm = g2d.getFontMetrics();
      int x = (IMAGE_WIDTH - fm.charWidth(c)) / 2;
      int y = (IMAGE_HEIGHT - fm.getHeight()) / 2 + fm.getAscent();
      g2d.drawString("" + c, x, y);
      repaint();
      return new CharImage(image, c, fm, x, y);
    }

    public void paint(Graphics g) {
      g.drawImage(image, 0, 0, this);
    }
  }

  private ImageCanvas canvas = new ImageCanvas();

  /**
   * Creates font creator.
   */
  public FontCreator() {
    super("Font creator");
    Container pane = getContentPane();
    pane.setLayout(new BorderLayout());
    pane.add(canvas);
  }

  /**
   * Create font file.
   * @param  tableFile     Unicode mapping table file.
   * @param  font          font.
   * @param  fontFileName  font file name.
   * @throws  IOException  IO error.
   */
  public void create(
    File tableFile, Font font, String fontFileName) throws IOException {

    ArrayList codes = new ArrayList();
    BufferedReader reader = null;
    try {
      reader = new BufferedReader(new FileReader(tableFile));
      String line;
      while((line = reader.readLine()) != null) {
        try {
          int code = Integer.parseInt(line, 16);
          codes.add(new Character((char)code));
        } catch(NumberFormatException e) {
          throw new IOException("Character number error");
        }
      }
    } catch(IOException e) {
      throw e;
    } finally {
      if(reader != null) {
        reader.close();
      }
    }

    CharImage charImage;
    ArrayList fontImage = new ArrayList();
    int offset = INT_SIZE + 3 * SHORT_SIZE;
    for(Iterator codeItr = codes.iterator(); codeItr.hasNext();) {
      Character code = (Character)codeItr.next();
      char c = code.charValue();
      charImage = canvas.drawChar(font, c);
      fontImage.add(charImage);
      offset += SHORT_SIZE + INT_SIZE;
//      System.out.println(charImage);
    }

    /*
     * Font file format:
     *
     * class Location {
     *   short code;
     *   int   offset;
     * }
     *
     * class CharImage {
     *   short width;
     *   byte[] pixels;
     * }
     *
     * class Font {
     *   int length;
     *   short height;
     *   short ascent;
     *   short descent;
     *   Location[] locations;
     *   CharImage[] images;
     * }
     *
     * CharImage[] charImages;
     */
    FileOutputStream out = null;
    try {
      out = new FileOutputStream(fontFileName);
      FontMetrics fm = getFontMetrics(font);
      writeInt(out, fontImage.size());
      writeShort(out, fm.getHeight());
      writeShort(out, fm.getAscent());
      writeShort(out, fm.getDescent());
      int location = offset;
      for(Iterator charImageItr = fontImage.iterator();
          charImageItr.hasNext();) {
        charImage = (CharImage)charImageItr.next();
        writeShort(out, charImage.code);
        writeInt(out, location);
        location += charImage.size;
      }
      for(Iterator charImageItr = fontImage.iterator();
          charImageItr.hasNext();) {
        charImage = (CharImage)charImageItr.next();
        charImage.writeTo(out);
      }
    } finally {
      if(out != null) {
        out.close();
      }
    }
  }

  private void writeShort(OutputStream out, int value) throws IOException {
    out.write((value >> 8) & 0xff);
    out.write(value & 0xff);
  }

  private void writeInt(OutputStream out, int value) throws IOException {
    out.write((value >> 24) & 0xff);
    out.write((value >> 16) & 0xff);
    out.write((value >> 8) & 0xff);
    out.write(value & 0xff);
  }
}
