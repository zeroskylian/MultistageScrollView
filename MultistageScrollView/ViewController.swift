//
//  ViewController.swift
//  MultistageScrollView
//
//  Created by Xinbo Lian on 2020/12/7.
//

import UIKit

class ViewController: UIViewController {
    
    
    lazy var tableView: ZLNestTableView = {
        let tableView = ZLNestTableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()
    
    
    lazy var containerView: ZLNestContainerView = {
        let containerView = ZLNestContainerView(dataSource: self)
        return containerView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    static func containerSize() -> CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        return CGSize(width: screenSize.width, height: screenSize.height - UIApplication.shared.statusBarFrame.size.height - 44 - 100)
    }
    
    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 4 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewContainerCell")
            if  cell == nil{
                cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewContainerCell")
                cell!.selectionStyle = .none
                cell!.contentView.addSubview(containerView)
                containerView.frame = CGRect(x: 0, y: 0, width: ViewController.containerSize().width, height: ViewController.containerSize().height)
            }
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        cell.selectionStyle = .none
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.textLabel?.text = "第 \(indexPath.row) 行"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
            return ViewController.containerSize().height
        }
        return 100
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        containerView.mainScrollViewDidScroll(scrollView)
    }
    
}

extension ViewController : ZLNestContainerViewDataSource
{
    func zl_numberOfContentsInNestContainerView(view: ZLNestContainerView) -> Int {
        4
    }
    
    func zl_nestContainerView(view: ZLNestContainerView, at page: Int) -> ZLNestContentProtocol {
        
        switch (page) {
        case 0: return NestSubView()
        case 1: return NestSubView()
        case 2: return NestSubSpaceView()
        case 3 : return NestSubController()
        default: return NestSubSpaceView()
        }
    }
}

class NestSubView : UIView,ZLNestContentProtocol,UITableViewDelegate, UITableViewDataSource
{
    var zl_contentView: UIView
    {
        self
    }
    
    var zl_contentScrollView: UIScrollView?
    {
        tableView
    }
    
    var zl_scrollViewDidScroll: ZLScrollViewDidScroll?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        27
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        cell.selectionStyle = .none
        cell.textLabel?.font = .boldSystemFont(ofSize: 14)
        cell.textLabel?.text = "第 \(indexPath.row) 行"
        cell.backgroundColor = .lightGray
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.zl_scrollViewDidScroll?(scrollView)
    }
    func zl_contentWillAppear() {
        print("NestSubView zl_contentWillAppear")
    }
    func zl_contentDidDisappear() {
        print("NestSubView zl_contentDidDisappear")
    }
    
}

class NestSubController: UIViewController,ZLNestContentProtocol ,UITableViewDelegate, UITableViewDataSource {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var zl_contentView: UIView
    {
        view
    }
    
    var zl_contentScrollView: UIScrollView?
    {
        tableView
    }
    
    var zl_scrollViewDidScroll: ZLScrollViewDidScroll?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        27
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        cell.selectionStyle = .none
        cell.textLabel?.font = .boldSystemFont(ofSize: 14)
        cell.textLabel?.text = "第 \(indexPath.row) 行"
        cell.backgroundColor = .lightGray
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.zl_scrollViewDidScroll?(scrollView)
    }
    func zl_contentWillAppear() {
        print("NestSubController zl_contentWillAppear")
    }
    func zl_contentDidDisappear() {
        print("NestSubController zl_contentDidDisappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
}

class NestSubSpaceView: UIView ,ZLNestContentProtocol{
    var zl_contentScrollView: UIScrollView?
    
    
    var zl_scrollViewDidScroll: ZLScrollViewDidScroll?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .orange
    }
    
    
    var zl_contentView: UIView
    {
        self
    }
}
