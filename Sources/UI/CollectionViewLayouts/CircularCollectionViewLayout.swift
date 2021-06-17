//
//  Created by Anton Spivak.
//  

import UIKit

public class CircularCollectionViewLayout: UICollectionViewFlowLayout {
    
    public override var scrollDirection: UICollectionView.ScrollDirection { set {} get { .horizontal } }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView
        else {
            return .zero
        }
        
        let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        var width: CGFloat = .zero
        
        let numberOfSections = collectionView.numberOfSections
        for i in 0..<numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: i)
            for k in 0..<numberOfItems {
                let size = delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: IndexPath(item: k, section: i)) ?? itemSize
                width += size.width
                
                if (i == 0 && k == 0) || (i == numberOfSections - 1 && k == numberOfItems - 1) {
                    width += (collectionView.bounds.width - size.width) / 2
                }
                
                if k < numberOfItems - 1 {
                    width += delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: i) ?? minimumLineSpacing
                }
            }
        }
        
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    public override func prepare() {
        super.prepare()
        super.scrollDirection = .horizontal
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
        let offset = (collectionView.bounds.width - (layoutAttributesForItem(at: IndexPath(item: 0, section: 0))?.bounds.width ?? 0)) / 2
        layoutAttributesForElements.forEach({ layoutAttributes in
            guard let updatedLayoutAttributes = layoutAttributes.copy() as? UICollectionViewLayoutAttributes
            else {
                return
            }
            
            let convertedFrame = collectionView.convert(updatedLayoutAttributes.frame, to: collectionView.superview ?? collectionView)
            
            let multiplier: CGFloat = 1.5
            let distance = convertedFrame.origin.x + convertedFrame.size.width / 4
            
            let scale = (updatedLayoutAttributes.bounds.height - abs(distance) * multiplier) / updatedLayoutAttributes.bounds.height
            var resolvedOffset = offset
            
            if distance > 0 {
                resolvedOffset -= (updatedLayoutAttributes.bounds.width - scale * updatedLayoutAttributes.bounds.width) / 2
            } else if distance < 0 {
                resolvedOffset += (updatedLayoutAttributes.bounds.width - scale * updatedLayoutAttributes.bounds.width) / 2
            }
            
            var transfrom: CGAffineTransform = .identity
            transfrom = transfrom.translatedBy(x: resolvedOffset, y: 0)
            transfrom = transfrom.scaledBy(x: scale, y: scale)
            
            updatedLayoutAttributes.transform = transfrom
            updatedLayoutAttributes.alpha = max(min(scale, 1), 0)
            updatedLayoutAttributesForElements.append(updatedLayoutAttributes)
        })
        
        return updatedLayoutAttributesForElements
    }
  
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return CGPoint(x: offsetPathFor(proposedOffset: proposedContentOffset.x, velocity: velocity), y: proposedContentOffset.y)
    }
    
    private func offsetPathFor(proposedOffset: CGFloat, velocity: CGPoint) -> CGFloat {
        guard let collectionView = collectionView
        else {
            return proposedOffset
        }
        
        let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        var offset: CGFloat = .zero
        
        let numberOfSections = collectionView.numberOfSections
        for i in 0..<numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: i)
            for k in 0..<numberOfItems {
                let width = (delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: IndexPath(item: k, section: i)).width ?? itemSize.width)
                var spacing: CGFloat = 0
                if k < numberOfItems - 1 {
                    spacing = delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: i) ?? minimumLineSpacing
                }
                
                if offset + width > proposedOffset {
                    if velocity.x > 0 || offset + width / 2 < proposedOffset {
                        return offset + width + spacing
                    }
                    return offset
                }
                
                offset += (width + spacing)
            }
        }
        
        return proposedOffset
    }
    
    public func offsetForItem(at indexPath: IndexPath) -> CGFloat {
        guard let collectionView = collectionView
        else {
            return .zero
        }
        
        let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        var offset: CGFloat = .zero
        
        for i in 0...indexPath.section {
            let numberOfItems = collectionView.numberOfItems(inSection: i)
            if indexPath.item == 0 {
                continue
            } else {
                for k in 1...indexPath.item {
                    let size = delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: IndexPath(item: k, section: i)) ?? itemSize
                    offset += size.width
                    
                    if k < numberOfItems - 1 {
                        offset += delegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: i) ?? minimumLineSpacing
                    }
                }
            }
        }
        
        return offset
    }
}
