//
//  ResultViewController.swift
//  Box Builder
//
//  Created by Jacob McLachlan on 6/10/22.
//

import UIKit

class ResultViewController: UIViewController {
    
    // dictated constants
    let tolerance: Double = 1.0 / 8.0
    let maxLengthForSingleRow = 8.0
    
    let hapticNormal = UIImpactFeedbackGenerator(style: .medium)
    
    enum Piece { case TOP, BOTTOM, EDGE_LEFT_RIGHT, EDGE_FRONT_BACK, COLUMN_DIVIDER, ROW_DIVIDER }
    
    // incoming parameters
    var incomingName: String? = nil
    var incomingRollCount = 0.0
    var incomingRollLength = 0.0
    var incomingRollDiameter = 0.0
    var incomingWoodThickness = 0.0
    var incomingForceRow = (isForced: false, count: 1)
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var drawBox: DrawBox!
    @IBOutlet weak var statsLabel: UILabel!
        
    struct Box {
        let woodThickness: Double
        let count: Double
        let rows: Int
    }
    
    struct Roll {
        let name: String?
        let length: Double
        let diameter: Double
    }
    
    struct WoodPiece {
        let title: String
        let quantity: Int
        let length: Double
        let width: Double
        let height: Double
        let modelAngle: Double
    }
    
    lazy var roll = Roll(
        name: incomingName,
        length: incomingRollLength,
        diameter: incomingRollDiameter
    )
    
    lazy var box = Box(
        woodThickness: incomingWoodThickness,
        count: incomingRollCount,
        rows:                                                                                           // MARK: reason (number)
            (roll.length > maxLengthForSingleRow                                                        // 6 rolls, too long (2)
            || incomingRollCount == 10                                                                  // 10 rolls (2)
            || (incomingForceRow.isForced && incomingForceRow.count == 2))                              // forced (2)
            && !(incomingForceRow.isForced && incomingForceRow.count == 1) ? 2 : 1                      // forced (1)
    )
    
    lazy var top = WoodPiece(
        title: "Top",
        quantity: 1,
        length: getLength(of: Piece.TOP, box, roll),
        width: getWidth(of: Piece.TOP, box, roll),
        height: getHeight(of: Piece.TOP, box, roll),
        modelAngle: 35.0
    )
    lazy var bottom = WoodPiece(
        title: "Bottom",
        quantity: 1,
        length: getLength(of: Piece.BOTTOM, box, roll),
        width: getWidth(of: Piece.BOTTOM, box, roll),
        height: getHeight(of: Piece.BOTTOM, box, roll),
        modelAngle: 35.0
    )
    lazy var leftRightEdge = WoodPiece(
        title: "Left / Right",
        quantity: 2,
        length: getLength(of: Piece.EDGE_LEFT_RIGHT, box, roll),
        width: getWidth(of: Piece.EDGE_LEFT_RIGHT, box, roll),
        height: getHeight(of: Piece.EDGE_LEFT_RIGHT, box, roll),
        modelAngle: 35.0
    )
    lazy var frontBackEdge = WoodPiece(
        title: "Front / Back",
        quantity: 2,
        length: getLength(of: Piece.EDGE_FRONT_BACK, box, roll),
        width: getWidth(of: Piece.EDGE_FRONT_BACK, box, roll),
        height: getHeight(of: Piece.EDGE_FRONT_BACK, box, roll),
        modelAngle: 35.0
    )
    lazy var columnDivider = WoodPiece(
        title: "Column Divider",
        quantity: box.rows == 1 ? 5 : box.count == 6 ? 4 : 8,
        length: getLength(of: Piece.COLUMN_DIVIDER, box, roll),
        width: getWidth(of: Piece.COLUMN_DIVIDER, box, roll),
        height: getHeight(of: Piece.COLUMN_DIVIDER, box, roll),
        modelAngle: 35.0
    )
    lazy var rowDivider = WoodPiece(
        title: "Row Divider",
        quantity: 1,
        length: getLength(of: Piece.ROW_DIVIDER, box, roll),
        width: getWidth(of: Piece.ROW_DIVIDER, box, roll),
        height: getHeight(of: Piece.ROW_DIVIDER, box, roll),
        modelAngle: 35.0
    )
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // stats label
        statsLabel.numberOfLines = 0
        let stats = NSMutableAttributedString(
            string: "Configuration",
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
        )
        stats.append(NSAttributedString(string: "\nRolls: \(Int(box.count))\t\tRows: \(box.rows)"))
        statsLabel.attributedText = stats
        
        // MARK: scroll view is deprecated
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.isScrollEnabled = false
                
        // send data to draw box
        drawBox.box = box
    }
    
    @IBAction func viewPieces(_ sender: Any) {
        hapticNormal.impactOccurred()
    }
    
    // TODO: fix
    @IBAction func print(_ sender: Any) {
        hapticNormal.impactOccurred()
    }
    
