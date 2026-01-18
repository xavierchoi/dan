import XCTest
import UserNotifications
@testable import DansProtocol

final class OnboardingViewModelTests: XCTestCase {
    private var testDefaults: UserDefaults!

    override func setUpWithError() throws {
        testDefaults = UserDefaults(suiteName: "OnboardingViewModelTests")!
        testDefaults.removePersistentDomain(forName: "OnboardingViewModelTests")
    }

    override func tearDownWithError() throws {
        testDefaults.removePersistentDomain(forName: "OnboardingViewModelTests")
        testDefaults = nil
    }

    // MARK: - Language Storage Tests

    func testLoadsStoredLanguageOnInit() {
        testDefaults.set("ko", forKey: OnboardingViewModel.userLanguageKey)

        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        XCTAssertEqual(viewModel.selectedLanguage, "ko")
    }

    func testUsesSystemLanguageWhenNoStoredLanguage() {
        // No stored language
        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        // Should be either "en" or "ko" based on system language
        XCTAssertTrue(["en", "ko"].contains(viewModel.selectedLanguage))
    }

    func testSavesLanguageToUserDefaults() {
        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        viewModel.selectedLanguage = "ko"

        XCTAssertEqual(testDefaults.string(forKey: OnboardingViewModel.userLanguageKey), "ko")
    }

    // MARK: - Language Step Skip Tests

    func testSkipsLanguageStepWhenLanguageStored() {
        testDefaults.set("en", forKey: OnboardingViewModel.userLanguageKey)

        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        XCTAssertEqual(viewModel.currentStep, .welcome)
        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .date) // Skipped .language
    }

    func testShowsLanguageStepWhenNoLanguageStored() {
        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        XCTAssertEqual(viewModel.currentStep, .welcome)
        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .language) // Did not skip
    }

    // MARK: - Notification Permission Skip Tests

    func testSkipsNotificationsStepWhenAuthorized() {
        let expectation = expectation(description: "Step advances")

        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
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
            userDefaults: testDefaults,
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
            userDefaults: testDefaults,
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

    func testPreviousStepFromDateGoesToWelcomeWhenLanguageWasSkipped() {
        testDefaults.set("en", forKey: OnboardingViewModel.userLanguageKey)

        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        viewModel.currentStep = .date
        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .welcome) // Skipped .language
    }

    func testPreviousStepFromDateGoesToLanguageWhenNoLanguageStored() {
        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        viewModel.currentStep = .date
        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .language) // Did not skip
    }

    func testPreviousStepFromReadyGoesToWakeTime() {
        let viewModel = OnboardingViewModel(
            userDefaults: testDefaults,
            notificationPermissionChecker: { $0(.notDetermined) }
        )

        viewModel.currentStep = .ready
        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .wakeTime) // Always go to wakeTime
    }
}
