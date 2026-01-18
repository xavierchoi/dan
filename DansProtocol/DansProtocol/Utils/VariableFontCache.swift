import UIKit
import CoreText

/// Variable Font 캐시 시스템
///
/// 애니메이션 중 매 프레임마다 새로운 UIFont 객체를 생성하는 것을 방지하여
/// 힙 메모리 할당과 GC 부하를 대폭 감소시킵니다.
///
/// - 스레드 안전 (NSLock 사용)
/// - Weight 5단위 반올림으로 캐시 효율성 최적화 (400-900 범위에서 최대 100개)
/// - 앱 전체에서 싱글톤으로 공유
///
/// Usage:
/// ```swift
/// guard let uiFont = VariableFontCache.shared.font(
///     family: "Playfair Display",
///     size: 28,
///     weight: 523.7
/// ) else {
///     // fallback handling
/// }
/// ```
final class VariableFontCache {
    static let shared = VariableFontCache()

    private var cache: [String: UIFont] = [:]
    private let lock = NSLock()

    /// Variable font weight axis identifier (FourCC for 'wght')
    /// CRITICAL: iOS ignores string key "wght", must use numeric axis tag
    /// 'wght' = 0x77('w') 0x67('g') 0x68('h') 0x74('t') = 0x77676874 = 2003265652
    private static let weightAxisTag: Int = 0x77676874

    private init() {}

    /// 캐시에서 폰트를 가져오거나 새로 생성
    ///
    /// Weight 값은 5단위로 반올림되어 캐시 키로 사용됩니다.
    /// 예: 523.7 → 525, 518.2 → 520
    ///
    /// - Parameters:
    ///   - family: 폰트 패밀리 이름 (e.g., "Playfair Display", "Noto Serif KR")
    ///   - size: 폰트 크기 (points)
    ///   - weight: 폰트 weight (400-900, 연속값 허용)
    ///   - italic: 이탤릭체 적용 여부 (synthesized oblique)
    /// - Returns: 캐시된 또는 새로 생성된 UIFont, 실패 시 nil
    func font(family: String, size: CGFloat, weight: CGFloat, italic: Bool = false) -> UIFont? {
        // Weight를 5단위로 반올림하여 캐시 키 최소화
        // 400-900 범위에서 최대 100개의 고유 weight 값만 캐시됨
        let roundedWeight = (weight / 5).rounded() * 5
        let italicSuffix = italic ? "-italic" : ""
        let key = "\(family)-\(size)-\(roundedWeight)\(italicSuffix)"

        lock.lock()
        defer { lock.unlock() }

        if let cached = cache[key] {
            return cached
        }

        guard let font = createVariableFont(family: family, size: size, weight: roundedWeight, italic: italic) else {
            return nil
        }

        cache[key] = font
        return font
    }

    /// 캐시 통계 정보 (디버깅용)
    var cacheCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }

    /// 캐시 전체 초기화 (메모리 경고 시 호출)
    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
    }

    // MARK: - Private

    private func createVariableFont(family: String, size: CGFloat, weight: CGFloat, italic: Bool = false) -> UIFont? {
        // Use .family attribute for variable fonts - this enables the weight axis
        let descriptor = UIFontDescriptor(fontAttributes: [
            .family: family
        ])

        // Use Core Text variation attribute to set the weight axis
        // CRITICAL: Must use numeric axis tag (2003265652), NOT string "wght"
        // iOS ignores string keys in kCTFontVariationAttribute dictionary
        var variationDescriptor = descriptor.addingAttributes([
            UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [
                Self.weightAxisTag: weight
            ]
        ])

        // Apply italic trait if requested (synthesized oblique)
        // This creates a slanted version of the font when no true italic axis exists
        if italic {
            let italicTraits = variationDescriptor.symbolicTraits.union(.traitItalic)
            if let italicDescriptor = variationDescriptor.withSymbolicTraits(italicTraits) {
                variationDescriptor = italicDescriptor
            }
        }

        return UIFont(descriptor: variationDescriptor, size: size)
    }
}
