//
//  Created by Anton Spivak.
//  

import UIKit

public enum InfinityCollectionViewLayoutBorder: Equatable {
    
    case top
    case bottom
}

public class InfinityCollectionViewLayout: UICollectionViewFlowLayout {
    
    private var pendingDeletingIndexPaths: [IndexPath] = []
    private var pendingInseringIndexPaths: [IndexPath] = []
    
    public var borders: [InfinityCollectionViewLayoutBorder] = [.top, .bottom] {
        didSet {
            invalidateLayout()
        }
    }
    
    public override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        pendingDeletingIndexPaths = []
        pendingInseringIndexPaths = []
        
        updateItems.forEach({ item in
            switch item.updateAction {
            case .delete:
                guard let indexPath = item.indexPathBeforeUpdate
                else {
                    break
                }
                
                pendingDeletingIndexPaths.append(indexPath)
            case .insert:
                guard let indexPath = item.indexPathAfterUpdate
                else {
                    break
                }
                
                pendingInseringIndexPaths.append(indexPath)
            default:
                break
            }
        })
    }
    
    public override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        pendingDeletingIndexPaths = []
        pendingInseringIndexPaths = []
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView
        else {
            return nil
        }
        
        return layoutAttributesForElements(in: rect, contentOffset: collectionView.contentOffset)
    }
    
    public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath),
              let copyLayoutAttributes = layoutAttributes.copy() as? UICollectionViewLayoutAttributes
        else {
            return nil
        }
        
        if pendingInseringIndexPaths.contains(copyLayoutAttributes.indexPath) {
            copyLayoutAttributes.alpha = 0
            copyLayoutAttributes.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -layoutAttributes.bounds.height / 2)
        
            return copyLayoutAttributes
        }
        
        return layoutAttributes
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView,
              let layoutAttributes = layoutAttributesForElements(in: collectionView.bounds, contentOffset: proposedContentOffset)
        else {
            return proposedContentOffset
        }
        
        var lastScaledLayoutAttributes: UICollectionViewLayoutAttributes? = nil
        for elementLayoutAttributes in layoutAttributes {
            if elementLayoutAttributes.transform == .identity {
                break
            }
            lastScaledLayoutAttributes = elementLayoutAttributes.copy() as? UICollectionViewLayoutAttributes
        }
        
        guard let lastScaledLayoutAttributes = lastScaledLayoutAttributes
        else {
            return proposedContentOffset
        }
        
        lastScaledLayoutAttributes.transform = .identity
        
        let matchedLastScaledContentOffsetY = (lastScaledLayoutAttributes.frame.height + minimumLineSpacing) * CGFloat(lastScaledLayoutAttributes.indexPath.item)
        let matchedNextNormalContentOffsetY = matchedLastScaledContentOffsetY + lastScaledLayoutAttributes.frame.height + minimumLineSpacing
        
        var contentOffset = proposedContentOffset
        if lastScaledLayoutAttributes.alpha < 0.2 {
            contentOffset.y = matchedNextNormalContentOffsetY
        } else {
            contentOffset.y = matchedLastScaledContentOffsetY
        }
        
        return contentOffset
    }
    
    private func layoutAttributesForElements(in rect: CGRect, contentOffset: CGPoint) -> [UICollectionViewLayoutAttributes]? {
        var updatedLayoutAtrributesArray: [UICollectionViewLayoutAttributes] = []
        let expandedRect = CGRect(x: rect.origin.x, y: rect.origin.y - 100, width: rect.size.width, height: rect.size.height + 100)
        
        guard let layoutAttributesArray = super.layoutAttributesForElements(in: expandedRect),
              let collectionView = collectionView
        else {
            return nil
        }

        layoutAttributesArray.forEach({ defaultLayoutAttributes in
            guard let layoutAttributes = defaultLayoutAttributes.copy() as? UICollectionViewLayoutAttributes
            else {
                return
            }
            
            let cellMinY = layoutAttributes.center.y - layoutAttributes.size.height / 2
            let cellMaxY = layoutAttributes.center.y + layoutAttributes.size.height / 2
            
            let cellOffsetT = cellMinY - contentOffset.y - sectionInset.top
            let cellOffsetB = contentOffset.y + collectionView.bounds.height - cellMaxY - sectionInset.bottom - sectionInset.top
        
            if cellOffsetT < 0 {
                if borders.contains(.top) {
                    let scale = min(max(1 - (abs(cellOffsetT)) / layoutAttributes.size.width, 0), 1)
                    layoutAttributes.center = CGPoint(
                        x: layoutAttributes.center.x,
                        y: layoutAttributes.center.y + abs(cellOffsetT)
                    )

                    var transform: CGAffineTransform = .identity
                    transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
                    transform = transform.concatenating(CGAffineTransform(translationX: 0, y: -(layoutAttributes.size.height - layoutAttributes.size.height * scale) / 2))

                    layoutAttributes.transform = transform
                    layoutAttributes.alpha = pow(scale, 21)
                    layoutAttributes.zIndex = -1
                }
                updatedLayoutAtrributesArray.append(layoutAttributes)
            } else if cellOffsetB < 0 {
                if borders.contains(.bottom) {
                    let scale = min(max(1 - (abs(cellOffsetB) / 2) / layoutAttributes.size.width, 0), 1)
                    layoutAttributes.center = CGPoint(
                        x: layoutAttributes.center.x,
                        y: contentOffset.y + collectionView.bounds.height - layoutAttributes.size.height / 2 - sectionInset.bottom - sectionInset.top
                    )
                    
                    var transform: CGAffineTransform = .identity.scaledBy(x: scale, y: scale)
                    transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
                    transform = transform.concatenating(CGAffineTransform(translationX: 0, y: (layoutAttributes.size.height - layoutAttributes.size.height * scale) / 2))
                    
                    layoutAttributes.transform = transform
                    layoutAttributes.alpha = pow(scale, 21)
                    layoutAttributes.zIndex = -1
                }
                updatedLayoutAtrributesArray.append(layoutAttributes)
            } else {
                layoutAttributes.zIndex = 1
                layoutAttributes.alpha = 1
                
                updatedLayoutAtrributesArray.append(layoutAttributes)
            }
        })
        
        return updatedLayoutAtrributesArray
    }
}
