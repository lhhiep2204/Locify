//
//  DSButtonStyleVariants.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 16/7/25.
//

import SwiftUI

// MARK: - FilledButtonStyle
extension ButtonStyle where Self == DSButtonStyle {
    static var filled: DSButtonStyle {
        DSButtonStyle(type: .filled(.medium(.expanded)))
    }

    static var filledSmall: DSButtonStyle {
        DSButtonStyle(type: .filled(.small(.expanded)))
    }

    static var filledSmallFit: DSButtonStyle {
        DSButtonStyle(type: .filled(.small(.adaptive)))
    }

    static var filledLarge: DSButtonStyle {
        DSButtonStyle(type: .filled(.large(.expanded)))
    }

    static var filledLargeFit: DSButtonStyle {
        DSButtonStyle(type: .filled(.large(.adaptive)))
    }

    static var filledDestructive: DSButtonStyle {
        DSButtonStyle(type: .filled(.medium(.expanded)), primaryColor: .red)
    }

    static var filledDestructiveLargeFit: DSButtonStyle {
        DSButtonStyle(type: .filled(.large(.adaptive)), primaryColor: .red)
    }
}

// MARK: - BorderedButtonStyle
extension ButtonStyle where Self == DSButtonStyle {
    static var bordered: DSButtonStyle {
        DSButtonStyle(type: .bordered(.medium(.expanded)))
    }

    static var borderedFit: DSButtonStyle {
        DSButtonStyle(type: .bordered(.medium(.adaptive)))
    }

    static var borderedSmall: DSButtonStyle {
        DSButtonStyle(type: .bordered(.small(.expanded)))
    }

    static var borderedSmallFit: DSButtonStyle {
        DSButtonStyle(type: .bordered(.small(.adaptive)))
    }

    static var borderedLarge: DSButtonStyle {
        DSButtonStyle(type: .bordered(.large(.expanded)))
    }

    static var borderedLargeFit: DSButtonStyle {
        DSButtonStyle(type: .bordered(.large(.adaptive)))
    }

    static var borderedDestructive: DSButtonStyle {
        DSButtonStyle(type: .bordered(.medium(.expanded)), primaryColor: .red)
    }

    static var borderedDestructiveFit: DSButtonStyle {
        DSButtonStyle(type: .bordered(.medium(.adaptive)), primaryColor: .red)
    }
}

// MARK: - IconButtonStyle
extension ButtonStyle where Self == DSButtonStyle {
    static var borderedCircularIcon: DSButtonStyle {
        DSButtonStyle(type: .icon(.circular(.bordered(.small(.expanded)))))
    }

    static var filledCircularIcon: DSButtonStyle {
        DSButtonStyle(type: .icon(.circular(.filled(.small(.expanded)))))
    }

    static var filledIcon: DSButtonStyle {
        DSButtonStyle(type: .icon(.normal(.filled(.medium(.expanded)))))
    }

    static var borderedIcon: DSButtonStyle {
        DSButtonStyle(type: .icon(.normal(.bordered(.medium(.expanded)))))
    }

    static var borderedDestructiveIcon: DSButtonStyle {
        DSButtonStyle(type: .icon(.normal(.bordered(.medium(.expanded)))), primaryColor: .red)
    }
}
