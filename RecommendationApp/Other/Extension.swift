//
//  Extension.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 02/04/2024.
//

import Foundation

extension Encodable {
    func asDictionary() -> [ String: Any]{
        //Encode object to JSON data
        guard let data = try? JSONEncoder().encode(self) else {
            return[:]
            
        }
        
        //Serialize Json data into dictionary
        do{
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        }catch{
            return[:]
        }
    }
}
