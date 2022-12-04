//
//  Video.swift
//  HandTrackingApp
//
//  Created by Hiroyuki Hori on 2022/12/04.
//

import Foundation
import AVFoundation

protocol VideoUpdateDelegate{
    func update(pixelBuffer:CVPixelBuffer)
}

class Video : NSObject, AVPlayerItemOutputPullDelegate{
    var videoPlayer:AVPlayer?
    // ピクセルフォーマット(32bit BGRA)
    let playerItemVideoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA])
    
    private let queue = DispatchQueue.main
    private let advancedInterval: TimeInterval = 0.1
    private var displayLink: CADisplayLink!
    private var lastTimestamp: CFTimeInterval = 0
    private var videoInfo: CMVideoFormatDescription?
    var delegate:VideoUpdateDelegate?

    func setup(){
        guard let url = Bundle.main.url(forResource: "video", withExtension: ".MOV") else
        {
            print("error loading video")
            return;
        }
        playerItemVideoOutput.setDelegate(self, queue: queue)
        playerItemVideoOutput.requestNotificationOfMediaDataChange(withAdvanceInterval: advancedInterval)
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback(_:)))
        displayLink.preferredFramesPerSecond = 1 / 30
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default) //タイマーを開始
        
        let item = AVPlayerItem(url: url)
        item.add(playerItemVideoOutput)
        videoPlayer = AVPlayer(playerItem: item)
        videoPlayer?.play()
        

    }
    
    func outputMediaDataWillChange(_ sender: AVPlayerItemOutput) {
        print("outputMediaDataWillChange")
        displayLink.isPaused = false
    }
    
    
    /**
   setCADiplayLinkSettingに呼び出されるselector。
   */
    @objc private func displayLinkCallback(_ displayLink: CADisplayLink) {
        if (videoPlayer?.rate == 0)
        {
            videoPlayer?.currentItem?.seek(to: CMTime.zero) {
                result in
                self.videoPlayer?.play()
            }
//            videoPlayer?.play()
        }
        let nextOutputHostTime = displayLink.timestamp + displayLink.duration * CFTimeInterval(displayLink.preferredFramesPerSecond)
        let nextOutputItemTime = playerItemVideoOutput.itemTime(forHostTime: nextOutputHostTime)
        if playerItemVideoOutput.hasNewPixelBuffer(forItemTime: nextOutputItemTime) {
            lastTimestamp = displayLink.timestamp
            var presentationItemTime = CMTime.zero
            guard let pixelBuffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: nextOutputItemTime, itemTimeForDisplay: &presentationItemTime) else { return; }
            delegate?.update(pixelBuffer: pixelBuffer)
        } else {
            if displayLink.timestamp - lastTimestamp > 0.5 {
                displayLink.isPaused = true
                playerItemVideoOutput.requestNotificationOfMediaDataChange(withAdvanceInterval: advancedInterval)
            }
        }
    }
    
}
