import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Resolved type cache")
struct TypeCacheTests {
    @Test("A cached resolution equals a fresh one, for every role, size and Bold Text setting")
    func equivalence() {
        for role in QeetrixTextRole.allCases {
            for size in [nil, CGFloat(11), CGFloat(23.5), CGFloat(53)] {
                for weight in [nil, LegibilityWeight.bold] {
                    let fresh = QeetrixResolvedType(tokens: role.tokens, size: size, legibilityWeight: weight)
                    let cached = QeetrixResolvedType.resolved(tokens: role.tokens, size: size, legibilityWeight: weight)
                    let again = QeetrixResolvedType.resolved(tokens: role.tokens, size: size, legibilityWeight: weight)
                    #expect(cached.pointSize == fresh.pointSize)
                    #expect(cached.weight == fresh.weight)
                    #expect(cached.lineSpacing == fresh.lineSpacing)
                    #expect(cached.tracking == fresh.tracking)
                    #expect(cached.usesBundledFont == fresh.usesBundledFont)
                    #expect(again.pointSize == cached.pointSize)
                }
            }
        }
    }

    @Test("Bold Text is part of the key: the regular and bold resolutions stay apart")
    func boldIsKeyed() {
        let tokens = QeetrixTextRole.body.tokens
        let regular = QeetrixResolvedType.resolved(tokens: tokens, size: 17, legibilityWeight: nil)
        let bold = QeetrixResolvedType.resolved(tokens: tokens, size: 17, legibilityWeight: .bold)
        #expect(bold.weight > regular.weight)
    }

    @Test("The cache is bounded")
    func bounded() {
        let tokens = QeetrixTextRole.caption.tokens
        for step in 0..<(QeetrixResolvedType.cacheCapacity + 40) {
            _ = QeetrixResolvedType.resolved(tokens: tokens, size: 200 + CGFloat(step) / 8, legibilityWeight: nil)
        }
        #expect(QeetrixResolvedType.cache.withLock { $0.count } <= QeetrixResolvedType.cacheCapacity)
    }
}
