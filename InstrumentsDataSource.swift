//
//  InstrumentsDataSource.swift
//  SimpleSynth
//
//  Created by Matt on 2025-04-07.
//

import Foundation
import AppKit

class Instrument {
    let name: String
    let midiInst: MIDIInstrument
    let searchValue: String
    let instID: UInt32
    let index: UInt32
    
    init(name: String, instID: UInt32, index: UInt32) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.instID = instID
        self.midiInst = AudioSystem.instrumentID(toInstrument: instID)
        self.index = index
        
        self.searchValue = String(format: "%03d:%03d %@", self.midiInst.bankSelectLSB, self.midiInst.programChange, self.name).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

@objc class InstrumentsDataSource : NSObject, NSTableViewDataSource {
    let audioSystem: AudioSystem
    
    var needsRefresh: Bool = true
    var data: [Instrument] = []
    var _displayedItems: [Instrument] = []
    
    var searchText: String = ""
    
    
    @objc init(audioSystem: AudioSystem) {
        self.audioSystem = audioSystem
    }
    
    func refresh() {
        if !needsRefresh {
            return
        }
        
        needsRefresh = false
        
        data = []
        
        for i in 0 ... self.audioSystem.instrumentCount() - 1 {
            let instID = audioSystem.instrumentID(at: i)
            
            let inst = Instrument(name: audioSystem.name(ofInstrument: instID),
                                  instID: instID,
                                  index: i)
            
            data.append(inst)
        }
        
        self._displayedItems = []
        
        let tokens = self.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().components(separatedBy: " ")
        
        for item in self.data {
            if self.searchText.count != 0 {
                var found = true
                
                for token in tokens {
                    if !item.searchValue.contains(token) {
                        found = false
                        break
                    }
                }
                
                if found {
                    self._displayedItems.append(item)
                }
            } else {
                self._displayedItems.append(item)
            }
        }
    }
    
    @objc func instrumentAt(rowIndex: Int) -> UInt32 {
        let items = getDisplayedItems()
        return items[rowIndex].index
    }
    
    @objc func rowNumberFor(instrumentID: UInt32) -> Int {
        let items = getDisplayedItems()
        
        for (i, item) in items.enumerated() {
            if item.instID == instrumentID {
                return i
            }
        }
        
        return -1
    }
    
    @objc func setSearchText(_ searchText: String) {
        self.searchText = searchText
        
        setNeedsRefresh()
    }
    
    @objc func numberOfRows(in tableView: NSTableView) -> Int {
        let items = getDisplayedItems()
        return items.count
    }
    
    func getDisplayedItems() -> [Instrument] {
        refresh()
        return _displayedItems
    }
    
    @objc
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let items = getDisplayedItems()
        
        var text = ""
        switch(tableColumn!.identifier.rawValue) {
        case "program change":
            text = String(format:"%03d:%03d", items[row].midiInst.bankSelectLSB, items[row].midiInst.programChange)
        case "name":
            text = items[row].name
        default:
            break
            
        }
        
        return text
    }
    
    @objc func setNeedsRefresh() {
        needsRefresh = true
    }
}
