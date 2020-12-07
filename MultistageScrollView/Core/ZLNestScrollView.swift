//
//  ZLNestTableView.swift
//  MultistageScrollView
//
//  Created by Xinbo Lian on 2020/12/7.
//

import UIKit

class ZLNestTableView: UITableView {}

class ZLNestCollectionView: UICollectionView {}

extension ZLNestTableView : UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) , otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            if let view = otherGestureRecognizer.view, view.isKind(of: ZLNestCollectionView.self) {
                return false
            }
            return true
        }
        return false
    }
}


extension UIScrollView
{
    private struct ZLAssociatedKey {
        static var arriveTop = "ArriveTop"
    }
    var zl_nestContentArriveTop : Bool
    {
        set {
            objc_setAssociatedObject(self, &ZLAssociatedKey.arriveTop, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        
        get {
            if let value = objc_getAssociatedObject(self, &ZLAssociatedKey.arriveTop) as? Bool {
                return value
            }
            return true
        }
    }
}
