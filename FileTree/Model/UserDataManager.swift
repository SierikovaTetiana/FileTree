//
//  UserDataManager.swift
//  FileTree
//
//  Created by Tetiana Sierikova on 18.06.2022.
//

import UIKit
import MobileCoreServices
import GoogleSignIn
import GoogleAPIClientForREST
import Security

protocol UserDataManagerDelegate {
    func didGetData(_ dataManager: UserDataManager, data: [Node])
    func didUpdateData(_ dataManager: UserDataManager, data: Node)
    func didFailWithError(error: Error)
}

class UserDataManager {
    
    var delegate: UserDataManagerDelegate?
    static let userInstance = UserDataManager()
    private let service = GTLRSheetsService()
    private let key = Secrets().keyAPI
    private let range = "Sheet1!A1:Z1000"
    private var userNode = [Node]()
    private var testNode = [Node]()
    
    // MARK: - Handle get data from Google Spreadsheets using API key(unautorize request only for reading public data)
    
    func getPublicDataRequest(collectView: UICollectionView, sheetID: String) {
        let url = NSURL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(sheetID)/values/\(range)?key=\(key)")
        if let safeUrl = url {
            let session = URLSession(configuration: .default)
            let task =  session.dataTask(with: safeUrl as URL) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let userData = self.parseJSON(safeData) {
                        self.delegate?.didGetData(self, data: userData)
                    }
                }
            }
            task.resume()
        } else {
            self.delegate?.didFailWithError(error: "Please, enter correct SheetID" as! Error)
        }
    }
    
    private func parseJSON(_ userData: Data) -> [Node]? {
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode(SearchData.self , from: userData)
            for item in json.values {
                testNode.append(Node(itemUUID: item[0], parentItemUUID: item[1], itemType: item[2], itemName: item[3]))
            }
            for item in testNode {
                if item.parentItemUUID == "" {
                    userNode.append(item)
                }
            }
            testNode.removeAll(where: { $0.parentItemUUID == "" })
            while testNode.count != 0 {
                addDataToUserNode(children: userNode, testNode: testNode)
            }
            userNode.sort { $0.itemType < $1.itemType }
            return userNode
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    private func addDataToUserNode(children: [Node], testNode: [Node]) {
        for node in testNode {
            for child in children {
                if (node.parentItemUUID == child.itemUUID) &&
                    !(child.children.contains(where: { $0.itemUUID ==  node.itemUUID})) {
                    child.add(child: node)
                    self.testNode.removeAll(where: { $0.parentItemUUID == child.itemUUID })
                    child.children.sort( by: { $0.itemType < $1.itemType } )
                    addDataToUserNode(children: child.children, testNode: testNode)
                }
            }
        }
    }
    
    // MARK: - Handle add data to Google Spreadsheets using OAuth 2.0 (autorize request) - sign-in Google acc
    
    func updateDataRequest(node: Node, collectView: UICollectionView, sheetID: String) {
        GIDSignIn.sharedInstance.currentUser?.authentication.do { authentication, error in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            if let authentication = authentication {
                self.service.authorizer = authentication.fetcherAuthorizer()
                self.updateSheets(node: node, collectView: collectView, sheetID: sheetID)
            } else {
                self.delegate?.didFailWithError(error: "Can't authenticate user" as! Error)
            }
        }
    }
    
    private func updateSheets(node: Node, collectView: UICollectionView, sheetID: String) {
        let valueRange = GTLRSheets_ValueRange()
        valueRange.majorDimension = "ROWS"
        valueRange.range = range
        valueRange.values = [["\(node.itemUUID)", "\(node.parentItemUUID)", "\(node.itemType)", "\(node.itemName)"]]
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: sheetID, range: range)
        query.valueInputOption = "USER_ENTERED"
        service.executeQuery(query) { ticket, object, error in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
            } else {
                self.delegate?.didUpdateData(self, data: node)
            }
        }
    }
}
