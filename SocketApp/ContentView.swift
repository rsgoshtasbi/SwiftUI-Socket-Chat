//
//  ContentView.swift
//  SocketApp
//
//  Created by Rashid Goshtasbi on 2/10/22.
//

import SwiftUI
import SocketIO
import zlib

final class Service: ObservableObject {
    private var manager = SocketManager(socketURL: URL(string: "ws://localhost:3000")!, config: [])
    
    //.log(true), .compress
    
    @Published var messages = [String]()
        
    init() {
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { (data, ack) in
            print("connected")
            socket.emit("NodeJS Server Port", "Hi Node.JS server!")
        }
        
        socket.on("iOS Client Port") { [weak self] data, ack in
            if let data = data[0] as?  [String: String],
               let rawMessage = data["msg"] {
                DispatchQueue.main.async {
                    self?.messages.append(rawMessage)
                    print(rawMessage)
                }
            }            
            socket.emitWithAck("NodeJS Server Port", data)
        }
        
        socket.connect()
    }
}

struct ContentView: View {

    @ObservedObject var service = Service()
    
    init() {
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
    }

    var body: some View {
//        ZStack {
//            List(service.messages.reversed(), id: \.self) { msg in
//                HStack {
//                    Text(msg).scaleEffect(x: 1, y: -1, anchor: .center)
//                }
//            }.scaleEffect(x: 1, y: -1, anchor: .center)
//        }
        
        ScrollView {
            VStack(spacing: 20) {
                ForEach(service.messages.reversed(), id: \.self) { msg in
                    HStack {
                        Text("Item \(msg)")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .scaleEffect(x: 1, y: -1, anchor: .center)
                    }
                }
            }
        }.scaleEffect(x: 1, y: -1, anchor: .center)
//        .frame(height: 350)

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
