//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

//import CoreFoundation

class WatchTimer {

    let startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?

    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()

        return duration!
    }

    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        
        let timer = WatchTimer()
        
        self.context.perform {
            
            let identifiers = entries.compactMap { $0.identifier }
            let array = self.entriesFromPersistentStore(with: identifiers, in: self.context)
            
            for entryRep in entries {
                
            }
            
            for entryRep in entries {
                guard let identifier = entryRep.identifier else { continue }
                
                let entry = self.fetchSingleEntryFromPersistentStore(with: identifier, in: self.context)
                if let entry = entry, entry != entryRep {
                    self.update(entry: entry, with: entryRep)
                } else if entry == nil {
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
            print("The task took \(timer.stop()) seconds.")
            completion(nil)
        }
    }
    
    /*
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        
        let timer = WatchTimer()
        
        self.context.perform {
            
            let identifiers = entries.compactMap { $0.identifier }
            let array = self.entriesFromPersistentStore(with: identifiers, in: self.context)
            
            for entryRep in entries {
                
            }
            
            for entryRep in entries {
                guard let identifier = entryRep.identifier else { continue }
                
                let entry = self.fetchSingleEntryFromPersistentStore(with: identifier, in: self.context)
                if let entry = entry, entry != entryRep {
                    self.update(entry: entry, with: entryRep)
                } else if entry == nil {
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
            print("The task took \(timer.stop()) seconds.")
            completion(nil)
        }
    }
 */
 
    /*
    private func fetchAll() -> [Entry]{
        
    }
    */
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    
    private func entriesFromPersistentStore(with identifiers: [String], in context: NSManagedObjectContext) -> [Entry] {
        
   //     guard let identifiers = identifiers else { return nil }
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        
        var result: [Entry] = []
        do {
            result = try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }
    
    private func fetchSingleEntryFromPersistentStore(with identifier: String?, in context: NSManagedObjectContext) -> Entry? {
        
        guard let identifier = identifier else { return nil }
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Entry? = nil
        do {
            result = try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }
    
    let context: NSManagedObjectContext
}
