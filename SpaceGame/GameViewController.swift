//
//  GameViewController.swift
//  SpaceGame
//
//  Created by yerinaoh on 2016. 9. 1..
//  Copyright (c) 2016년 yerinaoh. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks")
        
        let scneneData = NSData(contentsOfFile:path!)
        let archiver = NSKeyedUnarchiver(forReadingWithData:scneneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        
        return scene
    }
    
}


class GameViewController: UIViewController {

    var backgroundMusicplayer : AVAudioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if let scene = GameScene(fileNamed:"GameScene") {
//            // Configure the view.
//            let skView = self.view as! SKView
//            skView.showsFPS = true
//            skView.showsNodeCount = true
//            
//            /* Sprite Kit applies additional optimizations to improve rendering performance */
//            skView.ignoresSiblingOrder = true
//            
//            /* Set the scale mode to scale to fit the window */
//            scene.scaleMode = .AspectFill
//            
//            skView.presentScene(scene)
//        }
    }

    override func viewWillLayoutSubviews() {
        
        let bgMusicURL : NSURL = NSBundle.mainBundle().URLForResource("bgmusic", withExtension: "mp3")!
        
        do {
            try
                backgroundMusicplayer = AVAudioPlayer(contentsOfURL: bgMusicURL)
                backgroundMusicplayer.numberOfLoops = -1
                backgroundMusicplayer.prepareToPlay()
                backgroundMusicplayer.play()
            
        } catch {
            print("error")
        }

        let skView : SKView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = true
        
        let scene : SKScene = GameScene(size: skView.bounds.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        skView.presentScene(scene)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
