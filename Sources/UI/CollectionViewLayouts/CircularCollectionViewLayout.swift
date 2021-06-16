//
//  Created by Anton Spivak.
//  

import UIKit

open class CircularCollectionViewCell: UICollectionViewCell{
  
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    
        guard let circularlayoutAttributes = layoutAttributes as? CircularCollectionViewLayoutAttributes
        else {
            return
        }
    
        layer.anchorPoint = circularlayoutAttributes.anchorPoint
        center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
    }
}

public class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
  // 1
  var anchorPoint = CGPoint(x: 0.5, y: 0.5)
  var angle: CGFloat = 0 {
    // 2
    didSet {
      zIndex = Int(angle * 1000000)
      transform = CGAffineTransform(rotationAngle: angle)
    }
  }
  // 3 override
    public override func copy(with zone: NSZone? = nil) -> Any {
    let copiedAttributes: CircularCollectionViewLayoutAttributes = super.copy(with: zone) as! CircularCollectionViewLayoutAttributes
    copiedAttributes.anchorPoint = self.anchorPoint
    copiedAttributes.angle = self.angle
    return copiedAttributes
  }

}

public class CircularCollectionViewLayout: UICollectionViewLayout {
    
    var itemSize: CGSize {
        let height = collectionView?.bounds.height ?? 0
        return CGSize(width: itemWidth, height: height)
    }
    
    var anglePerItem: CGFloat {
        return atan(itemSize.width / radius)
    }
    
    var angleAtExtreme: CGFloat {
        guard let collectionView = collectionView
        else {
            return 0
        }
        
        return collectionView.numberOfItems(inSection: 0) > 0 ? -CGFloat(collectionView.numberOfItems(inSection: 0) - 1) * anglePerItem : 0
    }
    
    var angle: CGFloat {
        guard let collectionView = collectionView
        else {
            return 0
        }
        
        return angleAtExtreme * collectionView.contentOffset.x / (collectionViewContentSize.width - collectionView.bounds.width)
    }
    
    public var itemWidth: CGFloat = 64 {
        didSet {
            invalidateLayout()
        }
    }
  
    public var radius: CGFloat = 1000 {
        didSet {
            invalidateLayout()
        }
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView
        else {
            return .zero
        }
        
        let width = CGFloat(collectionView.numberOfItems(inSection: 0)) * itemSize.width
        let height = collectionView.bounds.height
    
        return CGSize(width: width, height: height)
    }
    
    private var attributesList = [CircularCollectionViewLayoutAttributes]()

    class func layoutAttributesClass() -> AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }

    public override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView
        else {
            return
        }
    
        let centerX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0)
        let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
    
        let theta = atan2(collectionView.bounds.width / 2.0, radius + (itemSize.height / 2.0) - (collectionView.bounds.height / 2.0))
        
        var startIndex = 0
        var endIndex = collectionView.numberOfItems(inSection: 0) - 1
        
        if (angle < -theta) {
            startIndex = Int(floor((-theta - angle) / anglePerItem))
        }
        
        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))
        
        if (endIndex < startIndex) {
            endIndex = 0
            startIndex = 0
        }
        
        attributesList = (startIndex...endIndex).map { (i) -> CircularCollectionViewLayoutAttributes in
            let attributes = CircularCollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            attributes.size = self.itemSize
            attributes.center = CGPoint(x: centerX, y: collectionView.bounds.midY)
            attributes.angle = self.angle + (self.anglePerItem * CGFloat(i))
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
            return attributes
            
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
        
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesList[indexPath.row]
        
    }
  
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
        
    }
  
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView
        else {
            return proposedContentOffset
        }
        
        var finalContentOffset = proposedContentOffset
        let factor = -angleAtExtreme / (collectionViewContentSize.width - collectionView.bounds.width)
        let proposedAngle = proposedContentOffset.x * factor
        let ratio = proposedAngle / anglePerItem
        var multiplier: CGFloat
        
        if (velocity.x > 0) {
            multiplier = ceil(ratio)
        } else if (velocity.x < 0) {
            multiplier = floor(ratio)
        } else {
            multiplier = round(ratio)
        }
        
        finalContentOffset.x = multiplier * anglePerItem / factor
        return finalContentOffset
  }
}
