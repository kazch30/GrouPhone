//
//  PtoPeer.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/24.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation
import SkyWay

protocol PeerDelegate {
    func changeConnectionStatus(connected:Bool)
    func mediaConnectionEventStream(streamPeerId:String?)
    func peerEventOpen(peerId:String)
    func peerEventClose()
    func roomEventClose()
    func roomEventStream(stream:SKWMediaStream)
    func roomEventRemoveStream(stream:SKWMediaStream)
    func roomEventPeerLeave(peerId: String)
}

extension PeerDelegate {
    func changeConnectionStatus(connected:Bool) {
        debugPrint("changeConnectionStatus() default call")
    }
    func mediaConnectionEventStream(streamPeerId:String?) {
        debugPrint("mediaConnectionEventStream() default call")
    }
    func peerEventOpen(peerId:String) {
        debugPrint("peerEventOpen() default call")
    }
    func peerEventClose() {
        debugPrint("peerEventOpen() default call")
    }
    func roomEventClose() {
        debugPrint("roomEventClose() default call")
    }
    func roomEventStream(stream:SKWMediaStream) {
        debugPrint("roomEventStream() default call")
    }
    func roomEventRemoveStream(stream:SKWMediaStream) {
        debugPrint("roomEventStream() default call")
    }
    func roomEventPeerLeave(peerId: String) {
        debugPrint("roomEventPeerLeave() default call")
    }
}


class PtoPeer {
    
    var peer: SKWPeer?
    var mediaConnection: SKWMediaConnection?
    var localStream: SKWMediaStream?
    var remoteStream: SKWMediaStream?

    weak var localStreamView: SKWVideo!
    weak var remoteStreamView: SKWVideo!
    var delegate: PeerDelegate?

    var Peer:SKWPeer? {
        get {
            return peer
        }
    }
    
    func setStreamView(localStreamView: SKWVideo, remoteStreamView: SKWVideo) {
        self.localStreamView = localStreamView
        self.remoteStreamView = remoteStreamView
    }
    
    // MARK: setup skyway
    
    func setup(apikey:String, domain:String) {
        debugPrint("setup()->")
        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = apikey
        option.domain = domain
        
        peer = SKWPeer(options: option)

        if let _peer = peer{
            setupPeerCallBacks(peer: _peer)
            setupStream(peer: _peer)
        }else{
            debugPrint("failed to create peer setup")
        }
        debugPrint("<-setup()")
    }
    
    func call(targetPeerId:String){
        debugPrint("call() ->")
        let option = SKWCallOption()
        
        if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
            self.mediaConnection = mediaConnection
            self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
        }else{
            print("failed to call :\(targetPeerId)")
        }
        debugPrint("<-call()")
    }
    
    func close() {
        debugPrint("close()->")
        self.mediaConnection?.close()
        debugPrint("<-close()")
    }
    
    func destroy() {
        debugPrint("destroy()->")
        self.peer?.destroy()
        debugPrint("<-destroy()")
    }

    func setupStream(peer:SKWPeer){
        debugPrint("setupStream() ->")
        SKWNavigator.initialize(peer);
        let constraints:SKWMediaConstraints = SKWMediaConstraints()
        self.localStream = SKWNavigator.getUserMedia(constraints)
        self.localStream?.addVideoRenderer(self.localStreamView, track: 0)
        debugPrint("<-setupStream()")
    }
    
    // MARK: skyway callbacks

    func setupPeerCallBacks(peer:SKWPeer){
        
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
                debugPrint("your peerId: \(peerId)")
                debugPrint("<-PEER_EVENT_OPEN(call back)")
            }
        })
        
        // MARK: PEER_EVENT_CALL
        peer.on(SKWPeerEventEnum.PEER_EVENT_CALL, callback: { (obj) -> Void in
            if let connection = obj as? SKWMediaConnection{
                debugPrint("PEER_EVENT_CALL(call back)->")
                self.setupMediaConnectionCallbacks(mediaConnection: connection)
                self.mediaConnection = connection
                connection.answer(self.localStream)
                debugPrint("<-PEER_EVENT_CALL(call back)")
            }
        })
    }

    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){
        
        // MARK: MEDIACONNECTION_EVENT_STREAM
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in
            if let msStream = obj as? SKWMediaStream{
                self.remoteStream = msStream
                debugPrint("MEDIACONNECTION_EVENT_STREAM(call back)->")
                DispatchQueue.main.async {
                    if let _delegate = self.delegate {

                        _delegate.mediaConnectionEventStream(streamPeerId:self.remoteStream?.peerId)
                    }

                    self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
                }
                if let _delegate = self.delegate {
                    _delegate.changeConnectionStatus(connected: true)
                }
                debugPrint("<-MEDIACONNECTION_EVENT_STREAM(call back)")
            }
        })
        
        // MARK: MEDIACONNECTION_EVENT_CLOSE
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            if let _ = obj as? SKWMediaConnection{
                debugPrint("MEDIACONNECTION_EVENT_CLOSE(call back)->")
                DispatchQueue.main.async {
                    self.remoteStream?.removeVideoRenderer(self.remoteStreamView, track: 0)
                    self.remoteStream = nil
                    self.mediaConnection = nil
                }
                if let _delegate = self.delegate {
                    _delegate.changeConnectionStatus(connected: false)
                }

                debugPrint("<-MEDIACONNECTION_EVENT_CLOSE(call back)")
            }
        })
    }
}
