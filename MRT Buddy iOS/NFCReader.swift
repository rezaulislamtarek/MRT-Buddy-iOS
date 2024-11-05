//
//  NFCReader.swift
//  MRT Buddy iOS
//
//  Created by Rezaul Islam on 5/11/24.
//
 

import CoreNFC

class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var nfcMessage: String = "Tap an NFC tag to read data"
    
    private var session: NFCTagReaderSession?
    
    func startScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            nfcMessage = "NFC not supported on this device"
            return
        }
        
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your iPhone near an NFC tag"
        session?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No NFC tag found.")
            return
        }
        
        session.connect(to: firstTag) { [weak self] error in
            if let error = error {
                print("Error connecting to tag: \(error.localizedDescription)")
                self?.nfcMessage = "Failed to connect to tag"
                session.invalidate()
                return
            }
            
            switch firstTag {
            case .miFare(let tag):
                self?.readMiFareTag(tag, session: session)
            case .iso7816(let tag):
                self?.readISO7816Tag(tag, session: session)
            case .iso15693(let tag):
                self?.readISO15693Tag(tag, session: session)
            case .feliCa(let tag):
                self?.readFeliCaTag(tag, session: session)
            @unknown default:
                session.invalidate(errorMessage: "Unsupported NFC tag type.")
            }
        }
    }
    
    private func readMiFareTag(_ tag: NFCMiFareTag, session: NFCTagReaderSession) {
        tag.readNDEF { [weak self] (message, error) in
            self?.processNDEFMessage(message, error: error, session: session)
        }
    }
    
    private func readISO7816Tag(_ tag: NFCISO7816Tag, session: NFCTagReaderSession) {
        // Customize this read logic for ISO7816 if needed
        session.invalidate(errorMessage: "ISO7816 tags are not fully supported in this example.")
    }
    
    private func readISO15693Tag(_ tag: NFCISO15693Tag, session: NFCTagReaderSession) {
        // Customize this read logic for ISO15693 if needed
        session.invalidate(errorMessage: "ISO15693 tags are not fully supported in this example.")
    }
    
    private func readFeliCaTag(_ tag: NFCFeliCaTag, session: NFCTagReaderSession) {
        // Customize this read logic for FeliCa if needed
        session.invalidate(errorMessage: "FeliCa tags are not fully supported in this example.")
    }
    
    private func processNDEFMessage(_ message: NFCNDEFMessage?, error: Error?, session: NFCTagReaderSession) {
        if let error = error {
            print("Error reading NDEF data: \(error.localizedDescription)")
            nfcMessage = "Error reading NFC data"
        } else if let records = message?.records, !records.isEmpty {
            let payload = records.first?.payload ?? Data()
            let dataString = String(data: payload, encoding: .utf8) ?? "Unknown data"
            nfcMessage = "NFC Data: \(dataString)"
        } else {
            nfcMessage = "No NDEF message found"
        }
        session.invalidate()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC session started")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("NFC session invalidated: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.nfcMessage = "Session ended. Please try again."
        }
    }
}
