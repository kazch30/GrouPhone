//
//  RoomCollectionViewController.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/25.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit
import SkyWay

private let reuseIdentifier = "Cell"

class RoomCollectionViewController: UICollectionViewController {

    var lock:NSLock?
    var aryMediaStreams:NSMutableArray?
    var aryVideoViews:NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        lock = NSLock()
        aryMediaStreams = NSMutableArray()
        aryVideoViews = NSMutableDictionary()
    }
    
    func addMediaStream(stream: SKWMediaStream) {
        debugPrint("addMediaStream()->")
        guard let id = stream.peerId, let label = stream.label else {
            return
        }
        let msKey = id + ":" + label
        debugPrint("msKey=" + msKey)

        lock?.lock()
        aryMediaStreams?.add(stream)
        self.collectionView.reloadData()
        lock?.unlock()
        
        debugPrint("<-addMediaStream()")
    }

    func removeMediaStream(stream: SKWMediaStream) {
        debugPrint("removeMediaStream()->")
        guard let id = stream.peerId, let label = stream.label else {
            return
        }
        let msKey = id + ":" + label
        debugPrint("msKey=" + msKey)

        lock?.lock()
        let video:SKWVideo? = aryVideoViews?.object(forKey: msKey) as? SKWVideo
        if let video = video {
            stream.removeVideoRenderer(video, track: 0)
            video.removeFromSuperview()
            aryVideoViews?.removeObject(forKey: msKey)
        }
        aryMediaStreams?.remove(stream)
        self.collectionView.reloadData()
        lock?.unlock()

        debugPrint("<-removeMediaStream()")
    }
    
    func removePeerStreams(peerId: String) {
        debugPrint("removePeerStreams()->")
        var stream:SKWMediaStream?
        
        
        lock?.lock()
        
        if let aryMediaStreams = aryMediaStreams {
            if let aryMediaStreams = aryMediaStreams as NSArray as? [SKWMediaStream] {
                for ms in aryMediaStreams {
                    if ms.peerId == peerId {
                        stream = ms
                        break
                    }
                }
            }
        }
        
        lock?.unlock()

        if let stream = stream {
            removeMediaStream(stream: stream)
        }
        
        debugPrint("<-removePeerStreams()")
    }
    
    func removeAllMediaStreams() {
        debugPrint("removeAllMediaStreams()->")
        lock?.lock()
        
        if let aryMediaStreams = self.aryMediaStreams {
            if let aryMediaStreams = aryMediaStreams as NSArray as? [SKWMediaStream] {
                for stream in aryMediaStreams {
                    guard let id = stream.peerId, let label = stream.label else {
                        continue
                    }
                    let msKey = id + ":" + label
                    debugPrint("msKey=" + msKey)
                    let video:SKWVideo? = self.aryVideoViews?.object(forKey: msKey) as? SKWVideo
                    if let video = video {
                        stream.removeVideoRenderer(video, track: 0)
                        video.removeFromSuperview()
                        self.aryVideoViews?.removeObject(forKey: msKey)
                    }

                }
                assert(self.aryVideoViews?.count == 0, "Video Views leaked.")
                self.aryMediaStreams?.removeAllObjects()
            }
        }
        
        self.collectionView.reloadData()
        lock?.unlock()
        debugPrint("<-removeAllMediaStreams()")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.aryMediaStreams?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let view:UIView? = cell.contentView.viewWithTag(1)
        if let v = view {
            if let aryMediaStreams = self.aryMediaStreams {
                if let aryMediaStreams = aryMediaStreams as NSArray as? [SKWMediaStream] {
                    let stream:SKWMediaStream = aryMediaStreams[indexPath.row]
                    guard let id = stream.peerId, let label = stream.label else {
                        return cell
                    }
                    let msKey = id + ":" + label
                    debugPrint("msKey of cell=" + msKey)
                    var video:SKWVideo? = self.aryVideoViews?.object(forKey: msKey) as? SKWVideo
                    if video == nil {
                        video = SKWVideo()
                        stream.addVideoRenderer(video!, track: 0)
                        self.aryVideoViews?.setValue(video, forKey: msKey)
                    }
                    
                    video?.frame = cell.bounds
                    v.addSubview(video!)
                    video?.setNeedsLayout()
                    
                    let lbl:UILabel? = cell.contentView.viewWithTag(2) as? UILabel
                    if let lbl = lbl {
                        lbl.text = stream.peerId
                        v.bringSubviewToFront(lbl)
                    }
                }
            }
        }
        
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
