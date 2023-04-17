//
//  DrawWoodPiece.swift
//  Box Builder
//
//  Created by Jacob McLachlan on 6/20/22.
//

import UIKit

class DrawWoodPiece: UIView {
    
    let shapeOffset = 80.0
    let dimensionBuffer = 10.0
    
    // getLast() constants
    let x = 0
    let y = 1
    
    // constants for shifting entire view
    let centerRectangleConstant = 16.0
    let centerModelConstant = 30.0
    
    lazy var width = self.frame.size.width
    lazy var height = self.frame.size.height
    
    let font = (title: UIFont.systemFont(ofSize: 24), dimension: UIFont.systemFont(ofSize: 20), small: UIFont.systemFont(ofSize: 14))
    var color = (long: UIColor.systemGreen, middle: UIColor.systemBlue, short: UIColor.systemRed, label: UIColor.label)
        
    enum Dimension { case LONG, MIDDLE, SHORT }
    enum Connector { case ACROSS, DOWN, NONE }
    enum Span { case LENGTH, WIDTH, HEIGHT }
    
    // incoming values
    var piece = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var roll = ResultViewController.Roll(name: "", length: 0, diameter: 0)
    var box = ResultViewController.Box(woodThickness: 0, count: 0, rows: 0)
    var slide = 0
    var isForPrinting = false
    
    // passed from detail view controller to draw model
    var sendToModel = (length: 0.0, width: 0.0, height: 0.0)

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(1)
            
            let dimension = (long: getDimension(Dimension.LONG).0, middle: getDimension(Dimension.MIDDLE).0, short: getDimension(Dimension.SHORT).0)
            let span = (long: getDimension(Dimension.LONG).1, middle: getDimension(Dimension.MIDDLE).1, short: getDimension(Dimension.SHORT).1)
            
            // determine and apply scale factor
            let xScaleFactor = width / dimension.middle / 2.0
            let yScaleFactor = height / dimension.long / 2.8
            let scaleFactor = xScaleFactor < yScaleFactor ? xScaleFactor : yScaleFactor
            let scaledDimension = (long: dimension.long * scaleFactor, middle: dimension.middle * scaleFactor, short: dimension.short * scaleFactor)
            let depthComponent = scaledDimension.short / sqrt(2)
            
            // long side label
            let longLabel = getDimensionLabelString(side: span.long, value: dimension.long)
            let sizeLL = longLabel.size(OfFont: font.dimension)
            let xLL = width / 2 - (sizeLL.width + scaledDimension.middle + depthComponent + dimensionBuffer) / 2 - centerRectangleConstant
            drawDimensionLabelString(
                side: span.long,
                value: dimension.long,
                boundingBox: CGRect(
                    x: xLL,
                    y: shapeOffset + depthComponent + scaledDimension.long / 2 - sizeLL.height / 2,
                    width: sizeLL.width,
                    height: sizeLL.height
                ),
                color: color.long
            )
            
            // get rectangle start point based on size of long label
            let rectangleStartPoint = CGPoint(
                x: xLL + sizeLL.width + dimensionBuffer,
                y: shapeOffset + depthComponent
            )
                        
            // middle side label
            let middleLabel = getDimensionLabelString(side: span.middle, value: dimension.middle)
            let sizeML = middleLabel.size(OfFont: font.dimension)
            drawDimensionLabelString(
                side: span.middle,
                value: dimension.middle,
                boundingBox: CGRect(
                    x: rectangleStartPoint.x + scaledDimension.middle / 2 - sizeML.width / 2,
                    y: rectangleStartPoint.y + scaledDimension.long + dimensionBuffer,
                    width: sizeML.width,
                    height: sizeML.height
                ),
                color: color.middle
            )
                
            // short side label
            let shortLabel = getDimensionLabelString(side: span.short, value: dimension.short, addWoodThickness: true)
            let sizeSL = shortLabel.size(OfFont: font.small)
            drawDimensionLabelString(
                side: span.short,
                value: dimension.short,
                boundingBox: CGRect(
                    x: rectangleStartPoint.x + depthComponent + scaledDimension.middle / 2 - sizeSL.width / 2,
                    y: rectangleStartPoint.y - depthComponent - sizeSL.height - dimensionBuffer,
                    width: sizeSL.width,
                    height: sizeSL.height
                ),
                color: color.short,
                isWoodThickness: true
            )
            
            // front rectangle middle side
            context.setStrokeColor(color.middle.cgColor)
            context.move(to: rectangleStartPoint)
            context.addLine(to: CGPoint(x: rectangleStartPoint.x + scaledDimension.middle, y: rectangleStartPoint.y))
            context.move(to: CGPoint(x: rectangleStartPoint.x, y: rectangleStartPoint.y + scaledDimension.long))
            context.addLine(to: CGPoint(x: rectangleStartPoint.x + scaledDimension.middle, y: rectangleStartPoint.y + scaledDimension.long))
            context.strokePath()
            
