//
//  MeshViewController.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/25.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit
import SkyWay

class MeshViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var roomNameField: UITextField!
    @IBOutlet weak var localView: SKWVideo!
    
    var collectionViewController:RoomCollectionViewController?
    var meshVideoChat = MeshVideoChat()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        idLabel.text = "N/A"
        roomNameField.delegate = self
        guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
            debugPrint("Not set apikey or domain")
            return
        }
        
        meshVideoChat.delegate = self
        meshVideoChat.setLocalStreamView(localStreamView: localView)
        meshVideoChat.setup(apikey: apikey, domain: domain)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        super.viewDidDisappear(animated)
    }
    
    @IBAction private func onJoinButtonClicked(_ sender: Any) {
        if let roomName = roomNameField.text {
            meshVideoChat.joinRoom(roomName: roomName)
        }
    }
    
    @IBAction private func onLeaveButtonClicked(_ sender: Any) {
        meshVideoChat.meshRoomClose()
    }

    @IBAction private func onSwitchCameraButtonClicked(_ sender: Any) {
        meshVideoChat.switchCamera()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueName = segue.identifier else {
            return
        }
        
        if segueName == "mesh_room_collection" {
            collectionViewController = (segue.destination as? RoomCollectionViewController)!
        }
        
    }

}

extension MeshViewController:PeerDelegate {
    func peerEventOpen(peerId:String) {
        self.idLabel.text = peerId
        self.idLabel.textColor = UIColor.darkGray
    }
    func peerEventClose() {
        self.idLabel.text = "N/A"
        self.idLabel.textColor = UIColor.systemBackground
    }
    func roomEventClose() {
        self.collectionViewController?.removeAllMediaStreams()
    }
    func roomEventStream(stream:SKWMediaStream) {
        self.collectionViewController?.addMediaStream(stream: stream)
    }
    func roomEventRemoveStream(stream:SKWMediaStream) {
        self.collectionViewController?.removeMediaStream(stream: stream)
    }
    func roomEventPeerLeave(peerId: String) {
        self.collectionViewController?.removePeerStreams(peerId: peerId)
    }
}

