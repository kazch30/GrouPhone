//
//  MediaConnectionViewController.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/24.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit
import SkyWay

class MediaConnectionViewController: UIViewController {

//    fileprivate var peer: SKWPeer?
//    fileprivate var mediaConnection: SKWMediaConnection?
//    fileprivate var localStream: SKWMediaStream?
//    fileprivate var remoteStream: SKWMediaStream?
    
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBOutlet weak var remoteStreamView: SKWVideo!
    @IBOutlet weak var myPeerIdLabel: UILabel!
    @IBOutlet weak var targetPeerIdLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    
    let peerToPeer = PtoPeer()

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("viewDidLoad()->")
        //self.setup()
        guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
            debugPrint("Not set apikey or domain")
            return
        }
        peerToPeer.delegate = self
        peerToPeer.setStreamView(localStreamView:self.localStreamView, remoteStreamView:self.remoteStreamView)
        peerToPeer.setup(apikey: apikey, domain: domain)
        debugPrint("<-viewDidLoad()")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.peerToPeer.close()
        self.peerToPeer.destroy()
//        self.mediaConnection?.close()
//        self.peer?.destroy()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapCall(){
        guard let peer = self.peerToPeer.Peer else{
            return
        }
        
        Util.callPeerIDSelectDialog(peer: peer, myPeerId: peer.identity) { (peerId) in
            self.peerToPeer.call(targetPeerId: peerId)
        }
    }

    @IBAction func tapEndCall(){
        self.peerToPeer.close()
//        self.mediaConnection?.close()
        self.changeConnectionStatus(connected: false)
    }

}

extension MediaConnectionViewController:PeerDelegate {
    
    func changeConnectionStatus(connected:Bool){
        if connected {
            self.callButton.isEnabled = false
            self.endCallButton.isEnabled = true
        }else{
            self.callButton.isEnabled = true
            self.endCallButton.isEnabled = false
        }
    }

    func mediaConnectionEventStream(streamPeerId:String?) {
        if let _streamPeerId = streamPeerId {
            self.targetPeerIdLabel.text = _streamPeerId
        }
        self.targetPeerIdLabel.textColor = UIColor.darkGray

    }
    
    func peerEventOpen(peerId:String) {
        self.myPeerIdLabel.text = peerId
        self.myPeerIdLabel.textColor = UIColor.darkGray
    }
    
}
