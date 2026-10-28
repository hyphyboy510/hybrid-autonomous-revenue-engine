import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: RevenueStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    headerCard
                    statsGrid
                    pipelinesSection
                    leadsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Revenue Engine")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await store.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            await store.refresh()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hybrid Autonomous Revenue Engine")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                        .textCase(.uppercase)
                        .tracking(1.2)
                    Text("$\(store.totalRevenue, format: .currency(code: "USD"))")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                }
                Spacer()
                Image(systemName: "waveform.badge.plus")
                    .font(.system(size: 28))
                    .foregroundStyle(.cyan)
            }

            HStack {
                statusPill(label: "Live", color: .green)
                Spacer()
                Text("iPhone 17 Pro Max native")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.12, blue: 0.18), Color(red: 0.09, green: 0.17, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(26)
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            statBubble(title: "Pipelines", value: "\(store.pipelines.count)")
            statBubble(title: "Potential", value: "\(store.leads.count)")
            statBubble(title: "Uptime", value: String(format: "%.1f%%", store.pipelines.map(\.uptime).reduce(0, +) / Double(max(store.pipelines.count, 1))))
        }
    }

    private var pipelinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Pipelines")
            ForEach(store.pipelines) { pipeline in
                pipelineCard(pipeline)
            }
        }
    }

    private var leadsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Leads")
            ForEach(store.leads.prefix(3)) { lead in
                leadRow(lead)
            }
        }
    }

    private func pipelineCard(_ pipeline: Pipeline) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(pipeline.type.capitalized)
                    .font(.headline)
                Spacer()
                statusPill(label: pipeline.status, color: pipeline.status == "running" ? .green : .orange)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Revenue")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(pipeline.totalRevenue, format: .currency(code: "USD"))")
                        .font(.title3.bold())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Uptime")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(pipeline.uptime, specifier: "%.1f")%")
                        .font(.title3.bold())
                }
            }

            HStack {
                Label("\(pipeline.activeTasks) active tasks", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(pipeline.lastSync)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }

    private func leadRow(_ lead: Lead) -> some View {
        HStack(alignment: .center) {
            Circle()
                .frame(width: 42, height: 42)
                .foregroundStyle(Color.cyan.opacity(0.18))
                .overlay(
                    Text(String(lead.name.prefix(1)))
                        .font(.headline)
                        .foregroundStyle(.cyan)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(lead.name)
                    .font(.headline)
                Text(lead.company)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(lead.value, format: .currency(code: "USD"))")
                    .font(.headline)
                Text(lead.stage.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statBubble(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, minHeight: 86)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
    }

    private func statusPill(label: String, color: Color) -> some View {
        Text(label)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(color)
            .background(color.opacity(0.12))
            .cornerRadius(999)
    }
}

#Preview {
    ContentView()
        .environmentObject(RevenueStore())
}