            // front rectangle long side
            context.setStrokeColor(color.long.cgColor)
            context.move(to: rectangleStartPoint)
            context.addLine(to: CGPoint(x: rectangleStartPoint.x, y: rectangleStartPoint.y + scaledDimension.long))
            context.move(to: CGPoint(x: rectangleStartPoint.x + scaledDimension.middle, y: rectangleStartPoint.y))
            context.addLine(to: CGPoint(x: rectangleStartPoint.x + scaledDimension.middle, y: rectangleStartPoint.y + scaledDimension.long))
            context.strokePath()
            
            addDepthLine(
                startingAt: rectangleStartPoint,
                ofLength: scaledDimension.short,
                context,
                withConnector: .ACROSS,
                scaledDimension.middle,
                scaledDimension.long
            )
            addDepthLine(
                startingAt: CGPoint(x: rectangleStartPoint.x + scaledDimension.middle, y: rectangleStartPoint.y),
                ofLength: scaledDimension.short - 1,
                context,
                withConnector: .DOWN,
                scaledDimension.middle,
                scaledDimension.long
            )
            addDepthLine(
                startingAt: CGPoint(x: rectangleStartPoint.x + scaledDimension.middle, y:rectangleStartPoint.y + scaledDimension.long),
                ofLength: scaledDimension.short,
                context
            )
            
            context.setStrokeColor(color.label.cgColor)
            
            // MARK: scale
            let scaleVertical: CGFloat = 16
            let scaleCount = isForPrinting ? 4 : 3
            let minimumDistanceBetweenLines = isForPrinting ? 70.0 : 50.0
            let scaleFactorMultiplier = floor(minimumDistanceBetweenLines / scaleFactor) == 0 ? 1 : floor(minimumDistanceBetweenLines / scaleFactor)
            let scaleStartPoint = CGPoint(
                x: width / 2 - scaleFactor * scaleFactorMultiplier * Double(scaleCount) / 2,
                y: rectangleStartPoint.y + scaledDimension.long + dimensionBuffer + sizeML.height + 30.0
            )
            
            // horizontal line
            context.move(to: scaleStartPoint)
            context.addLine(to: CGPoint(x: x.getLast() + scaleFactor * scaleFactorMultiplier * Double(scaleCount), y: y.getLast()))
            
            // vertical lines
            for i in 0 ... scaleCount {
                context.move(to: CGPoint(x: scaleStartPoint.x + scaleFactor * scaleFactorMultiplier * Double(i), y: scaleStartPoint.y - scaleVertical / 2))
                let bottomScaleVertical = CGPoint(x: x.getLast(), y: y.getLast() + scaleVertical)
                context.addLine(to: bottomScaleVertical)

                // numbers
                let scaleLabel = String(Int(Double(i) * scaleFactorMultiplier))
                let sizeSCL = scaleLabel.size(OfFont: font.small)
                scaleLabel.draw(
                    boundingBox: CGRect(
                        x: bottomScaleVertical.x - sizeSCL.width / 2,
                        y: bottomScaleVertical.y + 4,
                        width: sizeSCL.width,
                        height: sizeSCL.height
                    ),
                    font: font.small,
                    color: color.label
                )

                // inch label
                if i == scaleCount {
                    let inchLabel = "in."
                    let sizeIL = inchLabel.size(OfFont: font.small)
                    inchLabel.draw(
                        boundingBox: CGRect(
                            x: bottomScaleVertical.x - sizeSCL.width / 2 + sizeSCL.width + 3,
                            y: bottomScaleVertical.y + 4,
                            width: sizeIL.width,
                            height: sizeIL.height
                        ),
                        font: font.small,
                        color: color.label
                    )
                }

            }
            
            // title
            let titleLabel = piece.title
            let sizeTL = titleLabel.size(OfFont: font.title)
            titleLabel.draw(
                boundingBox: CGRect(
                    x: width / 2 - sizeTL.width / 2,
                    y: 10,
                    width: sizeTL.width,
                    height: sizeTL.height
                ),
                font: font.title,
                color: color.label
            )
            
