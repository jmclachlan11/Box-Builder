//
//  DrawBox.swift
//  Box Builder
//
//  Created by Jacob McLachlan on 6/15/22.
//

import UIKit

class DrawBox: UIView {
    
    // getLast() constants
    let x = 0
    let y = 1
    
    let rollOffset: CGFloat = 9                             // box line to top of roll
    let rollStrokeWidth: CGFloat = 2
    let yOffset: CGFloat = 20                               // top of view to top of box
    let height: CGFloat = 100                               // height for cell
    let width: CGFloat = 55                                 // width for cell
    lazy var middle: CGFloat = bounds.width / 2             // middle of view
    
    // incoming values
    var box = ResultViewController.Box(woodThickness: 0, count: 0, rows: 0)
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            // MARK: grid
            context.setLineWidth(3)
            context.setStrokeColor(UIColor.label.cgColor)
             
            // 6 rolls, 1 row
            if box.rows == 1 {
                for i in 0 ... Int(box.count) / 2 - 1 {
                    context.addRects([
                        CGRect(x: middle - CGFloat(i) * width, y: yOffset, width: -1 * width, height: height),
                        CGRect(x: middle + CGFloat(i) * width, y: yOffset, width: width, height: height)
                    ])
                }
            }
            // 2 rows
            else {
                // middle boxes
                context.addRects([
                    CGRect(x: middle - width / 2, y: yOffset, width: width, height: height),
                    CGRect(x: middle - width / 2, y: yOffset + height, width: width, height: height)
                ])

                // other boxes
                for i in 0 ... Int(box.count) / 4 - 1 {
                    context.addRects([
                        CGRect(x: middle - width / 2 - CGFloat(i) * width, y: yOffset, width: -1 * width, height: height),
                        CGRect(x: middle + width / 2 + CGFloat(i) * width, y: yOffset, width: width, height: height),
                        CGRect(x: middle - width / 2 - CGFloat(i) * width, y: yOffset + height, width: -1 * width, height: height),
                        CGRect(x: middle + width / 2 + CGFloat(i) * width, y: yOffset + height, width: width, height: height),
                    ])
                }
            }
                        
            context.strokePath()
            
            // MARK: rolls
            context.setLineWidth(rollStrokeWidth)
            context.setStrokeColor(UIColor.systemGray.cgColor)
            
            // 6 rolls, 1 row
            if box.rows == 1 {
                for i in 0 ... Int(box.count) / 2 - 1 {
                    insertRollDrawing(at: CGPoint(x: middle - CGFloat(i) * width - width / 2, y: yOffset + rollOffset), context)
                    insertRollDrawing(at: CGPoint(x: middle + CGFloat(i) * width + width / 2, y: yOffset + rollOffset), context)
                }
            }
            // 2 rows
            else {
                // middle boxes
                insertRollDrawing(at: CGPoint(x: middle, y: yOffset + rollOffset), context)
                insertRollDrawing(at: CGPoint(x: middle, y: yOffset + rollOffset + height), context)

                // other boxes
                for i in 0 ... Int(box.count) / 4 - 1 {
                    insertRollDrawing(at: CGPoint(x: middle - CGFloat(i + 1) * width, y: yOffset + rollOffset), context)
                    insertRollDrawing(at: CGPoint(x: middle + CGFloat(i + 1) * width, y: yOffset + rollOffset), context)
                    insertRollDrawing(at: CGPoint(x: middle - CGFloat(i + 1) * width, y: yOffset + rollOffset + height), context)
                    insertRollDrawing(at: CGPoint(x: middle + CGFloat(i + 1) * width, y: yOffset + rollOffset + height), context)
                }
            }
            
