//
//  Created by Anton Spivak.
//

import Foundation
import AVFoundation

public struct Effect {
    
    public var identifier: String
    public var units: [AVAudioUnit]
    
    public init(_ identifier: String, _ units: [AVAudioUnit]) {
        self.identifier = identifier
        self.units = units
    }
}
