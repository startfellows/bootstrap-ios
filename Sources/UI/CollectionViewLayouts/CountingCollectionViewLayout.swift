//
//  Created by Anton Spivak.
//

import UIKit

public class CountingCollectionViewLayout: UICollectionViewFlowLayout {
    
    public override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
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
            
            let scale = max(min(cos(ratio * 2.5), 1), 0.3)
            let translate = (layoutAttributes.bounds.width - layoutAttributes.bounds.width * scale) / 2
            
            var transfrom: CGAffineTransform = .identity
            transfrom = transfrom.translatedBy(x: translate * (ratio < 0 ? -1 : 1), y: 0)
            transfrom = transfrom.scaledBy(x: scale, y: scale)
            
            updatedLayoutAttributes.transform = transfrom
            updatedLayoutAttributes.alpha = scale
            updatedLayoutAttributesForElements.append(updatedLayoutAttributes)
        })
        
        return updatedLayoutAttributesForElements
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }

        let halfWidth = collectionView.bounds.width * 0.5
        let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth
        
        var candidateLayoutAttributes: UICollectionViewLayoutAttributes? = nil
        layoutAttributesForElements(in: collectionView.bounds)?.forEach({ layoutAttributes in
            guard layoutAttributes.representedElementCategory == .cell
            else {
                return
            }

            if let currentCandidateLayoutAttributes = candidateLayoutAttributes {
                let a = layoutAttributes.center.x - proposedContentOffsetCenterX
                let b = currentCandidateLayoutAttributes.center.x - proposedContentOffsetCenterX

                if abs(a) < abs(b) {
                    candidateLayoutAttributes = layoutAttributes;
                }
            } else {
                candidateLayoutAttributes = layoutAttributes
            }
        })
        
        if let layoutAttributes = candidateLayoutAttributes {
            return CGPoint(x : layoutAttributes.center.x - halfWidth, y : proposedContentOffset.y);
        } else {
            return proposedContentOffset
        }
    }
}

