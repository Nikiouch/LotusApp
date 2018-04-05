//
//  ViewController.swift
//  Lotus
//
//  Created by Nikita Glavatskiy on 13/02/2018.
//  Copyright © 2018 Dreamers. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation

class ViewController: UIViewController {
    
    private var headphones : Bool = false{
        didSet{
            if !headphones {
                AudioKit.stop()
                didRecordStart = false
            }
        }
    }
    var mic : AKMicrophone!
    var silence: AKBooster!
    var didRecordStart = false
    
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var VolumeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        
        if currentRoute.outputs.count != 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphone plugged in")
                } else {
                    print("headphone pulled out")
                }
            }
        } else {
            print("requires connection to device")
        }
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.audioRouteChangeListener(_:)),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil)
        
        AKSettings.defaultToSpeaker = true
        AKSettings.audioInputEnabled = true
        try! AKSettings.setSession(category: .playAndRecord)
        mic = AKMicrophone()
        silence = AKBooster(mic)
        silence.gain = 3
        // Do any additional setup after loading the view, typically from a nib.
        AudioKit.output = silence
        VolumeSlider.value = Float(mic.volume)
    }
    
    
    @IBAction func changeVolume(_ sender: UISlider) {
        mic.volume = Double(VolumeSlider.value)
    }
    
    @IBAction func startOrStopRecording(_ sender: Any) {
        if !didRecordStart{
            if headphones{
                AudioKit.start()
                didRecordStart = true
                PlayButton.setBackgroundImage(UIImage.init(named: "opened-lotus"), for: UIControlState.normal)
                PlayButton.setImage(UIImage.init(named: "opened-lotus"), for: UIControlState.normal)
            }
        }else{
            AudioKit.stop()
            didRecordStart = false
            PlayButton.setBackgroundImage(UIImage.init(named: "closed-lotus"), for: UIControlState.normal)
            PlayButton.setImage(UIImage.init(named: "closed-lotus"), for: UIControlState.normal)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @objc dynamic fileprivate func audioRouteChangeListener(_ notification:Notification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            print("headphone plugged in")
            headphones = true
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            print("headphone pulled out")
            headphones = false
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

