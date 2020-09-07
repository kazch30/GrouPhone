//
//  MeshVideoChat.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/26.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation
import SkyWay


class MeshVideoChat: PtoPeer {
    
    var meshRoom:SKWMeshRoom?

    func setLocalStreamView(localStreamView: SKWVideo) {
        self.localStreamView = localStreamView
    }
    
    // MARK: setup skyway
    
    override func setup(apikey:String, domain:String) {
        debugPrint("setup() for mesh ->")
        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = apikey
        option.domain = domain
        
        peer = SKWPeer(options: option)

        if let _peer = peer{
            setupPeerCallBacks(peer: _peer)
        }else{
            debugPrint("failed to create peer setup")
        }
        debugPrint("<-setup() for mesh ")
    }
    
    func joinRoom(roomName:String) {
        debugPrint("joinRoom()->")
        let option = SKWRoomOption.init()
        option.mode = SKWRoomModeEnum.ROOM_MODE_MESH
        option.stream = self.localStream
        
        meshRoom = peer?.joinRoom(withName: roomName, options: option) as? SKWMeshRoom
        if let _meshRoom = meshRoom {
            setupjoinRoomCallbacks(meshRoom:_meshRoom)
        }
        debugPrint("<-joinRoom()")
    }
    
    func switchCamera() {
        self.localStream?.switchCamera()
    }
    
    func meshRoomClose() {
        guard peer != nil && meshRoom != nil else {
            return 
        }
        meshRoom?.close()
    }

    override func setupStream(peer:SKWPeer){
        debugPrint("setupStream() for mesh ->")
        SKWNavigator.initialize(peer);
        let constraints:SKWMediaConstraints = SKWMediaConstraints()
        constraints.maxWidth = 960;
        constraints.maxHeight = 540;
        constraints.cameraPosition = SKWCameraPositionEnum.CAMERA_POSITION_FRONT;

        self.localStream = SKWNavigator.getUserMedia(constraints)
        self.localStream?.addVideoRenderer(self.localStreamView, track: 0)
        debugPrint("<-setupStream() for mesh")
    }

    
    // MARK: skyway callbacks

    override func setupPeerCallBacks(peer:SKWPeer){
        debugPrint("setupPeerCallBacks() for mesh ->")

        // MARK: PEER_EVENT_ERROR
        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR, callback:{ (obj) -> Void in
            if let error = obj as? SKWPeerError{
                debugPrint("PEER_EVENT_ERROR(call back)->")
                debugPrint("\(error)")
                debugPrint("<-PEER_EVENT_ERROR(call back)")
            }
        })
        
        // MARK: PEER_EVENT_OPEN
        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN,callback:{ (obj) -> Void in
            if let peerId = obj as? String{
                debugPrint("PEER_EVENT_OPEN(call back)->")
                DispatchQueue.main.async {
                    if let _delegate = self.delegate {
                        _delegate.peerEventOpen(peerId: peerId)
                    }
                }
                
                self.setupStream(peer: peer)
                
                debugPrint("your peerId: \(peerId)")
                debugPrint("<-PEER_EVENT_OPEN(call back)")
            }
        })
        
        // MARK: PEER_EVENT_CLOSE
        peer.on(SKWPeerEventEnum.PEER_EVENT_CLOSE, callback: { (obj) -> Void in
            debugPrint("PEER_EVENT_CLOSE(call back)->")
            SKWNavigator.terminate()
//            self.peer = nil
            DispatchQueue.main.async {
                if let _delegate = self.delegate {
                    _delegate.peerEventClose()
                }
            }

            debugPrint("<-PEER_EVENT_CLOSE(call back)")
        })
        debugPrint("<-setupPeerCallBacks() for mesh")
    }
    
    func setupjoinRoomCallbacks(meshRoom:SKWMeshRoom){
                
        // MARK: ROOM_EVENT_OPEN
        meshRoom.on(SKWRoomEventEnum.ROOM_EVENT_OPEN, callback: { (obj) -> Void in
            debugPrint("ROOM_EVENT_OPEN(call back)->")
            if let roomName = obj as? String{
                debugPrint("ROOM_EVENT_OPEN (roomName) : " + roomName)
            }
            debugPrint("<-ROOM_EVENT_OPEN(call back)")
        })
        
        // MARK: ROOM_EVENT_CLOSE
        meshRoom.on(SKWRoomEventEnum.ROOM_EVENT_CLOSE, callback: { (obj) -> Void in
            debugPrint("ROOM_EVENT_CLOSE(call back)->")
            if let roomName = obj as? String{
                debugPrint("ROOM_EVENT_CLOSE (roomName) : " + roomName)
            }
            DispatchQueue.main.async {
                if let _delegate = self.delegate {
                    _delegate.roomEventClose()
                }
            }
            self.meshRoom?.offAll()
            self.meshRoom = nil

            debugPrint("<-ROOM_EVENT_CLOSE(call back)")
        })

        // MARK: ROOM_EVENT_STREAM
        meshRoom.on(SKWRoomEventEnum.ROOM_EVENT_STREAM, callback: { (obj) -> Void in
            debugPrint("ROOM_EVENT_STREAM(call back)->")
            if let stream = obj as? SKWMediaStream {
                DispatchQueue.main.async {
                    if let _delegate = self.delegate {
                        _delegate.roomEventStream(stream: stream)
                    }
                }
            }

            debugPrint("<-ROOM_EVENT_STREAM(call back)")
        })

        // MARK: ROOM_EVENT_REMOVE_STREAM
        meshRoom.on(SKWRoomEventEnum.ROOM_EVENT_REMOVE_STREAM, callback: { (obj) -> Void in
            debugPrint("ROOM_EVENT_REMOVE_STREAM(call back)->")
            if let stream = obj as? SKWMediaStream {
                DispatchQueue.main.async {
                    if let _delegate = self.delegate {
                        _delegate.roomEventRemoveStream(stream: stream)
                    }
                }
            }

            debugPrint("<-ROOM_EVENT_REMOVE_STREAM(call back)")
        })

        // MARK: ROOM_EVENT_PEER_JOIN
        meshRoom.on(SKWRoomEventEnum.ROOM_EVENT_PEER_JOIN, callback: { (obj) -> Void in
            debugPrint("ROOM_EVENT_PEER_JOIN(call back)->")
            if let peerId = obj as? String{
                debugPrint("ROOM_EVENT_PEER_JOIN (peerId) : " + peerId)
            }

            debugPrint("<-ROOM_EVENT_PEER_JOIN(call back)")
        })

        // MARK: ROOM_EVENT_PEER_LEAVE
        meshRoom.on(SKWRoomEventEnum.ROOM_EVENT_PEER_LEAVE, callback: { (obj) -> Void in
            debugPrint("ROOM_EVENT_PEER_LEAVE(call back)->")
            if let peerId = obj as? String{
                debugPrint("ROOM_EVENT_PEER_LEAVE (peerId) : " + peerId)
                DispatchQueue.main.async {
                    if let _delegate = self.delegate {
                        _delegate.roomEventPeerLeave(peerId: peerId)
                    }
                }
            }
            debugPrint("<-ROOM_EVENT_PEER_LEAVE(call back)")
        })

    }

}
