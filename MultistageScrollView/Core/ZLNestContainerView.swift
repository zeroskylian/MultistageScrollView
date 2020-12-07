//
//  ZLNestContainerView.swift
//  MultistageScrollView
//
//  Created by Xinbo Lian on 2020/12/7.
//

import UIKit


protocol ZLNestContainerViewDataSource {
    
    func zl_numberOfContentsInNestContainerView(view : ZLNestContainerView) -> Int
    
    func zl_nestContainerView(view : ZLNestContainerView, at page : Int) -> ZLNestContentProtocol
}

@objc protocol ZLNestContainerViewDelegate {
    @objc optional func zl_nestContainerView(view: ZLNestContainerView ,pageChanged :Int)
}

class ZLNestContainerView: UIView {
    
    
    public weak var delegate : ZLNestContainerViewDelegate?
    
    public var currentPage : Int = 0
    
    public func setCurrentPage(currentPage : Int)
    {
        var curPage = currentPage
        let max = numberOfContents() - 1
        if curPage > max {
            curPage = max
        }
        self.currentPage = curPage
        if collectionView.superview != nil {
            collectionView.contentOffset = CGPoint(x: bounds.size.width * CGFloat(curPage), y: 0)
            pageNumberChanged()
        }
    }
    
    public var distanceBetweenPages : CGFloat
    {
        set {
            collectionViewLayout.distanceBetweenPages = newValue
        }
        
        get {
            collectionViewLayout.distanceBetweenPages
        }
    }
    
    private let dataSource : ZLNestContainerViewDataSource
    
    private let collectionViewLayout = ZLNestContainerLayout()
    
    private var mainScrollViewArriveBottom = false
    
    private var contentsCache:Dictionary<Int , ZLNestContentProtocol> = [:]
    
    lazy var collectionView: ZLNestCollectionView = {
        let collectionView = ZLNestCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        return collectionView
    }()
    
    public required init(dataSource : ZLNestContainerViewDataSource) {
        self.dataSource = dataSource
        self.currentPage = 0
        super.init(frame: .zero)
        addSubview(collectionView)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    
    
    public func reloadData()
    {
        contentsCache.removeAll()
        collectionView.reloadData()
    }
    
    
    private func containerScrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    public func mainScrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let content = self.content(at: currentPage)
        
        let contentScrollView = content.zl_contentScrollView
        
        let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height
        
        if let cScrollView = contentScrollView, !cScrollView.zl_nestContentArriveTop
        {
            scrollView.contentOffset = CGPoint(x: 0, y: maxOffsetY);
        }
        let beforeBottom = mainScrollViewArriveBottom
        
        mainScrollViewArriveBottom = scrollView.contentOffset.y >= maxOffsetY - 0.5;
        scrollView.showsVerticalScrollIndicator = !mainScrollViewArriveBottom;
        
        if beforeBottom != mainScrollViewArriveBottom && !mainScrollViewArriveBottom{
            for value in contentsCache.values {
                if let subScrollView = value.zl_contentScrollView
                {
                    if subScrollView.zl_nestContentArriveTop { continue }
                    subScrollView.contentOffset = .zero
                }
            }
        }
    }
    
    private func contentScrollViewDidScroll(scrollView: UIScrollView ,page:Int)
    {
        scrollView.zl_nestContentArriveTop = scrollView.contentOffset.y <= 0
        if !mainScrollViewArriveBottom {
            scrollView.contentOffset = .zero
        }
        scrollView.showsVerticalScrollIndicator = !scrollView.zl_nestContentArriveTop
    }
    
    
    
    private func numberOfContents() -> Int
    {
        dataSource.zl_numberOfContentsInNestContainerView(view: self)
    }
    
    private func content(at page:Int) -> ZLNestContentProtocol
    {
        if let content = contentsCache[page] {
            return content
        }
        let ctx = dataSource.zl_nestContainerView(view: self, at: page)
        guard ctx.zl_contentScrollView != nil else {
            return ctx
        }
        contentsCache[page] = ctx
        let curPage = page
        
        if ctx.zl_contentScrollView != nil {
            ctx.zl_scrollViewDidScroll =  { [weak self] (scrollView : UIScrollView) in
                self?.contentScrollViewDidScroll(scrollView: scrollView, page: curPage)
            }
        }
        return ctx
    }
}

extension ZLNestContainerView :UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.numberOfContents()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        for view in cell.contentView.subviews  {
            view.removeFromSuperview()
        }
        let content = self.content(at: indexPath.row)
        let view = content.zl_contentView
        view.frame = cell.bounds
        cell.contentView.addSubview(view)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        for content in self.contentsCache.values {
            content.zl_contentWillAppear?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        for content in self.contentsCache.values {
            content.zl_contentDidDisappear?()
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        containerScrollViewDidScroll(scrollView: scrollView)
        let pageF = scrollView.contentOffset.x / scrollView.bounds.size.width
        
        let page = Int(pageF + 0.5)
        if page < 0 || page > numberOfContents() - 1 { return }
        
        if !scrollView.isDecelerating && !scrollView.isDragging{
            return
        }
        
        if page != currentPage {
            currentPage = page
            pageNumberChanged()
        }
    }
    
    private func pageNumberChanged()
    {
        delegate?.zl_nestContainerView?(view: self, pageChanged: currentPage)
    }
}

class ZLNestContainerLayout: UICollectionViewFlowLayout {
    
    var distanceBetweenPages : CGFloat
    
    override init() {
        distanceBetweenPages = 20
        super.init()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = .zero
        scrollDirection = .horizontal
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        itemSize = collectionView?.bounds.size ?? .zero
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttsArray:[UICollectionViewLayoutAttributes] = (super.layoutAttributesForElements(in: rect) ?? []).map { $0.copy() as! UICollectionViewLayoutAttributes}
        let halfWidth = collectionView!.bounds.size.width / 2.0
        let centerX = collectionView!.contentOffset.x + halfWidth
        for value in layoutAttsArray
        {
            value.center = CGPoint(x: value.center.x + (value.center.x - centerX) / halfWidth * distanceBetweenPages, y: value.center.y)
        }
        return layoutAttsArray
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
}
