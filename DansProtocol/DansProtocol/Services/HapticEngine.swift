//
//  HapticEngine.swift
//  DansProtocol
//
//  Centralized haptic feedback service for tactile feedback throughout the app's emotional journey.
//

import UIKit

/// A centralized service for providing haptic feedback throughout the app.
/// Provides pre-defined patterns aligned with the app's emotional journey.
final class HapticEngine {

    // MARK: - Singleton

    static let shared = HapticEngine()

    // MARK: - Generators

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    // MARK: - Initialization

    private init() {
        prepareGenerators()
    }

    /// Pre-warms all haptic generators for responsive feedback
    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        rigidImpact.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    // MARK: - Haptic Patterns

    /// Question transition - intensity scales with progress through the protocol
    /// - Parameter progress: Progress value from 0.0 to 1.0
    func questionTransition(progress: Double) {
        let clampedProgress = max(0.0, min(1.0, progress))

        if clampedProgress < 0.33 {
            lightImpact.prepare()
            lightImpact.impactOccurred()
        } else if clampedProgress < 0.66 {
            mediumImpact.prepare()
            mediumImpact.impactOccurred()
        } else {
            heavyImpact.prepare()
            heavyImpact.impactOccurred()
        }
    }

    /// Part completion - double tap success notification
    func partComplete() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.success)

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000)
            await MainActor.run {
                self?.notificationGenerator.prepare()
                self?.notificationGenerator.notificationOccurred(.success)
            }
        }
    }

    /// Part 2 interrupt notification - staccato burst of three rigid impacts
    func interruptBurst() {
        rigidImpact.prepare()
        rigidImpact.impactOccurred()

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 50_000_000)
            await MainActor.run {
                self?.rigidImpact.prepare()
                self?.rigidImpact.impactOccurred()
            }
        }

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run {
                self?.rigidImpact.prepare()
                self?.rigidImpact.impactOccurred()
            }
        }
    }

    /// Component saved - selection click feedback
    func componentSaved() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }

    /// Protocol completion - heartbeat pattern (thump-thump, pause, thump-thump)
    func completionHeartbeat() {
        // First heartbeat: thump-thump
        heavyImpact.prepare()
        heavyImpact.impactOccurred(intensity: 1.0)

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000)
            await MainActor.run {
                self?.heavyImpact.prepare()
                self?.heavyImpact.impactOccurred(intensity: 0.7)
            }
        }

        // Pause, then second heartbeat: thump-thump
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run {
                self?.heavyImpact.prepare()
                self?.heavyImpact.impactOccurred(intensity: 1.0)
            }
        }

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 650_000_000)
            await MainActor.run {
                self?.heavyImpact.prepare()
                self?.heavyImpact.impactOccurred(intensity: 0.7)
            }
        }
    }

    /// Simple button tap - light impact feedback
    func buttonTap() {
        lightImpact.prepare()
        lightImpact.impactOccurred()
    }
}
