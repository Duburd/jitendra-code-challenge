//
//  JKSocket.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import SocketIO
class JKSocket: NSObject {
    
    //MARK:- Define in below Your socket event key
    enum EventType:String {
        case trackUserLocation
        case updateLocation
        
    }
    var socketURL:URL?{
       return URL(string: "http://locationsocket.mobilytedev.com/")
    }
    fileprivate var socket:SocketIOClient!
    fileprivate  lazy var manager:SocketManager = {
        return SocketManager(socketURL:  socketURL!, config: [.log(false),.compress])
        //SocketManager(socketURL:  URL(string:url)!, config: [.log(true), .forceWebsockets(true), .compress])
    }()
    private override init() {
        super.init()
        socket =  manager.defaultSocket
    }
    class var shared:JKSocket{
        struct Singlton{
            static let instance  = JKSocket()
        }
        return Singlton.instance
    }
    
    var status:SocketIOStatus{
        return socket.status
    }
    //MARK:- establishConnection
    func establishConnection(completion:(()->Void)? = nil){
        if status == .notConnected  {
            socket.once(clientEvent: .connect) { (data, ack) in
                print("socket connected",data)
                completion?()
            }
            socket.connect()
        }else {
            reConnection(completion: completion)
            
        }
        
        
    }
    //MARK:- closeConnection
    func closeConnection(completion:(()->Void)? = nil){
        if status == .connected {
            socket.on(clientEvent: .disconnect) { (data, ack) in
                print("socket disconnect",data)
                completion?()
            }
            socket.disconnect()
        }
        
    }
    //MARK:- reConnection
    func reConnection(completion:(()->Void)? = nil){
        if status == .disconnected {
            socket.on(clientEvent: .reconnect) { (data, ack) in
                print("socket starting reconnect **** ",data)
                completion?()
            }
            socket.connect()
        }
    }
    
}
extension JKSocket{
    //MARK:- POST
    
    func post<T:SocketData>(_ event:EventType , _ item:T...,completion:(()->Void)? = nil){
        print("\(event.rawValue) = \(item[0])")
        socket.emit(event.rawValue, item, completion: completion)
    }
    //MARK:- GET
    func get(_ event:EventType,completion:@escaping(_ dataArray:[Any])->Void){
        socket.on(event.rawValue) { (dataArray, ack) in
            print("\(event.rawValue) = \(dataArray[0])")
            completion(dataArray)
        }
    }
    //MARK:- sendJSON
    func sendJSON<T:Mappable>(_ event:EventType , data:T,completion:(()->Void)? = nil){
        if let object = data.jsonObject {
            self.post(event, object,completion: completion)
        }
    }
    //MARK:- sendObject
    func sendObject(_ event:EventType , param:[String:Any],completion:(()->Void)? = nil){
        post(event, param, completion: completion)
    }
    
    //MARK:- recieveJSON
    func recieveJSON<T:Mappable>(_ event:EventType ,completion:@escaping(Result<T,Error>)->Void){
        self.get(event) { (dataArray) in
            if let data = JSONSerialization.JSONData(Object: dataArray[0]){
                let result  = data.JKDecoder(T.self)
                completion(result)
            }
        }
    }
    //MARK:- recieveObject
    func recieveObject(_ event:EventType,completion:@escaping (_ data:Any) -> Void){
        self.get(event) { (dataArray) in
            completion(dataArray[0])
        }
        
        
    }
    //MARK:- reset
    func reset(_ event:EventType){
        socket.off(event.rawValue)
    }
}
