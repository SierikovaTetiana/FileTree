//
//  UserData.swift
//  FileTree
//
//  Created by Tetiana Sierikova on 14.06.2022.
//

import Foundation

class Node {
    var itemUUID : String
    var parentItemUUID : String
    var itemType : String
    var itemName : String
    var children: [Node] = []
    weak var parent: Node?
    
    init(itemUUID: String? = nil, parentItemUUID: String? = nil, itemType: String? = nil, itemName: String? = nil, children: [Node] = []) {
        self.itemUUID = itemUUID ?? ""
        self.parentItemUUID = parentItemUUID ?? ""
        self.itemType = itemType ?? ""
        self.itemName = itemName ?? ""
        self.children = children
        
        for child in self.children {
            child.parent = self
        }
    }
    
    func add(child: Node) {
        children.append(child)
        child.parent = self
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        var text = "\(itemUUID)"
        if !children.isEmpty {
            text += " {" + children.map { $0.description }.joined(separator: ", ") + "} "
        }
        return text
    }
}
