//
//  NestContentProtocol.swift
//  MultistageScrollView
//
//  Created by Xinbo Lian on 2020/12/7.
//

import UIKit

@objc protocol ZLNestContentProtocol {
    
    typealias ZLScrollViewDidScroll = (UIScrollView) -> Void
    var zl_contentView : UIView { get }
    
    var zl_contentScrollView : UIScrollView? { get }
    
    var zl_scrollViewDidScroll :ZLScrollViewDidScroll?  { set  get }
    
    @objc optional func zl_contentWillAppear()
    
    @objc optional func zl_contentDidDisappear()
}
//
//extension ZLNestContentProtocol
//{
//    func zl_contentWillAppear(){}
//    
//    func zl_contentDidDisappear(){}
//    
//}
