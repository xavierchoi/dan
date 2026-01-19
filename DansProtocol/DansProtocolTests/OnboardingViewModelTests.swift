import XCTest
import UserNotifications
@testable import DansProtocol

final class OnboardingViewModelTests: XCTestCase {

    // MARK: - Language Tests

    func testUsesSystemLanguage() {
        let viewModel = OnboardingViewModel(
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        // Language should be determined by iOS per-app settings (either "en" or "ko")
        XCTAssertTrue(["en", "ko"].contains(viewModel.selectedLanguage))
    }

    // MARK: - Step Flow Tests

    func testWelcomeGoesDirectlyToDate() {
        let viewModel = OnboardingViewModel(
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        XCTAssertEqual(viewModel.currentStep, .welcome)
        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .date) // No language step
    }

    func testDateGoesToWakeTime() {
        let viewModel = OnboardingViewModel(
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        viewModel.currentStep = .date
        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .wakeTime)
    }

    // MARK: - Notification Permission Skip Tests

    func testSkipsNotificationsStepWhenAuthorized() {
        let expectation = expectation(description: "Step advances")

        let viewModel = OnboardingViewModel(
            notificationPermissionChecker: { completion in
                completion(.authorized)
            }
        )

        viewModel.currentStep = .wakeTime
        viewModel.nextStep()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewModel.currentStep, .ready) // Skipped .notifications
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSkipsNotificationsStepWhenDenied() {
        let expectation = expectation(description: "Step advances")

        let viewModel = OnboardingViewModel(
            notificationPermissionChecker: { completion in
                completion(.denied)
            }
        )

        viewModel.currentStep = .wakeTime
        viewModel.nextStep()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewModel.currentStep, .ready) // Skipped .notifications
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testShowsNotificationsStepWhenNotDetermined() {
        let expectation = expectation(description: "Step advances")

        let viewModel = OnboardingViewModel(
            notificationPermissionChecker: { completion in
                completion(.notDetermined)
            }
        )

        viewModel.currentStep = .wakeTime
        viewModel.nextStep()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewModel.currentStep, .notifications) // Did not skip
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Previous Step Tests

    func testPreviousStepFromDateGoesToWelcome() {
        let viewModel = OnboardingViewModel(
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        viewModel.currentStep = .date
        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .welcome)
    }

    func testPreviousStepFromReadyGoesToWakeTime() {
        let viewModel = OnboardingViewModel(
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        viewModel.currentStep = .ready
        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .wakeTime) // Always go to wakeTime
    }
}
