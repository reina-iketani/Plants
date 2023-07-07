//
//  Information.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/21.
//

import RealmSwift

class Information: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var plants = ""
    
    @Persisted var place = ""
    
    @Persisted var water = ""
    
    @Persisted var soil = ""
    
    @Persisted var sswater = ""
    
    @Persisted var awwater = ""
    
    @Persisted var fortune = ""
}


class Myplants: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var plants = ""
    
    @Persisted var name = ""
    
    @Persisted var waterLastdate = Date()
    
    @Persisted var image: String? = ""
    
    
}

class Diary: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var name = ""
    
    @Persisted var comment = ""
    
    @Persisted var image: String? = ""
    
    @Persisted var date = Date()
    
}



