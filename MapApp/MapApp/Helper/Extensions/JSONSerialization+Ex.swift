//
//  JSONSerialization+Ex.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
extension JSONSerialization{

    //MARK:- JSONObject-
    static func JSONObject(data:Data)->Any?{
        do{
            return try self.jsonObject(with:data, options: [])
        } catch  {
            print("json object conversion error%@",error.localizedDescription)
        }
        return nil
    }
    //MARK:- JSONStringify-
    static func JSONStringify(Object: Any, prettyPrinted: Bool = false) -> String{
        let options = prettyPrinted ? self.WritingOptions.prettyPrinted : self.WritingOptions(rawValue: 0)
        let isvalid = JSONSerialization.isValidJSONObject(Object)
        guard isvalid ,let data = try? JSONSerialization.data(withJSONObject: Object, options: options), let jsonString = String(data: data, encoding:.utf8)else { return "" }
        return jsonString
    }
    //MARK:- getJsonData-
    static func JSONData(Object:Any)->Data?{
        do{
            return try self.data(withJSONObject: Object, options: [])
        } catch  {
            print("json error: \(error)")
        }
        return nil
    }
}
