//
//  String+.swift
//  Going-iOS
//
//  Created by 곽성준 on 1/10/24.
//

import Foundation

extension String {
    // 글자가 자음인지 체크
    var isConsonant: Bool {
        guard let scalar = UnicodeScalar(self)?.value else {
            return false
        }
        
        let consonantScalarRange: ClosedRange<UInt32> = 12593...12622
        
        return consonantScalarRange ~= scalar
    }

    func containsEmoji() -> Bool {
        for scalar in unicodeScalars {
            if scalar.properties.isEmoji {
                return true
            }
        }
        return false
    }
    
    func getEmojiCount() -> Int {
        var count = 0
        
        for scalar in unicodeScalars {
            if scalar.properties.isEmoji {
                count += 1
            }
        }
        return count
    }
}