            // quantity
            let quantityLabel = NSMutableAttributedString(
                string: String(piece.quantity),
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 36), NSAttributedString.Key.foregroundColor: color.label]
            )
            quantityLabel.append(NSAttributedString(
                string: "x",
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28), NSAttributedString.Key.foregroundColor: color.label]
            ))
            let sizeQL = quantityLabel.size()
            quantityLabel.draw(
                with: CGRect(
                    x: 40,
                    y: rectangleStartPoint.y + scaledDimension.long + dimensionBuffer + sizeML.height - sizeQL.height,
                    width: sizeQL.width,
                    height: sizeQL.height
                ),
                options: .usesLineFragmentOrigin,
                context: nil
            )
            
            // model
            let drawModel = DrawModel()
            drawModel.section = getSection()
            drawModel.color = color.label.cgColor
            drawModel.angle = piece.modelAngle
            drawModel.needsRowDivider = box.rows == 2
            drawModel.columnDividerCount = box.count == 10 ? 4 : box.rows == 2 ? 2 : 5
            
            let modelScaleFactor = width / (sendToModel.length + sendToModel.width) * cos(drawModel.angle.toRadians()) / 1.4
            let scaledLength = sendToModel.length * modelScaleFactor
            drawModel.length = scaledLength
            let scaledWidth = sendToModel.width * modelScaleFactor
            drawModel.width = scaledWidth
            let scaledHeight = sendToModel.height * modelScaleFactor
            drawModel.height = scaledHeight
            
            let angle = piece.modelAngle.toRadians()
            drawModel.angle = angle
            let origin = CGPoint(
                x: width / 2 - scaledWidth * cos(angle) / 2 + scaledLength * cos(angle) / 2 + centerModelConstant,
                y: scaleStartPoint.y + 60 + (scaledLength + scaledWidth) * sin(angle)
            )
            drawModel.origin = origin
            
            drawModel.draw(CGRect())

            // stats label
            if isForPrinting {
                var statsLabel = """
                Rows: \(box.rows)
                Roll count: \(Int(box.count))
                Roll length: \(roll.length.toFraction()) in.
                Roll diameter: \(roll.diameter.toFraction()) in.
                """
                if let rollName = roll.name {
                    var machineLabel = "Machine: "
                    machineLabel.append("\(rollName)\n\(statsLabel)")
                    statsLabel = machineLabel
                }
                
                let sizeSTL = statsLabel.size(OfFont: font.small)
                statsLabel.draw(
                    boundingBox: CGRect(
                        x: 20,
                        y: 20,
                        width: sizeSTL.width,
                        height: sizeSTL.height
                    ),
                    font: font.small,
                    color: color.label,
                    alignment: .left
                )
            }
            
            // directional arrows
            let arrowCenter = CGPoint(x: origin.x - scaledLength * cos(angle) - 30, y: origin.y + scaledHeight)
            let arrowLength = 40.0
            let long = getDimension(.LONG).1
            let middle = getDimension(.MIDDLE).1
            
            context.addArrow(
                tail: arrowCenter,
                tip: CGPoint(
                    x: arrowCenter.x,
                    y: arrowCenter.y - arrowLength
                ),
                angle: 90,
                character: "H",
                font: font.small,
                color: long == .HEIGHT ? color.long : middle == .HEIGHT ? color.middle : color.short
            )
            context.addArrow(
                tail: arrowCenter,
                tip: CGPoint(
                    x: arrowCenter.x - arrowLength * cos(angle),
                    y: arrowCenter.y - arrowLength * sin(angle)
                ),
                angle: 180 - piece.modelAngle,
                character: "L",
                font: font.small,
                color: long == .LENGTH ? color.long : middle == .LENGTH ? color.middle : color.short
            )
            context.addArrow(
                tail: arrowCenter,
                tip: CGPoint(
                    x: arrowCenter.x + arrowLength * cos(angle),
                    y: arrowCenter.y - arrowLength * sin(angle)
                ),
                angle: piece.modelAngle,
                character: "W",
                font: font.small,
                color: long == .WIDTH ? color.long : middle == .WIDTH ? color.middle : color.short
            )
            
            context.strokePath()
        }
    }
  
    func addDepthLine(startingAt point: CGPoint,
                      ofLength length: Double,
                      _ context: CGContext,
                      withConnector connector: Connector = .NONE,
                      _ middle: Double = 0,
                      _ long: Double = 0) {
        context.setStrokeColor(color.short.cgColor)
        context.move(to: point)
        let endpoint = CGPoint(x: point.x + length / sqrt(2), y: point.y - length / sqrt(2))
        context.addLine(to: endpoint)
        context.strokePath()
        
        // connect depth lines
        if connector == .ACROSS {
            context.setStrokeColor(color.middle.cgColor)
            context.move(to: endpoint)
            context.addLine(to: CGPoint(x: endpoint.x + middle, y: endpoint.y))
            context.strokePath()
        } else if connector == .DOWN {
            context.setStrokeColor(color.long.cgColor)
            context.move(to: endpoint)
            context.addLine(to: CGPoint(x: endpoint.x, y: endpoint.y + long))
            context.strokePath()
        }
    }
    
    func getDimension(_ dimension: Dimension) -> (Double, Span) {
        switch dimension {
        case .LONG:
            if piece.length > piece.width && piece.length > piece.height {
                return (piece.length, Span.LENGTH)
            } else {
                return piece.width > piece.height ? (piece.width, Span.WIDTH) : (piece.height, Span.HEIGHT)
            }
        case .MIDDLE:
            if (piece.length > piece.width && piece.length < piece.height) || (piece.length < piece.width && piece.length > piece.height) {
                return (piece.length, Span.LENGTH)
            } else {
                return (piece.width > piece.length && piece.width < piece.height) || (piece.width < piece.length && piece.width > piece.height)
                ? (piece.width, Span.WIDTH) : (piece.height, Span.HEIGHT)
            }
        case .SHORT:
            if piece.length < piece.width && piece.length < piece.height {
                return (piece.length, Span.LENGTH)
            } else {
                return piece.width < piece.height ? (piece.width, Span.WIDTH) : (piece.height, Span.HEIGHT)
            }
        }
    }
    
    func getSection() -> DrawModel.Section {
        switch slide {
        case 0:
            return .TOP
        case 1:
            return .BOTTOM
        case 2:
            return .LEFT_RIGHT
        case 3:
            return .FRONT_BACK
        case 4:
            return .COLUMN_DIVIDER
        default:
            return .ROW_DIVIDER
        }
    }
    
    func getDimensionLabelString(side: Span, value: Double, addWoodThickness: Bool = false) -> String {
        var label = "\(side == .LENGTH ? "L" : side == .WIDTH ? "W" : "H"): \(value.toFraction())\""
        if addWoodThickness {
            label += " (wood thickness)"
        }
        return label
    }
    
    func drawDimensionLabelString(side: Span, value: Double, boundingBox: CGRect, color: UIColor, isWoodThickness: Bool = false) {
        let label = NSMutableAttributedString(
            string: side == .LENGTH ? "L:" : side == .WIDTH ? "W:" : "H:",
            attributes: [NSAttributedString.Key.font: isWoodThickness ? UIFont.systemFont(ofSize: 10) : font.small, NSAttributedString.Key.foregroundColor: color]
        )
        label.append(NSAttributedString(
            string: " \(value.toFraction())\"\(isWoodThickness ? " (wood thickness)" : "")",
            attributes: [NSAttributedString.Key.font: isWoodThickness ? font.small : font.dimension, NSAttributedString.Key.foregroundColor: color]
        ))
        label.draw(with: boundingBox, options: .usesLineFragmentOrigin, context: nil)
    }
    
}

