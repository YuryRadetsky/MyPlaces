//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Yury Radetsky on 04.09.2020.
//  Copyright © 2020 YuryRadetsky. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
    
}