//    func getLength(of piece: Piece, _ box: Box, _ roll: Roll) -> Double {
//        var n = 0.0
//
//        switch piece {
//        case .TOP_BOTTOM:
//            if box.rows == 1 {
//                n += roll.length
//                n += 2 * box.woodThickness
//                n += 2 * tolerance
//            } else {
//                // 2 rows
//                n += 2 * roll.length
//                n += 3 * box.woodThickness
//                n += 4 * tolerance
//            }
//
//        case .EDGE_LEFT_RIGHT:
//            if box.rows == 1 {
//                n += roll.length
//                n += 2 * tolerance
//            } else {
//                // 2 rows
//                n += 2 * roll.length
//                n += box.woodThickness
//                n += 4 * tolerance
//            }
//
//        case .COLUMN_DIVIDER:
//            n += roll.length
//            n += 2 * tolerance
//
//        case .EDGE_FRONT_BACK, .ROW_DIVIDER:
//            n += box.woodThickness
//        }
//
//        return n
//    }
//
//    func getWidth(of piece: Piece, _ box: Box, _ roll: Roll) -> Double {
//        var n = 0.0
//
//        switch piece {
//        case .TOP_BOTTOM, .EDGE_FRONT_BACK:
//            if box.rows == 1 {
//                n += box.count * roll.diameter
//                n += (box.count + 1) * box.woodThickness
//                n += 2 * box.count * tolerance
//            } else {
//                // 2 rows
//                n += box.count / 2 * roll.diameter
//                n += (box.count / 2 + 1) * box.woodThickness
//                n += box.count * tolerance
//            }
//
//        case .ROW_DIVIDER:
//            if box.rows == 1 {
//                n += box.count * roll.diameter
//                n += (box.count - 1) * box.woodThickness
//                n += 2 * box.count * tolerance
//            } else {
//                // 2 rows
//                n += box.count / 2 * roll.diameter
//                n += (box.count / 2 - 1) * box.woodThickness
//                n += box.count * tolerance
//            }
//
//        case .COLUMN_DIVIDER, .EDGE_LEFT_RIGHT:
//            n += box.woodThickness
//        }
//
//        return n
//    }
//
//    func getHeight(of piece: Piece, _ box: Box, _ roll: Roll) -> Double {
//        var n = 0.0
//
//        switch piece {
//        case .EDGE_LEFT_RIGHT, .EDGE_FRONT_BACK, .COLUMN_DIVIDER, .ROW_DIVIDER:
//            n += roll.diameter
//            n += 2 * tolerance
//
//        case .TOP_BOTTOM:
//            n += box.woodThickness
//        }
//
//        return n
//    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // send parameters to detail view controller
        if let detailVC = segue.destination as? DetailViewController {
            detailVC.pageControl.numberOfPages = box.rows == 1 ? 5 : 6
            
            detailVC.box = box
            detailVC.roll = roll
            detailVC.top = top
            detailVC.bottom = bottom
            detailVC.leftRight = leftRightEdge
            detailVC.frontBack = frontBackEdge
            detailVC.columnDivider = columnDivider
            detailVC.rowDivider = rowDivider

            detailVC.modalPresentationStyle = .fullScreen
            
            if segue.identifier == "sentFromPrintButton" {
                detailVC.sendToPrint = true
            }
        }
    }
    
    func getLength(of piece: Piece, _ box: Box, _ roll: Roll) -> Double {
        var n = 0.0
        
        switch piece {
        case .TOP, .BOTTOM, .EDGE_LEFT_RIGHT:
            n += roll.length
            n += piece == .TOP ? 2 * box.woodThickness : 0
            n += 2 * tolerance
            if box.rows == 2 {
                n += roll.length
                n += box.woodThickness
                n += 2 * tolerance
            }
        case .EDGE_FRONT_BACK, .ROW_DIVIDER:
            n += box.woodThickness
        case .COLUMN_DIVIDER:
            n += roll.length
            n += 2 * tolerance
        }
    
        return n
    }
    
    func getWidth(of piece: Piece, _ box: Box, _ roll: Roll) -> Double {
        var n = 0.0
        
        switch piece {
        case .TOP, .EDGE_FRONT_BACK, .BOTTOM, .ROW_DIVIDER:
            n += box.count / 2 * roll.diameter
            n += (box.count / 2 + (piece == .BOTTOM || piece == .ROW_DIVIDER ? -1 : 1)) * box.woodThickness
            
            // MARK: edit: tolerance decreased from 2x rolls in row
            n += tolerance
            if box.rows == 1 {
                n += box.count / 2 * roll.diameter
                n += box.count / 2 * box.woodThickness
            }
        case .EDGE_LEFT_RIGHT, .COLUMN_DIVIDER:
            n += box.woodThickness
        }
        
        return n
    }
    
    func getHeight(of piece: Piece, _ box: Box, _ roll: Roll) -> Double {
        var n = 0.0
        
        switch piece {
        case .TOP, .BOTTOM:
            n += box.woodThickness
        case .EDGE_LEFT_RIGHT, .EDGE_FRONT_BACK, .COLUMN_DIVIDER, .ROW_DIVIDER:
            n += roll.diameter
            n += piece == .EDGE_LEFT_RIGHT || piece == .EDGE_FRONT_BACK ? box.woodThickness : 0
            
            // MARK: edit: tolerance decreased by 1/8
            n += tolerance
        }
        
        return n
    }
    
}

// MARK: scroll view is deprecated
extension ResultViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drawBox
    }
}
