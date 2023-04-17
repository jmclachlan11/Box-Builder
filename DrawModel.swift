//
//  DrawModel.swift
//  Box Builder
//
//  Created by Jacob McLachlan on 6/23/22.
//

import UIKit

class DrawModel: UIView {
        
    var length = 0.0
    var width = 0.0
    var height = 0.0
    
    // getLast() constants
    let x = 0
    let y = 1
    
    var needsRowDivider = false
    var columnDividerCount = 0
    
    var color = UIColor.label.cgColor
            
    var angle = 0.0
    var origin = CGPoint(x: 0, y: 0)
    
    enum Section { case TOP, BOTTOM, LEFT_RIGHT, FRONT_BACK, COLUMN_DIVIDER, ROW_DIVIDER }
    
    var section: Section = .TOP
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(1)
            context.setAlpha(0.4)
            context.setStrokeColor(color)
            
            // top
            context.insertParallelogram(at: origin, angle, length, width, needsVertical: false)
                        
            // left
            context.insertParallelogram(at: origin, -angle, height, -length)
            
            // front
            context.insertParallelogram(at: origin, angle, height, width)
                    
            // bottom
            let bottomStartPoint = CGPoint(x: origin.x, y: origin.y + height)
            context.insertParallelogram(at: bottomStartPoint, angle, length, width, needsVertical: false)
            
            // right
            let rightStartPoint = CGPoint(x: origin.x + width * cos(angle), y: origin.y - width * sin(angle))
            context.insertParallelogram(at: rightStartPoint, -angle, height, -length)
            
            // back
            let backStartPoint = CGPoint(x: origin.x - length * cos(angle), y: origin.y - length * sin(angle))
            context.insertParallelogram(at: backStartPoint, angle, height, width)
            
            // column dividers
            var columnDividerStartPoints: [CGPoint] = []
            for i in 1 ... columnDividerCount {
                columnDividerStartPoints.append(CGPoint(
                    x: origin.x + Double(i) / Double(columnDividerCount + 1) * width * cos(angle),
                    y: origin.y - Double(i) / Double(columnDividerCount + 1) * width * sin(angle)
                ))
                context.insertParallelogram(at: columnDividerStartPoints[i - 1], -angle, height, -length)
            }
            
            // row divider
            let rowDividerStartPoint = CGPoint(x: origin.x - length / 2 * cos(angle), y: origin.y - length / 2 * sin(angle))
            if needsRowDivider {
                context.insertParallelogram(at: rowDividerStartPoint, angle, height, width)
            }
            
            context.strokePath()
            context.setAlpha(0.2)
            
            switch section {
            case .TOP:
                context.shadeParallelogram(at: origin, angle, length, width, needsVertical: false)
            case .BOTTOM:
                context.shadeParallelogram(at: bottomStartPoint, angle, length, width, needsVertical: false)
            case .LEFT_RIGHT:
                context.shadeParallelogram(at: origin, -angle, height, length, movingLeft: true)
                context.shadeParallelogram(at: rightStartPoint, -angle, height, -length)
            case .FRONT_BACK:
                context.shadeParallelogram(at: origin, angle, height, width)
                context.shadeParallelogram(at: backStartPoint, angle, height, width)
            case .COLUMN_DIVIDER:
                for i in 1 ... columnDividerCount {
                    context.shadeParallelogram(at: columnDividerStartPoints[i - 1], -angle, height, -length)
                }
            case .ROW_DIVIDER:
                context.shadeParallelogram(at: rowDividerStartPoint, angle, height, width)
            }
            
            context.strokePath()
            context.setAlpha(1)
            
            switch section {
            case .TOP:
                context.insertParallelogram(at: origin, angle, length, width, needsVertical: false)
            case .BOTTOM:
                context.insertParallelogram(at: bottomStartPoint, angle, length, width, needsVertical: false)
            case .LEFT_RIGHT:
                context.insertParallelogram(at: origin, -angle, height, -length)
                context.insertParallelogram(at: rightStartPoint, -angle, height, -length)
            case .FRONT_BACK:
                context.insertParallelogram(at: origin, angle, height, width)
                context.insertParallelogram(at: backStartPoint, angle, height, width)
            case .COLUMN_DIVIDER:
                for i in 1 ... columnDividerCount {
                    context.insertParallelogram(at: columnDividerStartPoints[i - 1], -angle, height, -length)
                    
                    if needsRowDivider {
                        context.move(to: CGPoint(x: x.getLast() - length / 2 * cos(angle), y: y.getLast() - length / 2 * sin(angle)))
                        context.addLine(to: CGPoint(x: x.getLast(), y: y.getLast() + height))
                    }
                }
            case .ROW_DIVIDER:
                context.insertParallelogram(at: rowDividerStartPoint, angle, height, width)
            }
            
            context.strokePath()
        }
    }
    
}

extension CGContext {
    func insertParallelogram(at point: CGPoint, _ angle: Double, _ length: Double, _ width: Double, needsVertical: Bool = true) {
        // getLast() constants
        let x = 0
        let y = 1
        
        move(to: point)
        addLine(to: CGPoint(
            x: x.getLast() - (needsVertical ? 0 : length * cos(angle)),
            y: y.getLast() - length * (needsVertical ? -1 : sin(angle))
        ))
        addLine(to: CGPoint(
            x: x.getLast() + width * cos(angle),
            y: y.getLast() - width * sin(angle)
        ))
        addLine(to: CGPoint(
            x: x.getLast() + (needsVertical ? 0 : length * cos(angle)),
            y: y.getLast() + length * (needsVertical ? -1 : sin(angle))
        ))
        addLine(to: point)
    }
    
    func shadeParallelogram(at point: CGPoint, _ angle: Double, _ length: Double, _ width: Double, movingLeft: Bool = false, needsVertical: Bool = true) {
        // getLast() constants
        let x = 0
        let y = 1
        
        if needsVertical {
            for i in 0 ... Int(length) {
                move(to: CGPoint(x: point.x, y: point.y + Double(i)))
                addLine(to: CGPoint(
                    x: x.getLast() + (movingLeft ? -width * cos(angle) : width * cos(angle)),
                    y: y.getLast() + (movingLeft ? width * sin(angle) : -width * sin(angle))
                ))
            }
        } else {
            var across = 0.0
            var down = 0.0
            var newPoint = point
            while hypot(newPoint.x - point.x, newPoint.y - point.y) < length {
                newPoint = CGPoint(x: point.x - across, y: point.y - down)
                move(to: newPoint)
                addLine(to: CGPoint(
                    x: x.getLast() + width * cos(angle),
                    y: y.getLast() - width * sin(angle)
                ))
                across += cos(angle)
                down += sin(angle)
            }
        }
    }
}

extension Double {
    func toRadians() -> Double {
        return self * 3.14159265358979 / 180
    }
}
