//
//  DetailViewController.swift
//  Box Builder
//
//  Created by Jacob McLachlan on 6/17/22.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    // incoming values
    var box = ResultViewController.Box(woodThickness: 0, count: 0, rows: 0)
    var roll = ResultViewController.Roll(name: "", length: 0, diameter: 0)
    var top = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var bottom = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var leftRight = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var frontBack = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var columnDivider = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    var rowDivider = ResultViewController.WoodPiece(title: "", quantity: 0, length: 0, width: 0, height: 0, modelAngle: 0)
    
    var sendToPrint = false
    
    // layout constants
    let pageControlOffset: CGFloat = 100
    let backButtonOffset: CGFloat = 90
    lazy var width = view.frame.size.width
    lazy var height = view.frame.size.height
    
    let hapticNormal = UIImpactFeedbackGenerator(style: .medium)
    
    let pageControl = UIPageControl()
    let scrollView = UIScrollView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // set up scroll view
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)

        // set up page control
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)
        view.addSubview(pageControl)
        
        // go straight to print view controller if print button was pressed
        if sendToPrint {
            sendToPrint = false
            DispatchQueue.main.async() {
               self.performSegue(withIdentifier: "detailToPrint", sender: self)
            }
        }
                
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let pageControlOffsetX: CGFloat = 10
        pageControl.frame = CGRect(x: pageControlOffsetX, y: height - pageControlOffset, width: width - 2 * pageControlOffsetX, height: 70)
        scrollView.frame = CGRect(x: 0, y: backButtonOffset, width: width, height: height - backButtonOffset - pageControlOffset)
        
        if scrollView.subviews.count == 1 {
            scrollView.contentSize = CGSize(width: width * CGFloat(pageControl.numberOfPages), height: height - backButtonOffset - pageControlOffset)
            scrollView.isPagingEnabled = true
            
            // draw view for each slide
            for i in 0 ..< pageControl.numberOfPages {
                let drawWoodPiece = DrawWoodPiece(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: scrollView.frame.size.height))
                drawWoodPiece.backgroundColor = UIColor.systemBackground
                
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
                drawWoodPiece.roll = roll
                drawWoodPiece.box = box
                drawWoodPiece.sendToModel = (
                    length: top.length,
                    width: top.width,
                    height: leftRight.height
                )

                scrollView.addSubview(drawWoodPiece)
            }
        }
    }
    
    @objc func pageControlChanged(_ sender: UIPageControl) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(sender.currentPage) * width, y: 0), animated: true)
    }
    
    @IBAction func sendToPrint(_ sender: Any) {
        hapticNormal.impactOccurred()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // send data to print view controller
        if let printVC = segue.destination as? PrintViewController {
            printVC.box = box
            printVC.roll = roll
            
            printVC.top = top
            printVC.bottom = bottom
            printVC.leftRight = leftRight
            printVC.frontBack = frontBack
            printVC.columnDivider = columnDivider
            printVC.rowDivider = rowDivider
            
            printVC.modalPresentationStyle = .fullScreen
        }
    }
}

extension DetailViewController: UIScrollViewDelegate {
    // change page control when scroll view is swiped
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
    }
}
