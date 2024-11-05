//
//  ContentView.swift
//  MRT Buddy iOS
//
//  Created by Rezaul Islam on 5/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NFCReaderView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


struct NFCReaderView: View {
    @StateObject private var nfcReader = NFCReader()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(nfcReader.nfcMessage)
                .font(.title2)
                .padding()
            
            Button(action: {
                nfcReader.startScanning()
            }) {
                Text("Scan NFC Tag")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