            UIGraphicsEndImageContext()
        }
    }
    
    func insertRollDrawing(at topCenter: CGPoint, _ context: CGContext) {
        let topEndLength: CGFloat = 22
        let rollLength: CGFloat = 40
        let fillet: CGFloat = 5
        let bottomEndLength: CGFloat = height - topEndLength - rollLength - 2 * rollOffset - 2 * fillet
        let smallRadius: CGFloat = 5
        let largeRadius: CGFloat = width / 2 - rollOffset
        let curveOffsetFromCenter: CGFloat = largeRadius - 5
        let offsetFromFilletX: CGFloat = 5
        let offsetFromFilletY: CGFloat = 3
        let cut: CGFloat = 1
        
        // MARK: calls to use when moving in
        // x direction: topCenter, shouldFlipX
        // y direction: getLast(x)
        
        // draw left side then right side
        var shouldFlip = true
        for _ in 1 ... 2 {
            context.move(to: topCenter)
            
            // top shaft
            context.addLine(to: CGPoint(
                x: topCenter.x + smallRadius - cut,
                y: y.getLast()
            ).shouldFlipX(over: topCenter.x, shouldFlip))
            context.addLine(to: CGPoint(
                x: topCenter.x + smallRadius,
                y: y.getLast() + cut
            ).shouldFlipX(over: topCenter.x, shouldFlip))
            context.addLine(to: CGPoint(
                x: x.getLast(),
                y: y.getLast() + topEndLength
            ))
            
            // roll
            context.addLine(to: CGPoint(
                x: topCenter.x + largeRadius - fillet,
                y: y.getLast()
            ).shouldFlipX(over: topCenter.x, shouldFlip))
            context.addQuadCurve(
                to: CGPoint(
                    x: topCenter.x + largeRadius,
                    y: y.getLast() + fillet
                ).shouldFlipX(over: topCenter.x, shouldFlip),
                control: CGPoint(
                    x: topCenter.x + largeRadius - fillet / 2 + offsetFromFilletX,
                    y: y.getLast() + fillet / 2 - offsetFromFilletY
                ).shouldFlipX(over: topCenter.x, shouldFlip)
            )
            context.addCurve(
                to: CGPoint(
                    x: x.getLast(),
                    y: y.getLast() + rollLength
                ),
                control1: CGPoint(
                    x: topCenter.x + curveOffsetFromCenter,
                    y: y.getLast() + rollLength / 3
                ).shouldFlipX(over: topCenter.x, shouldFlip),
                control2: CGPoint(
                    x: topCenter.x + curveOffsetFromCenter,
                    y: y.getLast() + 2 * rollLength / 3
                ).shouldFlipX(over: topCenter.x, shouldFlip)
            )
            context.addQuadCurve(
                to: CGPoint(
                    x: topCenter.x + largeRadius - fillet,
                    y: y.getLast() + fillet
                ).shouldFlipX(over: topCenter.x, shouldFlip),
                control: CGPoint(
                    x: topCenter.x + largeRadius - fillet / 2 + offsetFromFilletX,
                    y: y.getLast() + fillet / 2 + offsetFromFilletY
                ).shouldFlipX(over: topCenter.x, shouldFlip)
            )
            context.addLine(to: CGPoint(
                x: topCenter.x + smallRadius,
                y: y.getLast()
            ).shouldFlipX(over: topCenter.x, shouldFlip))
            
            // bottom shaft
            context.addLine(to: CGPoint(
                x: x.getLast(),
                y: y.getLast() + bottomEndLength - cut
            ))
            context.addLine(to: CGPoint(
                x: topCenter.x + smallRadius - cut,
                y: y.getLast() + cut
            ).shouldFlipX(over: topCenter.x, shouldFlip))
            context.addLine(to: CGPoint(
                x: topCenter.x,
                y: y.getLast()
            ))
            
            fillInRoll(topCenter, context, shouldFlip)
            
            // prepare to draw other side
            shouldFlip = false
        }
    }
    
    func fillInRoll(_ topCenter: CGPoint, _ context: CGContext, _ shouldFlip: Bool) {
        context.strokePath()
        context.setLineWidth(5)
        
        // shaft
        context.move(to: CGPoint(
            x: topCenter.x + 2,
            y: topCenter.y - 1
        ).shouldFlipX(over: topCenter.x, shouldFlip))
        context.addLine(to: CGPoint(
            x: x.getLast(),
            y: topCenter.y + 83
        ))
        context.strokePath()
        
        // between shaft and curve
        context.setLineWidth(11)
        context.move(to: CGPoint(
            x: topCenter.x + 37 / 4,
            y: topCenter.y + 22
        ).shouldFlipX(over: topCenter.x, shouldFlip))
        context.addLine(to: CGPoint(
            x: x.getLast(),
            y: topCenter.y + 73
        ))
        context.strokePath()
        
        // edge of shaft
        context.setLineWidth(6)
        context.move(to: CGPoint(
            x: topCenter.x + 17,
            y: topCenter.y + 23.5
        ).shouldFlipX(over: topCenter.x, shouldFlip))
        context.addCurve(
            to: CGPoint(
                x: x.getLast(),
                y: topCenter.y + 73
            ),
            control1: CGPoint(
                x: topCenter.x + 11,
                y: y.getLast() + 40 / 3
            ).shouldFlipX(over: topCenter.x, shouldFlip),
            control2: CGPoint(
                x: topCenter.x + 8.5,
                y: y.getLast() + 80 / 3
            ).shouldFlipX(over: topCenter.x, shouldFlip)
        )
        context.strokePath()
        context.setLineWidth(rollStrokeWidth)
    }
    
}

extension CGPoint {
    func shouldFlipX(over originX: CGFloat, _ shouldFlip: Bool) -> CGPoint {
        return shouldFlip ? CGPoint(x: self.x - 2 * (self.x - originX), y: self.y) : self
    }
}

extension Int {
    func getLast() -> CGFloat {
        return self == 0 ? UIGraphicsGetCurrentContext()?.currentPointOfPath.x ?? 0 : UIGraphicsGetCurrentContext()?.currentPointOfPath.y ?? 0
    }
}
