//
//  Task.swift
//  taskapp
//
//  Created by 由上博之 on 2021/05/25.
//

import RealmSwift

class Task: Object{
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var contents = ""
    @objc dynamic var category = ""
    @objc dynamic var date = Date()
    override static func primaryKey() -> String? {
        return "id"
    }
}
