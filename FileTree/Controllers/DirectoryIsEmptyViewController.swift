//
//  DirectoryIsEmptyViewController.swift
//  FileTree
//
//  Created by Tetiana Sierikova on 15.06.2022.
//

import UIKit

class DirectoryIsEmptyViewController: UIViewController {

    private let isEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Directory is Empty"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.textColor = .black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(isEmptyLabel)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style:.plain, target: self, action: #selector(tapAddFolder)), UIBarButtonItem(image:UIImage(systemName: "doc.badge.plus"), style:.plain, target: self, action: #selector(tapAddFile))]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        isEmptyLabel.frame = CGRect(x: view.frame.midX, y: view.frame.midY, width: view.frame.size.width, height: view.frame.height)
        isEmptyLabel.center = view.center
    }
    
    @objc func tapAddFolder() {
        print("Message")
    }

    @objc func tapAddFile() {
        print("Notification")
    }

}
