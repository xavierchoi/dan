import Foundation
import SwiftData

@Model
final class LifeGameComponents {
    var antiVision: String
    var vision: String
    var oneYearGoal: String
    var oneMonthProject: String
    var dailyLevers: [String]
    var constraints: String

    var session: ProtocolSession?

    init(
        antiVision: String = "",
        vision: String = "",
        oneYearGoal: String = "",
        oneMonthProject: String = "",
        dailyLevers: [String] = [],
        constraints: String = ""
    ) {
        self.antiVision = antiVision
        self.vision = vision
        self.oneYearGoal = oneYearGoal
        self.oneMonthProject = oneMonthProject
        self.dailyLevers = dailyLevers
        self.constraints = constraints
    }
}
