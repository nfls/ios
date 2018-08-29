//
//  Problem.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/12.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Problem: Model {
    required init(map: Map) throws {
        self.id = UUID(uuidString: try map.value("id"))!
        self.contentImageUrl = WaterConstant.apiEndpoint.appendingPathComponent("assets/papers").appendingPathComponent(try map.value("contentImageUrl"))
        self.markSchemeImageUrl = WaterConstant.apiEndpoint.appendingPathComponent("assets/papers").appendingPathComponent(try map.value("markSchemeImageUrl"))
        self.correct = try map.value("correct")
        self.mark = try map.value("mark")
        self.number = try map.value("number")
        self.type = ProblemType(rawValue: try map.value("type"))!
        self.score = try map.value("score")
        self.paper = try? map.value("paper")
        self.masterProblem = try? map.value("masterProblem")
        self.subProblems = try map.value("subProblems")
    }
    
    let id: UUID
    let contentImageUrl: URL
    let markSchemeImageUrl: URL
    let correct: String
    let mark: Int
    let number: Int
    let type: ProblemType
    let score: Int
    let paper: Paper?
    let masterProblem: Problem?
    let subProblems: [Problem]
    
    enum ProblemType: Int, Codable {
        case multipleChoice = 1
        case simpleResponse = 2
        case longAnswer = 3
    }
}
