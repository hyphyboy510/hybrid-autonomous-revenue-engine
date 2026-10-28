import Foundation
import SwiftUI

@MainActor
final class RevenueStore: ObservableObject {
    @Published var totalRevenue: Double = 12980.0
    @Published var pipelines: [Pipeline] = [
        Pipeline(id: "automaton-001", type: "automaton", status: "running", totalRevenue: 3450.75, uptime: 98.9, activeTasks: 4, lastSync: "just now"),
        Pipeline(id: "bandwidth-001", type: "bandwidth", status: "running", totalRevenue: 420.0, uptime: 99.2, activeTasks: 3, lastSync: "just now"),
        Pipeline(id: "setandforget-001", type: "set_and_forget", status: "running", totalRevenue: 8609.25, uptime: 99.1, activeTasks: 12, lastSync: "just now")
    ]
    @Published var leads: [Lead] = [
        Lead(id: 1, name: "Ava Patel", email: "ava@northstar.ai", company: "Northstar AI", stage: "qualified", value: 12000, source: "outbound", updatedAt: "Now"),
        Lead(id: 2, name: "Milo Chen", email: "milo@atlascloud.io", company: "Atlas Cloud", stage: "proposal", value: 18000, source: "partner", updatedAt: "Now"),
        Lead(id: 3, name: "Sofia Reed", email: "sofia@greenline.io", company: "Greenline", stage: "demo", value: 9500, source: "inbound", updatedAt: "Now")
    ]

    func refresh() async {
        guard let url = URL(string: "http://localhost:5001/api/v1/metrics") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(MetricsResponse.self, from: data)
            self.totalRevenue = decoded.totalRevenue
            self.pipelines = decoded.pipelines
        } catch {
            print("Failed to load metrics: \(error)")
        }

        guard let leadsURL = URL(string: "http://localhost:5001/api/v1/leads") else { return }

        do {
            let (leadData, _) = try await URLSession.shared.data(from: leadsURL)
            let decoded = try JSONDecoder().decode(LeadsResponse.self, from: leadData)
            self.leads = decoded.leads
        } catch {
            print("Failed to load leads: \(error)")
        }
    }
}
