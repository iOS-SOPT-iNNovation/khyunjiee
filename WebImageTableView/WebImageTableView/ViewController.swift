//
//  ViewController.swift
//  WebImageTableView
//
//  Created by 김현지 on 2020/02/22.
//  Copyright © 2020 김현지. All rights reserved.
//

import UIKit

private let cellId = "SelfSizingCellId"


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 20
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SelfSizingTableCell
        cell.webImageView.tag = indexPath.row
        
        let urlStr: String = "https://placehold.it/200x200&text=SampleImg\(indexPath.row)"
        let placeholder: UIImage? = UIImage.init(named: "img1")
        
        cell.webImageView.imageFromURL(urlString: urlStr, placeholder: placeholder) {
            if cell.finishReload == false {
                cell.finishReload = true
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath.init(row: cell.webImageView.tag, section: 0)], with: UITableView.RowAnimation.automatic)
                tableView.endUpdates()
            }
        }

        cell.titleLabel?.text = "\(indexPath.row)"
        
        return cell
    }
    
}

class SelfSizingTableCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var webImageView: UIImageView!
    
    var finishReload: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension UIImageView {
    public func imageFromURL(urlString: String, placeholder: UIImage?, completion: @escaping () -> ()) {
        if self.image == nil {
            self.image = placeholder
        }
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
                self.setNeedsLayout()
                completion()
            })
        }).resume()
    }
}



