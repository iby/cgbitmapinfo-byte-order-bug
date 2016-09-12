import AppKit
import CoreGraphics
import Foundation

public class ViewController: NSViewController
{
    @IBOutlet private weak var pngNsImageView: NSImageView!
    @IBOutlet private weak var jpgNsImageView: NSImageView!
    @IBOutlet private weak var pngCgImageView: NSImageView!
    @IBOutlet private weak var jpgCgImageView: NSImageView!

    override public func viewDidLoad() {
        let pngUrl: NSURL = NSBundle.mainBundle().URLForImageResource("image.png")!
        let jpgUrl: NSURL = NSBundle.mainBundle().URLForImageResource("image.jpg")!

        let pngNsImage: NSImage = NSImage(byReferencingURL: pngUrl)
        let jpgNsImage: NSImage = NSImage(byReferencingURL: jpgUrl)

        let pngCgImage: CGImage = pngNsImage.CGImageForProposedRect(nil, context: nil, hints: nil)!
        let jpgCgImage: CGImage = jpgNsImage.CGImageForProposedRect(nil, context: nil, hints: nil)!

        let pngBitmapInfo: CGBitmapInfo = CGImageGetBitmapInfo(pngCgImage)
        let jpgBitmapInfo: CGBitmapInfo = CGImageGetBitmapInfo(jpgCgImage)

        // Confirm that we have little endian host byte order.

        Swift.print("Host byte order:")
        Swift.print("  CGBitmapByteOrder16Host == ByteOrder16Big", CGBitmapByteOrder16Host == CGBitmapInfo.ByteOrder16Big.rawValue)
        Swift.print("  CGBitmapByteOrder16Host == ByteOrder32Little", CGBitmapByteOrder16Host == CGBitmapInfo.ByteOrder16Little.rawValue)
        Swift.print("  CGBitmapByteOrder32Host == ByteOrder32Big", CGBitmapByteOrder32Host == CGBitmapInfo.ByteOrder32Big.rawValue)
        Swift.print("  CGBitmapByteOrder32Host == ByteOrder32Little", CGBitmapByteOrder32Host == CGBitmapInfo.ByteOrder32Little.rawValue)

        // PNG and JPEG use network / big endian byte order, however the bitmap information indicates
        // otherwise, suggesting the order is little endian.

        Swift.print("PNG bitmap info:")
        Swift.print("  ByteOrderDefault", pngBitmapInfo.contains(CGBitmapInfo.ByteOrderDefault))
        Swift.print("  ByteOrder16Big", pngBitmapInfo.contains(CGBitmapInfo.ByteOrder16Big))
        Swift.print("  ByteOrder16Little", pngBitmapInfo.contains(CGBitmapInfo.ByteOrder16Little))
        Swift.print("  ByteOrder32Big", pngBitmapInfo.contains(CGBitmapInfo.ByteOrder32Big))
        Swift.print("  ByteOrder32Little", pngBitmapInfo.contains(CGBitmapInfo.ByteOrder32Little))

        Swift.print("JPEG bitmap info:")
        Swift.print("  ByteOrderDefault", jpgBitmapInfo.contains(CGBitmapInfo.ByteOrderDefault))
        Swift.print("  ByteOrder16Big", jpgBitmapInfo.contains(CGBitmapInfo.ByteOrder16Big))
        Swift.print("  ByteOrder16Little", jpgBitmapInfo.contains(CGBitmapInfo.ByteOrder16Little))
        Swift.print("  ByteOrder32Big", jpgBitmapInfo.contains(CGBitmapInfo.ByteOrder32Big))
        Swift.print("  ByteOrder32Little", jpgBitmapInfo.contains(CGBitmapInfo.ByteOrder32Little))

        // Bitmap representation doesn't provide any endianness information either.

        Swift.print("PNG & JPEG bitmap representation bitmap format:")
        Swift.print((pngNsImage.representations.first! as! NSBitmapImageRep).bitmapFormat)
        Swift.print((jpgNsImage.representations.first! as! NSBitmapImageRep).bitmapFormat)

        // Display image, both must be pure red colour.

        self.pngNsImageView.image = pngNsImage
        self.jpgNsImageView.image = jpgNsImage

        // Print RGBA values for the first pixel, whilst according to bitmap info the pixel 
        // format is BGRA. Green value is also shown differently, it should be 0, but must
        // be adjusted by colour space / model.

        let dataProvider: CGDataProvider = CGImageGetDataProvider(pngCgImage)!
        let bitmapData: CFDataRef = CGDataProviderCopyData(dataProvider)!
        let buffer: UnsafeMutableBufferPointer<UInt8> = UnsafeMutableBufferPointer(start: UnsafeMutablePointer<UInt8>(CFDataGetBytePtr(bitmapData)), count: CGImageGetBytesPerRow(pngCgImage) * CGImageGetHeight(pngCgImage))
        let bytes: [UInt8] = Array(buffer)

        Swift.print(bytes[0], bytes[1], bytes[2], bytes[3])
    }
}

