//
//  Mappable.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
// MARK: - JSON: Codable
typealias Mappable = Codable

extension Encodable{
    func JKEncoder() -> Result<Data,Error> {
        return JSNParser.encoder(self)
    }
    var jsonObject:[String:Any]?{
        let result  = JKEncoder()
        switch result {
        case .success(let data):return data.object
        default: return nil
        }
        
        
    }
    var jsonObjects:[[String:Any]]?{
        let result  = JKEncoder()
        switch result {
        case .success(let data):return data.objects as? [[String : Any]]
        default: return nil
            
        }
        
    }
    var jsonString:String?{
        let result  = JKEncoder()
        switch result {
        case .success(let data):return data.utf8String
            
        default: return nil
            
        }
        
        
    }
    var data:Data?{
        let result  = JKEncoder()
        switch result {
        case .success(let data):return data
        default: return nil
            
        }
    }
    
}

extension Data{
    
    func JKDecoder<T>(_ type:T.Type)->Result<T,Error> where T:Decodable{
        return JSNParser.decoder(T.self, from: self)
    }
    var utf8String:String?{
        return String(bytes: self, encoding: .utf8)
    }
    var object:[String: Any]? {
        return JSONSerialization.JSONObject(data: self) as? [String : Any]
        
    }
    var objects:[Any]? {
        guard let listObject = JSONSerialization.JSONObject(data: self) as? [Any] else{return nil}
        return listObject
        
    }
}

private struct JSNParser:Equatable{
    
    static func decoder<T>(_ type:T.Type,from data:Data)->Result<T,Error> where T:Decodable{
        do{
            let decoder  = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let obj  = try decoder.decode(T.self, from: data)
            
            return (.success(obj))
        }catch {
            return (.failure(error))
        }
    }
    static func encoder<T>(_ value: T)->Result<Data,Error> where T : Encodable{
        do{
            let encoder =  JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encodeData  = try encoder.encode(value)
            return(.success(encodeData))
            
        }catch{
            return (.failure(error))
        }
    }
}
