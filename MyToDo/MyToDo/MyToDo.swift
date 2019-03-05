//
//  File.swift
//  MyToDo
//
//  Created by Chad Ingram on 2/21/19.
//  Copyright © 2019 Chad Ingram. All rights reserved.
//

import Foundation

class ToDoItem: NSObject,NSCoding
{
    var title: String
    var done: Bool
    required init?(coder aDecoder: NSCoder)
    {
        // Try to unserialize the "title" variable
        if let title = aDecoder.decodeObject(forKey: "title") as? String
        {
            self.title = title
        }
        else
        {
            //there were no objects encoded with the key title,
            // yeah, thats an error
            return nil
        }
        // Check if the key 'done' exitsts, since decodeBool() always works
        if aDecoder.containsValue(forKey: "done")
        {
            self.done = aDecoder.decodeBool(forKey: "done")
        }
        else
        {
            //there were no objects encoded with the key 'done'
            //this is an error
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        //we will store the objects in the coder object
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.done, forKey: "done")
    }
    
    public init(title: String)
    {
        self.title = title
        self.done = false
    }
}

extension ToDoItem
{
    public class func getMockData() -> [ToDoItem]
    {
        return [
            ToDoItem(title: "Milk"),
            ToDoItem(title: "Chocolate"),
            ToDoItem(title: "Lights"),
            ToDoItem(title: "Dog food")
        ]
    }
    
}

extension Collection where Iterator.Element == ToDoItem
{
    //Builds  the persistence URL. This is a location inside
    // the "Application Support" directory for the App.
    private static func persistencePath()-> URL?
    {
        let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        return url?.appendingPathComponent("todoitems.bin")
    }
    
    // We must write the array to persistence
    func writeToPersistence() throws
    {
        if let url = Self.persistencePath(), let array = self as? NSArray
        {
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            try data.write(to: url)
        }
        else
        {
            throw NSError(domain: "com.example.MyToDo", code: 10, userInfo: nil)
        }
    }
    //Read the array from persistence
    static func readFromPersistence() throws -> [ToDoItem]
    {
        if let url = persistencePath(), let data = (try Data(contentsOf: url)as Data?)
        {
            if let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ToDoItem]
            {
                return array
            }
            else
            {
                throw NSError(domain: "com.example.MyToDo", code: 11, userInfo: nil)
            }
        }
        else
        {
            throw NSError(domain: "com.example.MyToDo", code: 12, userInfo: nil)
        }
    }
}
