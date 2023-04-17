//
//  ViewController.swift
//  Box Builder
//
//  Created by Jacob McLachlan on 6/10/22.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    // used for validating text field input
    enum Stage { case STRING, DOUBLE }
    
    // machine menu
    var machineDictionary: [(name: String, dimension: (length: String?, diameter: String?))] = [(name: "Custom", dimension: (nil, nil))]
    var selectedMachine: String? = nil
    
    let hapticNormal = UIImpactFeedbackGenerator(style: .medium)
    let hapticSpecial = UINotificationFeedbackGenerator()
        
    // inputs
    var rollCount = 6
    var shouldForceRowCount = false
    var forcedRowCount = 1
    var rollLength = 0.0
    var rollDiameter = 0.0
    var woodThickness = 0.0
    lazy var inputs = [rollLength, rollDiameter, woodThickness]
    
    @IBOutlet weak var machineSelectButton: UIButton!
    
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var diameterTextField: UITextField!
    @IBOutlet weak var thicknessTextField: UITextField!
    lazy var textFields = [lengthTextField, diameterTextField, thicknessTextField]
    
    @IBOutlet weak var rollCountSegmentedControl: UISegmentedControl!
    @IBOutlet weak var forceRowSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var forceRowSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up machine select
        fillMachineDictionary()
        var children: [UIAction] = []
        for (name, dimension) in machineDictionary {
            children.append(UIAction(title: name, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [self] _ in
                if let lengthFromDictionary = dimension.length {
                    lengthTextField.text = String(lengthFromDictionary)
                }
                if let diameterFromDictionary = dimension.diameter {
                    diameterTextField.text = String(diameterFromDictionary)
                }
            }))
        }
        machineSelectButton.menu = UIMenu(title: "Select machine", image: nil, identifier: nil, options: [], children: children)
        
        lengthTextField.delegate = self
        diameterTextField.delegate = self
        thicknessTextField.delegate = self
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        // restore preferences
        rollCount = UserDefaults.standard.integer(forKey: "roll count")
        rollCountSegmentedControl.selectedSegmentIndex = rollCount == 10 ? 1 : 0
        rollCountChanged(self)
        forcedRowCount = UserDefaults.standard.integer(forKey: "forced row count")
        forceRowSegmentedControl.selectedSegmentIndex = forcedRowCount == 2 ? 1 : 0
        shouldForceRowCount = UserDefaults.standard.bool(forKey: "should force row count")
        forceRowSwitch.isOn = shouldForceRowCount
        
        // decimal pad toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let upButton = UIBarButtonItem(title: "🔼", style: .plain, target: self, action: #selector(previousTextField))
        let downButton = UIBarButtonItem(title: "🔽", style: .plain, target: self, action: #selector(nextTextField))
        let fractionButton = UIBarButtonItem(title: "/", style: .plain, target: self, action: #selector(fraction))
        let decimalButton = UIBarButtonItem(title: "•", style: .done, target: self, action: #selector(decimal))
        let spaceButton = UIBarButtonItem(title: "Space", style: .plain, target: self, action: #selector(space))
        toolbar.items = [flexibleSpace, decimalButton, flexibleSpace, spaceButton, flexibleSpace, fractionButton, flexibleSpace, upButton, downButton]
        toolbar.sizeToFit()
        for textField in textFields {
            textField?.inputAccessoryView = toolbar
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // force keyboard to appear
        lengthTextField.becomeFirstResponder()
    }

    @objc func nextTextField() {
        if lengthTextField.isFirstResponder {
            hapticNormal.impactOccurred()
            diameterTextField.becomeFirstResponder()
        } else if diameterTextField.isFirstResponder {
            hapticNormal.impactOccurred()
            thicknessTextField.becomeFirstResponder()
        }
    }
    
    @objc func previousTextField() {
        if diameterTextField.isFirstResponder {
            hapticNormal.impactOccurred()
            lengthTextField.becomeFirstResponder()
        } else if thicknessTextField.isFirstResponder {
            hapticNormal.impactOccurred()
            diameterTextField.becomeFirstResponder()
        }
    }
    
    @objc func fraction() {
        insertCharacter("/")
    }
    
    @objc func decimal() {
        insertCharacter(".")
    }
    
    @objc func space() {
        insertCharacter(" ")
    }
    
    func insertCharacter(_ attemptingToAppend: Character) {
        var currentInput = getFirstResponder().text ?? ""
                                                                                                            // MARK: disallow
        if currentInput.contains(attemptingToAppend)                                                        // duplicate
        || (currentInput == "" && (attemptingToAppend == " " || attemptingToAppend == "/"))                 // leading space or /
        || ((currentInput.contains("/") || currentInput.contains(" ")) && attemptingToAppend == ".")        // adding . with space or / present
        || (currentInput.contains(".") && (attemptingToAppend == "/" || attemptingToAppend == " "))         // adding space or / with . present
        || (currentInput.contains("/") && attemptingToAppend == " ")                                        // adding space with / present
        || (currentInput.last == " " && attemptingToAppend == "/") {                                        // adding / immediately after space
            hapticSpecial.notificationOccurred(.error)
        } else {
            // allow character
            currentInput.append(attemptingToAppend)
            getFirstResponder().text = currentInput
        }
    }
    
    func getFirstResponder() -> UITextField {
        return lengthTextField.isFirstResponder ? lengthTextField : diameterTextField.isFirstResponder ? diameterTextField : thicknessTextField
    }
    
    @IBAction func clearAll(_ sender: Any) {
        if sender as? ViewController != self {
            hapticNormal.impactOccurred()
        }
        for textField in textFields {
            textField?.text = ""
        }
    }
    
    // switch
    @IBAction func rowCountForceChanged(_ sender: Any) {
        if sender as? ViewController != self {
            hapticNormal.impactOccurred()
        }
        shouldForceRowCount = forceRowSwitch.isOn
        UserDefaults.standard.set(shouldForceRowCount, forKey: "should force row count")
    }
    
    // segmented control
    @IBAction func rowCountChanged(_ sender: Any) {
        hapticNormal.impactOccurred()
        forcedRowCount = forceRowSegmentedControl.selectedSegmentIndex == 0 ? 1 : 2
        UserDefaults.standard.set(forcedRowCount, forKey: "forced row count")
    }
    
    @IBAction func rollCountChanged(_ sender: Any) {
        if sender as? ViewController != self {
            hapticNormal.impactOccurred()
        }
        rollCount = rollCountSegmentedControl.selectedSegmentIndex == 0 ? 6 : 10
        UserDefaults.standard.set(rollCount, forKey: "roll count")

        // turn off force for 10 rolls
        if rollCount == 10 {
            forceRowSwitch.isOn = false
            rowCountForceChanged(self)
        }
    }
    
    @IBAction func build(_ sender: Any) {
        // check for runtime errors
        if canContinueBuild(Stage.STRING) {
            rollLength = stringToDouble(lengthTextField.text ?? "")
            rollDiameter = stringToDouble(diameterTextField.text ?? "")
            woodThickness = stringToDouble(thicknessTextField.text ?? "")
              
            inputs = [rollLength, rollDiameter, woodThickness]
            
            // check for overflow
            if canContinueBuild(Stage.DOUBLE) {
                
                for (name, dimension) in machineDictionary {
                    if stringToDouble(dimension.length ?? "") == rollLength && stringToDouble(dimension.diameter ?? "") == rollDiameter {
                        selectedMachine = name
                        break
                    }
                    selectedMachine = nil
                }
                
                // build
                hapticSpecial.notificationOccurred(.success)
            }
        }
    }
    
    func stringToDouble(_ string: String) -> Double {
        // no fraction
        if !string.contains("/") {
            return Double(string) ?? 0
        }

        // mixed number or fraction
        let mixedArray = string.contains(" ") ? string.components(separatedBy: " ") : ["0", string]
        let fractionArray = mixedArray[1].components(separatedBy: "/")
        return (Double(mixedArray[0]) ?? 0) + (Double(fractionArray[0]) ?? 0) / (Double(fractionArray[1]) ?? 1)
    }
    
    func canContinueBuild(_ stage: Stage) -> Bool {
        switch stage {
        case .STRING:
            for textField in textFields {
                var input = textField?.text ?? ""
                
                // remove trailing space
                if input.last == " " {
                    input.remove(at: input.index(before: input.endIndex))
                    textField?.text = input
                }
                
                // disallow 123 456 and ending in /
                if (input.contains(" ") && !input.contains("/")) || input.last == "/" {
                    reportError("Invalid format")
                    return false
                }
                // disallow /0
                if let i = input.firstIndex(of: "/") {
                    if input.contains("/") && input[input.index(input.startIndex, offsetBy: Int(input.distance(from: input.startIndex, to: i)) + 1)] == "0" {
                        reportError("Divide by 0")
                        return false
                    }
                }
                // empty field
                if input == "" {
                    reportError("Empty field")
                    return false
                }
                // force 10 rolls 1 row
                if forceRowSwitch.isOn && rollCountSegmentedControl.selectedSegmentIndex == 1 && forceRowSegmentedControl.selectedSegmentIndex == 0 {
                    reportError("Invalid configuration: 10 rolls, 1 row")
                    return false
                }
            }
            return true
            
        case .DOUBLE:
            for input in inputs {
                // overflow
                if input > 9999 || input < 0.0001 {
                    reportError("Overflow")
                    return false
                }
            }
            return true
        }
        
    }
    
    func reportError(_ error: String) {
        hapticSpecial.notificationOccurred(.error)
        
        let dialogMessage = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        dialogMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in }))
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func fillMachineDictionary() {
        let machineNames = [
            "911.25", "912.5", "914.5", "916", "920",
            "922", "924R", "926", "927", "930",
            "935", "940", "AYZ", "AY", "AYY",
            "AXY", "AX", "AXN", "AN", "A0",
            "A1", "A2", "WS1 / WS101", "WS1A / WS101A", "WS2 / WS102",
            "WS3 / WS103", "WS4 / WS104", "WS5 / WS105", "WS6 / WS106", "WS6HD / WS106HD",
            "WS7 / WS107", "WS8 / WS108"
        ]
        
        // [length, diameter]
        let dimensions: [[String]] = [
            ["2.188", "0.566"], ["3", "1.132"], ["5 3/16", "2.030"], ["6 9/16", "2.543"], ["8 15/16", "3.672"],
            ["11 3/16", "4.621"], ["12 23/32", "5.283"], ["18 1/2", "5.526"], ["15 5/8", "6.215"], ["17 3/8", "7.147"],
            ["22 5/8", "8.806"], ["27 3/8", "11.27"], ["2 11/16", "0.879"], ["5 15/16", "1.791"], ["7 13/32", "2.725"],
            ["9 1/2", "3.698"], ["14", "4.576"], ["19 11/16", "5.916"], ["21 3/16", "7.126"], ["24 3/4", "9.269"],
            ["27 5/16", "10.907"], ["26 3/4", "12.140"], ["3.051", "1.142"], ["4.843", "1.772"], ["9.843", "3.543"],
            ["15", "4.331"], ["17.205", "5.512"], ["20.079", "7"], ["24.213", "8.858"], ["23.228", "8.858"],
            ["27.402", "10.236"], ["31.496", "11.811"]
        ]
        
        for i in 0 ..< machineNames.count {
            machineDictionary.append((name: machineNames[i], dimension: (length: dimensions[i][0], diameter: dimensions[i][1])))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // send parameters to result view controller
        if let resultVC = segue.destination as? ResultViewController {
            resultVC.incomingName = selectedMachine
            resultVC.incomingRollCount = Double(rollCount)
            resultVC.incomingRollLength = rollLength
            resultVC.incomingRollDiameter = rollDiameter
            resultVC.incomingWoodThickness = woodThickness
            resultVC.incomingForceRow = (isForced: shouldForceRowCount, count: forcedRowCount)
            
            resultVC.modalPresentationStyle = .fullScreen
        }
    }
    
    // filters keyboard input to only allow numbers and "."
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "1234567890. /")
        let typedCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
}

// orientation lock
struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}
