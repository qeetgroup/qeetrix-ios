import Qeetrix
import QeetrixIconsExtended

// A core icon only: the baseline the extended icons are measured against.
let icons: [QeetrixIconName] = [.send]
for icon in icons {
    print(icon.rawValue, icon.hasDrawing(.sharp, .outline), icon.hasDrawing(.round, .filled))
}
