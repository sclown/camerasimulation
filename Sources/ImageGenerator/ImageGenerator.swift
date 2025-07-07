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

extension CGContext {
    public func drawImage(
        _ text: String,
        colors: [UIColor],
        size: CGSize
    ) {
        let center = CGPoint(x: size.width/2, y: size.height/2)
        
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
        
        setStrokeColor(UIColor.black.cgColor)
        setLineWidth(1.5)
        move(to: CGPoint(x: 0, y: 0))
        addLine(to: CGPoint(x: size.width, y: size.height))
        strokePath()
        move(to: CGPoint(x: size.width, y: 0))
        addLine(to: CGPoint(x: 0, y: size.height))
        strokePath()
        
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

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .paragraphStyle: style,
            .foregroundColor: UIColor.black
        ]
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
