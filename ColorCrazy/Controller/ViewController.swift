//  ViewController.swift
//  ColorCrazy

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoStack: UIStackView!
    
    var score = 0
    var target = ""
    var seconds = 30
    var timer = Timer()
    var isTimerRunning = false
    let dataObject = DataFile()
    var audioPlayer = AVAudioPlayer()
    let explosion = SCNParticleSystem(named: "Explosion", inDirectory: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.showsStatistics = true
        // Set goal of game
        setTarget()
        // place nodes in world space
        placeNode()
        // Start timer
        runTimer()
        //play background music
        playBackgroundMusic()
    }
    
    
    // MARK: - create and place text nodes
    
    func createNode() {
        let scale = randomScale()
        let color = randomColor()
        let text = SCNText(string: randomText(), extrusionDepth: 1)
        // create a material object, set color
        let material = SCNMaterial()
        material.diffuse.contents = color
        text.materials = [material]
        // create the node object, set position & scale & text geometry
        let node = SCNNode()
        // set the name as a color
        node.name = color.name!
        node.position = SCNVector3(randomXValue(), randonYValue(), randomZValue())
        node.scale = SCNVector3(scale, scale, scale)
        node.geometry = text
        sceneView.scene.rootNode.addChildNode(node)
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func placeNode() {for _ in 0...200 {createNode()}}
    
    
    // MARK: - random generators
    
    func randomColor() -> UIColor {return dataObject.colorArray.randomElement()!}
    func randomText() -> String {return dataObject.textArray.randomElement()!}
    // left to right
    func randomXValue() -> Float {return Float.random(in: -0.60..<0.40)}
    //up to down
    func randonYValue() -> Float {return Float.random(in: -0.50..<0.50)}
    // in front to behind
    func randomZValue() -> Float {return Float.random(in: -1.30 ..< -0.20)}
    func randomScale() -> Float {return Float.random(in: 0.0025 ..< 0.004)}
    
    
    // MARK: - touch, explode, and sound functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        //if I could swap this out with the location of the camera then id be somewhere
        let location = touch.location(in: sceneView)
        let hitList = sceneView.hitTest(location, options: nil)
        
        if let hitObject = hitList.first {
            let node = hitObject.node
            if node.name == target  {
                print(node.name!)
                score += 3
                removeInstructions()
                // play audio
                playAudio(fileName: "blast")
                // trigger particle explosion
                node.addParticleSystem(explosion!)
                // wait
                let waitAction = SCNAction.wait(duration: 0.2)
                // remove node
                node.runAction(waitAction, completionHandler: {
                    node.removeFromParentNode()
                })
                DispatchQueue.main.async {
                    self.scoreLabel.text = String(self.score)
                }
            }
        }
    }
    
    func playBackgroundMusic(){
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: "background.wav")!
        audioSource.volume = 0.01
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        audioNode.addAudioPlayer(audioPlayer)
        let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
        audioNode.runAction(play)
        sceneView.scene.rootNode.addChildNode(audioNode)
    }
    
    func playAudio(fileName: String) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: "wav")!))
        } catch {print(error)}
        audioPlayer.play()
    }
    
    
    // MARK: gameplay functions
    
    // Set goal of game
    func setTarget() {
        target = (dataObject.colorArray.randomElement()?.name)!
        infoLabel.text = "Tap on \(target.capitalizingFirstLetter())"
    }
    
    func removeInstructions() {
        if score > 0 {
            infoStack.isHidden = true
        }
    }
    
    func gameOver(){
        //store the score in UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: "score")
        //go back to the Home View Controller
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: timer functions
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds == 0 {
            timer.invalidate()
            gameOver()
        }else{
            seconds -= 1
            timerLabel.text = "\(seconds)"
        }
    }
    
    func resetTimer(){
        timer.invalidate()
        seconds = 30
        timerLabel.text = "\(seconds)"
    }
    

    // MARK: - view functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
}

extension UIColor {
    var name: String? {
        switch self {
        case UIColor.black: return "black"
        case UIColor.darkGray: return "darkGray"
        case UIColor.lightGray: return "lightGray"
        case UIColor.white: return "white"
        case UIColor.gray: return "gray"
        case UIColor.red: return "red"
        case UIColor.green: return "green"
        case UIColor.blue: return "blue"
        case UIColor.cyan: return "cyan"
        case UIColor.yellow: return "yellow"
        case UIColor.magenta: return "magenta"
        case UIColor.orange: return "orange"
        case UIColor.purple: return "purple"
        case UIColor.brown: return "brown"
        default: return nil
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
