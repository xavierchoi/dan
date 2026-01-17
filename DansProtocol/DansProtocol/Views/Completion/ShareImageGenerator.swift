import SwiftUI
import UIKit

struct ShareImageGenerator {
    static func generate(components: LifeGameComponents, language: String) -> UIImage? {
        let view = ShareCardView(components: components, language: language)

        let controller = UIHostingController(rootView: view)
        let size = CGSize(width: 1080, height: 1920) // Instagram Story size

        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .black

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ShareCardView: View {
    let components: LifeGameComponents
    let language: String

    var body: some View {
        ZStack {
            Color.black

            VStack(alignment: .leading, spacing: 48) {
                Text(language == "ko" ? "나의 라이프 게임" : "My Life Game")
                    .font(.custom("PlayfairDisplay-Regular", size: 48))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 32) {
                    ShareComponentItem(
                        title: language == "ko" ? "안티비전" : "Anti-Vision",
                        value: components.antiVision
                    )
                    ShareComponentItem(
                        title: language == "ko" ? "비전" : "Vision",
                        value: components.vision
                    )
                    ShareComponentItem(
                        title: language == "ko" ? "1년 목표" : "1-Year Goal",
                        value: components.oneYearGoal
                    )
                    ShareComponentItem(
                        title: language == "ko" ? "1달 프로젝트" : "1-Month Project",
                        value: components.oneMonthProject
                    )
                    ShareComponentItem(
                        title: language == "ko" ? "일일 레버" : "Daily Levers",
                        value: components.dailyLevers.joined(separator: " • ")
                    )
                    ShareComponentItem(
                        title: language == "ko" ? "제약" : "Constraints",
                        value: components.constraints
                    )
                }

                Spacer()

                Text("Dan's Protocol")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
            }
            .padding(60)
        }
    }
}

struct ShareComponentItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .tracking(2)

            Text(value)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(3)
        }
    }
}