extension CGContext {
    func addArrow(tail origin: CGPoint, tip end: CGPoint, angle: Double, character: String, font: UIFont, color: UIColor) {
        strokePath()
        setStrokeColor(color.cgColor)
        move(to: origin)
        addLine(to: end)
        addArrowTip(at: angle, fromPoint: end, with: color.cgColor)
        character.draw(
            boundingBox: CGRect(
                x: end.x + 3,
                y: end.y + 10,
                width: character.size(OfFont: font).width,
                height: character.size(OfFont: font).height
            ), font: font, color: color
        )
    }
    
    func addArrowTip(at angle: Double, fromPoint origin: CGPoint, with color: CGColor) {
        // getLast() constants
        let x = 0
        let y = 1
        
        let length = 10.0
        let interiorAngle = 25.0
        let interiorAngleLeft = (angle - interiorAngle).toRadians()
        let interiorAngleRight = (angle + interiorAngle).toRadians()
        
        strokePath()
        setStrokeColor(color)
        
        move(to: origin)
        addLine(to: CGPoint(x: x.getLast() - length * cos(interiorAngleLeft), y: y.getLast() + length * sin(interiorAngleLeft)))
        move(to: origin)
        addLine(to: CGPoint(x: x.getLast() - length * cos(interiorAngleRight), y: y.getLast() + length * sin(interiorAngleRight)))
    }
}

extension String {
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
    
    func draw(boundingBox: CGRect, font: UIFont, color: UIColor, alignment: NSTextAlignment = .center) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        self.draw(
            with: boundingBox,
            options: .usesLineFragmentOrigin,
            attributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: color
            ],
            context: nil
        )
    }
}

extension Double {
    func toFraction() -> String {
        let accuracyLevel = 16
        var numerator = 0
        var decimal = self - floor(self)
        
        // exact integer
        if decimal == 0 {
            return String(Int(self))
        }
        
        while decimal > 0 {
            decimal -= 1.0 / Double(accuracyLevel)
            numerator += 1
        }
        
        // from 15/16 to next integer
        if numerator == accuracyLevel && decimal != 0 {
            return String(Int(self + 1))
        }
        
        // any other fraction
        var denominator = accuracyLevel
        while numerator % 2 == 0 {
            numerator /= 2
            denominator /= 2
        }
        return "\(self < 1 ? "" : "\(Int(self)) ")\(numerator)/\(denominator)"
    }
}
