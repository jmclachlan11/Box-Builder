//
//  PrintViewController.swift
//  Box Builder
//
//  Created by Jacob McLachlan on 6/27/22.
//

import UIKit
import WebKit

class PrintViewController: UIViewController {
    
    // incoming values
    var box = ResultViewController.Box(woodThickness: 0, count: 0, rows: 0)
    var roll = ResultViewController.Roll(name: "", length: 0, diameter: 0)
    var top = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var bottom = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var leftRight = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var frontBack = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var columnDivider = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var rowDivider = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    
    let hapticNormal = UIImpactFeedbackGenerator(style: .medium)
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get path for pdf
        guard let path = getDocumentPath()?.path else { return }
        UIGraphicsBeginPDFContextToFile(path, .zero, nil)
        
        // draw views
        for i in 0 ..< (box.rows == 1 ? 5 : 6) {
            UIGraphicsBeginPDFPage()
            let drawWoodPiece = DrawWoodPiece(frame: UIGraphicsGetPDFContextBounds())
            
            drawWoodPiece.isForPrinting = true
            drawWoodPiece.color = (long: UIColor.black, middle: UIColor.black, short: UIColor.black, label: UIColor.black)
            drawWoodPiece.backgroundColor = UIColor.white
            
            // send data to draw wood piece
            switch i {
            case 0:
                drawWoodPiece.piece = top
            case 1:
                drawWoodPiece.piece = bottom
            case 2:
                drawWoodPiece.piece = leftRight
            case 3:
                drawWoodPiece.piece = frontBack
            case 4:
                drawWoodPiece.piece = columnDivider
            default:
                drawWoodPiece.piece = rowDivider
            }
            
            drawWoodPiece.slide = i
            drawWoodPiece.box = box
            drawWoodPiece.roll = roll
            drawWoodPiece.sendToModel = (
                length: top.length,
                width: top.width,
                height: leftRight.height
            )

            drawWoodPiece.draw(CGRect())

        }
        UIGraphicsEndPDFContext()
        
        // show pdf in web view
        if let url = getDocumentPath() {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
    
    @IBAction func printAction(_ sender: Any) {
        if let url = getDocumentPath() {
            hapticNormal.impactOccurred()
            
            // print preview
            if UIPrintInteractionController.canPrint(url) {
                let printInfo = UIPrintInfo(dictionary: nil)
                printInfo.jobName = url.lastPathComponent
                printInfo.outputType = .general

                let printController = UIPrintInteractionController.shared
                printController.printInfo = printInfo
                printController.showsNumberOfCopies = false
                printController.printingItem = url

                printController.present(animated: true, completionHandler: nil)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func getDocumentPath() -> URL? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return documentsURL.appendingPathComponent("box.pdf")
    }
}
