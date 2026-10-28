import SwiftUI

struct Pipeline: Identifiable, Codable {
    let id: String
    let type: String
    let status: String
    let totalRevenue: Double
    let uptime: Double
    let activeTasks: Int
    let lastSync: String

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case status
        case totalRevenue = "total_revenue"
        case uptime
        case activeTasks = "active_tasks"
        case lastSync = "last_sync"
    }
}

struct MetricsResponse: Codable {
    let totalRevenue: Double
    let pipelines: [Pipeline]

    enum CodingKeys: String, CodingKey {
        case totalRevenue = "total_revenue"
        case pipelines
    }
}

struct Lead: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
    let company: String
    let stage: String
    let value: Double
    let source: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case company
        case stage
        case value
        case source
        case updatedAt = "updated_at"
    }
}

struct LeadsResponse: Codable {
    let leads: [Lead]
}
