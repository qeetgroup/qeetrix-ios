import Qeetrix
import QeetrixIconsExtended

// The baseline's core icon and twenty extended ones; Scripts/icon-budget.sh lists the same twenty.
let icons: [QeetrixIconName] = [
    .send,
    .alarmClock, .anchor, .award, .backpack, .bike, .binoculars, .bird, .bookOpen, .brain, .bus,
    .cake, .car, .cat, .compass, .dog, .flame, .gift, .globeLock, .heart, .sun,
]
for icon in icons {
    print(icon.rawValue, icon.hasDrawing(.sharp, .outline), icon.hasDrawing(.round, .filled))
}
