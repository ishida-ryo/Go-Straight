//
//  ViewController.swift
//  Go Straight
//
//  Created by 石田陵 on 2017/05/01.
//  Copyright © 2017年 ryo.ishida. All rights reserved.
//

import UIKit
import SpriteKit
class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let skView = self.view as! SKView
    skView.showsFPS = true
    
    skView.showsNodeCount = true
    
    let scene = GameScene(fileNamed: "GameScene")
    
    scene?.scaleMode = .aspectFill
    
    skView.presentScene(scene)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

