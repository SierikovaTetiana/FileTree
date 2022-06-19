//
//  FileTreeManager.swift
//  FileTree
//
//  Created by Tetiana Sierikova on 18.06.2022.
//

import UIKit

class FileTreeManager {
    
    private lazy var url = NSURL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(range)?key=\(key)")
    private let key = Secrets().keyAPI
    private let spreadsheetIdDefault = "1vwFQ6PxiCOiXf41QLRrzy6yNI5M9Fg63XT_4X7_uVKs"
    lazy var spreadsheetId = spreadsheetIdDefault
    private let range = "Sheet1!A1:Z1000"
    var userNode = [Node]()
    
    func requestData() {
        //About task: Data model is fetched and processed on a separate thread or dispatch_queue.
        //URLSession data tasks are always running on a background thread.
        guard let safeUrl = url else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: safeUrl as URL) {
            (data, response, error) in
            do {
                let decoder = JSONDecoder()
                guard let safeData = data else { return }
                let json = try decoder.decode(SearchData.self, from: safeData)
                //User interface are updating on the main thread
                DispatchQueue.main.async {
                    for item in json.values {
//                        if !item.isEmpty {
                            if item[1] == "" {
                                self.userNode.append(Node(itemUUID: item[0], parentItemUUID: item[1], itemType: item[2], itemName: item[3]))
                            } else {
                                for node in self.userNode {
                                    if node.itemUUID == item[1] {
                                        node.children.append(Node(itemUUID: item[0], parentItemUUID: item[1], itemType: item[2], itemName: item[3]))
                                    }
                                    node.children.sort( by: { $0.itemType < $1.itemType } )
                                }
                            }
//                        }
                    }
                    self.userNode.sort { $0.itemType < $1.itemType }
                }
            } catch {
                print("Error during JSON serialization MainVC:", error)
            }
        }
        task.resume()
    }
}
