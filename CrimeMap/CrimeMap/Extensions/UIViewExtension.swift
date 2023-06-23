//
//  UIViewExtension.swift
//  CrimeMap
//

import UIKit

extension UIView {
    class var nib: UINib {
        return UINib(nibName: NSStringFromClass(self).components(separatedBy: ".").last!, bundle: nil)
    }
    class func initFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)![0] as! T
    }
}
