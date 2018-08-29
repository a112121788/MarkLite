//
//  MenuView.swift
//  WePost
//
//  Created by zhubch on 16/03/2017.
//  Copyright © 2017 happyiterating. All rights reserved.
//

import UIKit

private let cellHeight: CGFloat = 40

class MenuView: UIView {
    
    fileprivate var items: [String] = []
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView(frame: self.bounds, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        self.addSubview(table)
        return table
    }()
    
    var selectedChanged: ((Int) -> Void)?
    
    var dismissed: (() -> Void)?
    
    var textAlignment: NSTextAlignment
    
    init(items: [String],
         postion: CGPoint,
         textAlignment: NSTextAlignment = .left,
         selectedChanged: @escaping (Int) -> Void) {
        self.items = items
        self.textAlignment = textAlignment
        self.selectedChanged = selectedChanged
        super.init(frame: CGRect(x: postion.x, y: postion.y, width: 100, height: CGFloat(items.count) * cellHeight - 1))
        self.tableView.setBackgroundColor(.tableBackground)
        self.tableView.setSeparatorColor(.primary)
        self.cornerRadius = 1.5
    }
    
    func show(on view: UIView? = nil) {
        
        guard let superView = view ?? UIApplication.shared.keyWindow else {
            return
        }
        let control = UIControl(superView: superView, padding: 0)
        control.backgroundColor = UIColor(white: 0, alpha: 0.1)
        control.addTarget(self, action: #selector(dismiss(sender:)), for: .touchDown)
        control.addSubview(self)
        
        superView.addSubview(control)
        superView.isUserInteractionEnabled = true
        
        self.tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismiss(sender: UIControl!){
        dismissed?()
        sender.removeFromSuperview()
    }
    
}

extension MenuView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let label = UILabel(x: 10, y: 0, w: 110, h: cellHeight)
        cell.addSubview(label)
        cell.setBackgroundColor(.background)
        
        label.textAlignment = textAlignment
        label.text = items[indexPath.row]
        label.font = UIFont.font(ofSize: 15)
        label.setTextColor(.primary)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChanged?(indexPath.row)
        dismissed?()
        self.superview?.removeFromSuperview()
    }
}
