//
//  CAPSPageMenuConfiguration.swift
//  PageMenuConfigurationDemo
import UIKit

public class CAPSPageMenuConfiguration {
    open var menuHeight : CGFloat = 34.0
    open var menuMargin : CGFloat = 15.0
    open var menuItemWidth : CGFloat = 111.0
    open var selectionIndicatorHeight : CGFloat = 3.0
    open var scrollAnimationDurationOnMenuItemTap : Int = 500 // Millisecons
    open var selectionIndicatorColor : UIColor = UIColor.clear
    open var selectedMenuItemLabelColor : UIColor = UIColor.clear
    open var unselectedMenuItemLabelColor : UIColor = UIColor.clear
    open var scrollMenuBackgroundColor : UIColor = UIColor.clear
    open var viewBackgroundColor : UIColor = UIColor.clear
    open var bottomMenuHairlineColor : UIColor = UIColor.clear
    open var menuItemSeparatorColor : UIColor = UIColor.clear
    
    open var menuItemFont : UIFont = UIFont.systemFont(ofSize: 15.0)
    open var menuItemSeparatorPercentageHeight : CGFloat = 0.2
    open var menuItemSeparatorWidth : CGFloat = 0.5
    open var menuItemSeparatorRoundEdges : Bool = false
    
    open var addBottomMenuHairline : Bool = true
    open var menuItemWidthBasedOnTitleTextWidth : Bool = false
    open var titleTextSizeBasedOnMenuItemWidth : Bool = false
    open var useMenuLikeSegmentedControl : Bool = false
    open var centerMenuItems : Bool = true
    open var enableHorizontalBounce : Bool = true
    open var hideTopMenuBar : Bool = false
    
    public init() {
        
    }
}
