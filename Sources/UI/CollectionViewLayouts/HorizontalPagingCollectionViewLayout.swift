//
//  Created by Anton Spivak.
//  

import UIKit

public class HorizontalPagingCollectionViewLayout: UICollectionViewFlowLayout {
    
    public override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        collectionView?.decelerationRate = .fast
    }
    
    public override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        layoutAttributes?.transform = .identity.translatedBy(x: 0, y: layoutAttributes?.bounds.height ?? 0)
        return layoutAttributes
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
              let layoutAttributesForElements = super.layoutAttributesForElements(in: rect)
        else {
            return nil
        }
        
        var updatedLayoutAttributesForElements: [UICollectionViewLayoutAttributes] = []
        layoutAttributesForElements.forEach({ layoutAttributes in
            guard let updatedLayoutAttributes = layoutAttributes.copy() as? UICollectionViewLayoutAttributes
            else {
                return
            }
            
            let center = collectionView.contentOffset.x + collectionView.bounds.width / 2
            let distance = (center - updatedLayoutAttributes.center.x)
            let ratio = distance / collectionView.bounds.width
            
            let scale = max(min(cos(ratio), 1), 0.8)
            let translate = (layoutAttributes.bounds.width - layoutAttributes.bounds.width * scale) / 2
            
            var transfrom: CGAffineTransform = .identity
            transfrom = transfrom.translatedBy(x: translate * (ratio < 0 ? -1 : 1), y: 0)
            transfrom = transfrom.scaledBy(x: scale, y: scale)
            
            updatedLayoutAttributes.transform = transfrom
            updatedLayoutAttributesForElements.append(updatedLayoutAttributes)
        })
        
        return updatedLayoutAttributesForElements
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }
        
        let pageLength: CGFloat
        let approxPage: CGFloat
        let currentPage: CGFloat
        let speed: CGFloat
        
        if scrollDirection == .horizontal {
            pageLength = (self.itemSize.width + self.minimumLineSpacing)
            approxPage = collectionView.contentOffset.x / pageLength
            speed = velocity.x
        } else {
            pageLength = (self.itemSize.height + self.minimumLineSpacing)
            approxPage = collectionView.contentOffset.y / pageLength
            speed = velocity.y
        }
        
        if speed < 0 {
            currentPage = ceil(approxPage)
        } else if speed > 0 {
            currentPage = floor(approxPage)
        } else {
            currentPage = round(approxPage)
        }
        
        guard speed != 0 else {
            if scrollDirection == .horizontal {
                return CGPoint(x: currentPage * pageLength, y: 0)
            } else {
                return CGPoint(x: 0, y: currentPage * pageLength)
            }
        }
        
        var nextPage: CGFloat = currentPage + (speed > 0 ? 1 : -1)
        
        let velocityThresholdPerPage: CGFloat = 2
        let increment = speed / velocityThresholdPerPage
        nextPage += (speed < 0) ? ceil(increment) : floor(increment)
        
        if scrollDirection == .horizontal {
            return CGPoint(x: nextPage * pageLength, y: 0)
        } else {
            return CGPoint(x: 0, y: nextPage * pageLength)
        }
    }
}
