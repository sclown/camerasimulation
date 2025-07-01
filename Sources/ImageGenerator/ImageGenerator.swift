import SwiftUI

public extension UIImage {
    static func generateImage(from string: String, size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image {
            $0.cgContext.drawImage(
                string,
                colors: .palette(text: string),
                size: size
            )
        }
    }
}

// Extension for CGContext to add triangle drawing functionality
extension CGContext {
    public func drawImage(
        _ text: String,
        colors: [UIColor],
        size: CGSize
    ) {
        let center = CGPoint(x: size.width/2, y: size.height/2)
        
        // Draw the four triangles
        drawTriangle(
            [
                CGPoint(x: 0, y: 0),
                CGPoint(x: size.width, y: 0),
                center
            ],
            color: colors[0]
        )
        drawTriangle(
            [
                CGPoint(x: size.width, y: 0),
                CGPoint(x: size.width, y: size.height),
                center
            ],
            color: colors[1]
        )
        drawTriangle(
            [
                CGPoint(x: size.width, y: size.height),
                CGPoint(x: 0, y: size.height),
                center
            ],
            color: colors[2]
        )
        drawTriangle(
            [
                CGPoint(x: 0, y: size.height),
                CGPoint(x: 0, y: 0),
                center
            ],
            color: colors[3]
        )
        
        // Draw diagonal lines
        setStrokeColor(UIColor.black.cgColor)
        setLineWidth(1.5)
        
        // First diagonal (top-left to bottom-right)
        move(to: CGPoint(x: 0, y: 0))
        addLine(to: CGPoint(x: size.width, y: size.height))
        strokePath()
        
        // Second diagonal (top-right to bottom-left)
        move(to: CGPoint(x: size.width, y: 0))
        addLine(to: CGPoint(x: 0, y: size.height))
        strokePath()
        
        // Draw a circle that fits the frame
        setStrokeColor(UIColor.black.cgColor)
        setLineWidth(2.0)
        let padding: CGFloat = 10
        let diam = min(size.width, size.height) - padding * 2
        let circleRect = CGRect(
            x: center.x - diam / 2,
            y: center.y - diam / 2,
            width: diam,
            height: diam
        )
        addEllipse(in: circleRect)
        strokePath()
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        // Draw the string on the image
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .paragraphStyle: style,
            .foregroundColor: UIColor.black
        ]
        
        // Calculate text size to center it
        let textSize = text.size(withAttributes: textAttributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: textAttributes)
    }
    
    private func drawTriangle(_ points: [CGPoint], color: UIColor) {
        beginPath()
        move(to: points[0])
        addLine(to: points[1])
        addLine(to: points[2])
        closePath()
        color.setFill()
        fillPath()
    }
}
