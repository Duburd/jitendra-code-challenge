//
//  JKApollo.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import Apollo
class JKApollo: NSObject {
    
    enum ServerType:String{
        case dev = ""
        var url:URL{
            return URL(string: "\(self.rawValue)")!
        }
    }
    private(set) lazy var client = ApolloClient(url: ServerType.dev.url)
    private override init() {
        super.init()
    }
    class var shared:JKApollo{
        struct Singlton{
            static let instance  = JKApollo()
        }
        return Singlton.instance
    }
    
    
      //MARK:- POST
      func post<Mutation: GraphQLMutation>(mutation: Mutation,resultHandler: GraphQLResultHandler<Mutation.Data>? = nil){
          client.perform(mutation: mutation, resultHandler: resultHandler)
      }
    //MARK:- GET
      func get<Query: GraphQLQuery>(query: Query,resultHandler: GraphQLResultHandler<Query.Data>? = nil){
          client.fetch(query: query,cachePolicy: .fetchIgnoringCacheCompletely, resultHandler: resultHandler)
          
      }
    //MARK:- UPLOAD
      func upload<Operation: GraphQLOperation>(operation: Operation,
                                               files: [GraphQLFile],
                                               resultHandler: GraphQLResultHandler<Operation.Data>? = nil){
          client.upload(operation: operation, files: files, resultHandler: resultHandler)
      }

    
    
}
