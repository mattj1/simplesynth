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
    
    init(name: String, midiInst: MIDIInstrument) {
        self.name = name
        self.midiInst = midiInst
    }
}

@objc class InstrumentsDataSource : NSObject, NSTableViewDataSource {
    let audioSystem: AudioSystem
    
    var needsRefresh: Bool = true
    var data: [Instrument] = []
    
    
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
                                  midiInst: AudioSystem.instrumentID(toInstrument: instID))
            
            data.append(inst)
        }
    }
    
    @objc func numberOfRows(in tableView: NSTableView) -> Int {
        self.refresh()
        return data.count
    }
    
    @objc
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        self.refresh()
        
        var text = ""
        switch(tableColumn!.identifier.rawValue) {
        case "program change":
            text = String(format:"%03d:%03d", data[row].midiInst.bankSelectLSB, data[row].midiInst.programChange)
        case "name":
            text = data[row].name
        default:
            break
            
        }
        
        return text
    }
    
    @objc func setNeedsRefresh() {
        needsRefresh = true
    }
}
