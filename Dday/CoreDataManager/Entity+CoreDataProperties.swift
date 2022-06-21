//
//  Entity+CoreDataProperties.swift
//  Dday
//
//  Created by 한수진 on 2021/08/24.
//
//

import Foundation
import CoreData

extension Entity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var name: String?
    @NSManaged public var day: String?
    @NSManaged public var dday: Int
    @NSManaged public var idx: Int

}

extension Entity: Identifiable {

}

extension MySetting {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MySetting> {
        return NSFetchRequest<MySetting>(entityName: "MySetting")
    }

    @NSManaged public var iter: Int
    @NSManaged public var set1: Bool
    @NSManaged public var widget: Bool

}

extension MySetting: Identifiable {

}
