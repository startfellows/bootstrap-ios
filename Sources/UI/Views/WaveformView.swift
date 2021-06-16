//
//  Created by Anton Spivak.
//  

import UIKit

internal class WaveformItemCell: UICollectionViewCell, UICollectionViewIdentifiableCell {
    
    static var nib: UINib? { nil }
    
    let itemView: UIView = UIView()
    var multiplier: Double = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        addSubview(itemView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = bounds.height * CGFloat(multiplier)
        itemView.frame = CGRect(x: 0, y: (bounds.height - height) / 2, width: bounds.width, height: height)
        itemView.layer.cornerRadius = bounds.width / 2
        itemView.layer.cornerCurve = .continuous
    }
}

public class WaveformView: UIView {
    
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var collectionViewLayout: UICollectionViewFlowLayout { collectionView.collectionViewLayout as! UICollectionViewFlowLayout }
    
    public override var tintColor: UIColor! {
        set {
            super.tintColor = newValue
            collectionView.reloadData()
        }
        get {
            super.tintColor
        }
    }
    
    public var waveform: [Double] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var interitemSpacing: CGFloat = 4 {
        didSet {
            collectionViewLayout.minimumLineSpacing = interitemSpacing
            collectionViewLayout.invalidateLayout()
        }
    }
    
    public var itemWidth: CGFloat = 4 {
        didSet {
            collectionViewLayout.invalidateLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 0
        
        interitemSpacing = 4
        itemWidth = 4
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(WaveformItemCell.self)
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    private func wave(for indexPath: IndexPath) -> Double {
        guard indexPath.item < waveform.count - 1
        else {
            return 0.1
        }
        return waveform[indexPath.item]
    }
}

extension WaveformView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10000
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WaveformItemCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.itemView.backgroundColor = tintColor
        cell.multiplier = wave(for: indexPath)
        return cell
    }
}

extension WaveformView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: bounds.height)
    }
}

extension WaveformView: UICollectionViewDelegate {
    
}
