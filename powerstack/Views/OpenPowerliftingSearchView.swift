//
//  OpenPowerliftingSearchView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-08.
//

import SwiftUI
import Combine
import Foundation
import FirebaseFirestore

struct OpenPowerliftingSearchView: View {
    @EnvironmentObject var settings: SettingsManager
    
    @State private var debounceTimer: Timer? = nil
    @StateObject private var viewModel = LifterViewModel()
    
    @State private var lifterName: String = ""
    @State private var pounds: Bool = false
    
    @State private var suggestion: String? = nil
    @State private var filteredSuggestions: [String] = []
    
    @State private var invoked: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    if settings.disableSearchPrediction {
                        searchTextFieldNoPrediction
                    } else {
                        searchTextField
                    }
                    
                    if lifterName.count > 2 && viewModel.resourceFound {
                        if viewModel.lifters.first != nil {
                            Toggle(isOn: $pounds) {
                                Text("\(SettingsManager.unitPounds)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .textCase(.uppercase)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        if pounds {
                            lifterPersonalBestsViewPounds
                        } else {
                            lifterPersonalBestsView
                        }
                        
                        lifterProgressView
                        lifterCompetitionsView
                    }
                    
                    Spacer()
                }
            }
            .dismissKeyboardOnTap()
            .ignoresSafeArea(.keyboard)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("OpenPowerlifting Search")
            }
        }
        .onAppear {
            viewModel.fetchSuggestions()
        }
    }
    
    private var searchTextField: some View {
        ZStack(alignment: .leading) {
            HStack(alignment: .center) {
                TextField("Enter lifter name", text: $lifterName)
                    .modifier(CustomTextFieldModifier())
                    .onChange(of: lifterName) {
                        if lifterName.isEmpty {
                            viewModel.reset()
                        }
                        
                        filterSuggestions()
                        
                        debounceTimer?.invalidate()
                                        
                        debounceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                            if !invoked {
                                viewModel.fetchLifters(for: lifterName)
                            }
                            
                            invoked = false
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                if let suggestion = suggestion, value.translation.width > 0 {
                                    lifterName = suggestion
                                    
                                    viewModel.fetchLifters(for: lifterName)
                                    
                                    invoked = true
                                }
                            }
                    )
            }
            .padding(.horizontal)
            
            HStack {
                Text(lifterName)
                    .foregroundColor(.clear)
                    .padding(.trailing, 25)
                Text(suggestion?.dropFirst(lifterName.count) ?? "")
                    .foregroundColor(Color.gray.opacity(0.5))
            }
        }
    }
    
    private var searchTextFieldNoPrediction: some View {
        ZStack {
            TextField("Enter lifter name", text: $lifterName)
                .modifier(CustomTextFieldModifier())
                .padding(.horizontal)
                .onChange(of: lifterName) {
                    if lifterName.isEmpty {
                        viewModel.reset()
                    }
                    
                    debounceTimer?.invalidate()
                                    
                    debounceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        viewModel.fetchLifters(for: lifterName)
                    }
                }
        }
    }
    
    private var lifterPersonalBestsView: some View {
        Group {
            if let lifter = viewModel.lifters.first {
                ScoreCard(
                    title: "Personal Bests",
                    scores: [
                        (label: "Squat", value: formatValue(lifter.personalBests.squat, decimals: 1)),
                        (label: "Bench", value: formatValue(lifter.personalBests.bench, decimals: 1)),
                        (label: "Deadlift", value: formatValue(lifter.personalBests.deadlift, decimals: 1)),
                        (label: "Total", value: formatValue(lifter.personalBests.total, decimals: 1)),
                        (label: "Dots", value: formatValue(lifter.personalBests.dots, decimals: 2))
                    ]
                )
            }
        }
    }
    
    private var lifterPersonalBestsViewPounds: some View {
        Group {
            if let lifter = viewModel.lifters.first {
                ScoreCard(
                    title: "Personal Bests",
                    scores: [
                        (label: "Squat", value: formatValue(lifter.personalBests.squat * 2.2046, decimals: 1)),
                        (label: "Bench", value: formatValue(lifter.personalBests.bench * 2.2046, decimals: 1)),
                        (label: "Deadlift", value: formatValue(lifter.personalBests.deadlift * 2.2046, decimals: 1)),
                        (label: "Total", value: formatValue(lifter.personalBests.total * 2.2046, decimals: 1)),
                        (label: "Dots", value: formatValue(lifter.personalBests.dots, decimals: 2))
                    ]
                )
            }
        }
    }
    
    private var lifterProgressView: some View {
        Group {
            if let lifter = viewModel.lifters.first, lifter.competitions.count > 1 {
                ScoreCard(
                    title: "Progress",
                    scores: [
                        (label: "Squat", value: "\(lifter.progress.squat)%"),
                        (label: "Bench", value: "\(lifter.progress.bench)%"),
                        (label: "Deadlift", value: "\(lifter.progress.deadlift)%"),
                        (label: "Total", value: "\(lifter.progress.total)%"),
                        (label: "Dots", value: "\(lifter.progress.dots)%")
                    ]
                )
            }
        }
    }

    private var lifterCompetitionsView: some View {
        Group {
            if let lifter = viewModel.lifters.first {
                VStack(spacing: 10) {
                    Text("Competition Results")
                        .font(.system(size: 24))
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    
                    ForEach(lifter.competitions) { competition in
                        competitionView(for: competition)
                    }
                }
                .padding()
            }
        }
    }
    
    private func competitionView(for competition: Competition) -> some View {
        ZStack {
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(competition.competitionName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    let total = pounds ? competition.total * 2.2046 : competition.total
                    let bodyweight = pounds ? competition.bodyweight * 2.2046 : competition.bodyweight
                    let formattedTotal = String(format: "%.1f", total).replacingOccurrences(of: ".0", with: "")
                    let formattedBodyweight = String(format: "%.2f", bodyweight)
                    let placing = ordinal(of: competition.placing)
                    let placeEmoji = getPlaceEmoji(for: competition.placing)

                    Text("\(formattedTotal) @ \(formattedBodyweight), \(placing) Place \(placeEmoji)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Divider()
                        .background(Color.gray)
                    
                    let squatAttempts = formattedAttempts(for: competition.squatAttempts)
                    let benchAttempts = formattedAttempts(for: competition.benchAttempts)
                    let deadliftAttempts = formattedAttempts(for: competition.deadliftAttempts)
                    
                    Text("S: \(squatAttempts)")
                        .font(.body)
                        .foregroundColor(.white)
                    
                    Text("B: \(benchAttempts)")
                        .font(.body)
                        .foregroundColor(.white)
                    
                    Text("D: \(deadliftAttempts)")
                        .font(.body)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .cornerRadius(10)
            }
        }
    }
    
    private func ordinal(of number: Int) -> String {
        let suffix: String
        let tens = number % 100
        let units = number % 10
        
        if (11...13).contains(tens) {
            suffix = "th"
        } else {
            switch units {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        
        return "\(number)\(suffix)"
    }
    
    private func getPlaceEmoji(for place: Int) -> String {
        switch place {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    private func formatValue(_ value: Double, decimals: Int) -> String {
        let formatted = String(format: "%.\(decimals)f", value)
        return decimals == 1 ? formatted.replacingOccurrences(of: ".0", with: "") : formatted
    }
    
    private func formattedAttempts(for attempts: [Double?]) -> String {
        return attempts.compactMap { attempt -> String? in
            guard let attemptValue = attempt else { return nil }
            
            var formattedAttempt = String(format: "%.1f", pounds ? attemptValue * 2.2046 : attemptValue).replacingOccurrences(of: ".0", with: "")
            
            if formattedAttempt.hasPrefix("-") {
                formattedAttempt = formattedAttempt.replacingOccurrences(of: "-", with: "") + "x"
            }
            
            return formattedAttempt
        }.joined(separator: "/")
    }
    
    private func filterSuggestions() {
        if lifterName.count < 3 {
            suggestion = nil
            return
        }
        
        filteredSuggestions = viewModel.suggestions.filter { $0.lowercased().hasPrefix(lifterName.lowercased()) }
        
        suggestion = filteredSuggestions.first ?? nil
    }
}

struct ScoreCard: View {
    var title: String
    var scores: [(label: String, value: String)]
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 24))
                .bold()
                .foregroundColor(.white)
                .padding()
            
            HStack(spacing: 0) {
                ForEach(scores, id: \.label) { score in
                    VStack {
                        Text(score.label)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(score.value)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

class LifterViewModel: ObservableObject {
    @Published var lifters: [Lifter] = []
    @Published var errorMessage: String? = nil
    @Published var resourceFound: Bool = false
    @Published var suggestions: [String] = []
    
    private var db = Firestore.firestore()
    
    func fetchLifters(for lifterName: String) {
        guard !lifterName.isEmpty, lifterName.split(separator: " ").count >= 2 else {
            self.resourceFound = false
            return
        }
        
        let formattedName = lifterName
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "#", with: "")
            .lowercased()
        
        guard let url = URL(string: "https://www.openpowerlifting.org/api/liftercsv/\(formattedName)") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        db.collection("lifters").document(lifterName).getDocument { document, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Firestore error: \(error.localizedDescription)"
                }
                
                return
            }
            
            if let document = document, document.exists {
                if let timestamp = document.get("timestamp") as? Timestamp {
                    let currentTime = Date()
                    let timeElapsed = currentTime.timeIntervalSince(timestamp.dateValue())
                    
                    if timeElapsed > 86400 {
                        self.fetchAndParseCsv(from: url)
                    } else {
                        if let lifterData = try? document.data(as: LifterData.self) {
                            self.lifters = [lifterData.lifter]
                            
                            DispatchQueue.main.async {
                                self.resourceFound = true
                            }
                        }
                    }
                }
            } else {
                self.fetchAndParseCsv(from: url)
            }
        }
    }
    
    func fetchAndParseCsv(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    self.resourceFound = httpResponse.statusCode == 200
                }
                
                if httpResponse.statusCode == 404 {
                    return
                }
            }
            
            guard let data = data, let csvString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode data"
                }
                
                return
            }
            
            self.parseCsv(csvString)
        }.resume()
    }
    
    func parseCsv(_ csvString: String) {
        let rows = csvString.components(separatedBy: "\n").filter{ !$0.isEmpty }
        
        guard let headerRow = rows.first else {
            DispatchQueue.main.async {
                self.errorMessage = "CSV has no header row"
            }
            
            return
        }
        
        let headers = headerRow.components(separatedBy: ",")
        
        let nameIndex = headers.firstIndex(of: "Name") ?? 0
        let federationIndex = headers.firstIndex(of: "Federation") ?? 1
        let competitionNameIndex = headers.firstIndex(of: "MeetName") ?? 2
        let divisionIndex = headers.firstIndex(of: "Division") ?? 3
        let equipmentIndex = headers.firstIndex(of: "Equipment") ?? 4
        let weightClassIndex = headers.firstIndex(of: "WeightClassKg") ?? 5
        let bodyweightIndex = headers.firstIndex(of: "BodyweightKg") ?? 6
        let squat1Index = headers.firstIndex(of: "Squat1Kg") ?? 7
        let squat2Index = headers.firstIndex(of: "Squat2Kg") ?? 8
        let squat3Index = headers.firstIndex(of: "Squat3Kg") ?? 9
        let bench1Index = headers.firstIndex(of: "Bench1Kg") ?? 10
        let bench2Index = headers.firstIndex(of: "Bench2Kg") ?? 11
        let bench3Index = headers.firstIndex(of: "Bench3Kg") ?? 12
        let deadlift1Index = headers.firstIndex(of: "Deadlift1Kg") ?? 13
        let deadlift2Index = headers.firstIndex(of: "Deadlift2Kg") ?? 14
        let deadlift3Index = headers.firstIndex(of: "Deadlift3Kg") ?? 15
        let totalIndex = headers.firstIndex(of: "TotalKg") ?? 16
        let dotsIndex = headers.firstIndex(of: "Dots") ?? 17
        let placingIndex = headers.firstIndex(of: "Place") ?? 18
        let dateIndex = headers.firstIndex(of: "Date") ?? 19
        let bestSquatIndex = headers.firstIndex(of: "Best3SquatKg") ?? 20
        let bestBenchIndex = headers.firstIndex(of: "Best3BenchKg") ?? 21
        let bestDeadliftIndex = headers.firstIndex(of: "Best3DeadliftKg") ?? 22
        
        var competitions: [Competition] = []
        var personalBests = PersonalBests(squat: 0.0, bench: 0.0, deadlift: 0.0, total: 0.0, dots: 0.0)
        var progress = Progress(squat: 0, bench: 0, deadlift: 0, total: 0, dots: 0)
        
        var firstMeetSquat: Double = 0
        var firstMeetBench: Double = 0
        var firstMeetDeadlift: Double = 0
        var firstMeetTotal: Double = 0
        var firstMeetDots: Double = 0
        
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            guard columns.count > max(placingIndex, dotsIndex, totalIndex) else { continue }
            
            var squatAttempts = [
                Double(columns[squat1Index]),
                Double(columns[squat2Index]),
                Double(columns[squat3Index])
            ]
            
            if squatAttempts.allSatisfy({ $0 == nil }) {
                if let bestSquat = Double(columns[bestSquatIndex]) {
                    squatAttempts = [bestSquat]
                }
            }
            
            var benchAttempts = [
                Double(columns[bench1Index]),
                Double(columns[bench2Index]),
                Double(columns[bench3Index])
            ]
            
            if benchAttempts.allSatisfy({ $0 == nil }) {
                if let bestBench = Double(columns[bestBenchIndex]) {
                    benchAttempts = [bestBench]
                }
            }
            
            var deadliftAttempts = [
                Double(columns[deadlift1Index]),
                Double(columns[deadlift2Index]),
                Double(columns[deadlift3Index])
            ]
            
            if deadliftAttempts.allSatisfy({ $0 == nil }) {
                if let bestDeadlift = Double(columns[bestDeadliftIndex]) {
                    deadliftAttempts = [bestDeadlift]
                }
            }
            
            let total = Double(columns[totalIndex]) ?? 0.0
            let dots = Double(columns[dotsIndex]) ?? 0.0
            
            if [squatAttempts, benchAttempts, deadliftAttempts].allSatisfy({ !$0.compactMap({ $0 }).isEmpty }) && total != 0 {
                firstMeetSquat = squatAttempts.compactMap{ $0 }.max() ?? 0
                firstMeetBench = benchAttempts.compactMap{ $0 }.max() ?? 0
                firstMeetDeadlift = deadliftAttempts.compactMap{ $0 }.max() ?? 0
                firstMeetTotal = total
                firstMeetDots = dots
            }
            
            personalBests = PersonalBests(
                squat: max(personalBests.squat, squatAttempts.compactMap{ $0 }.max() ?? 0.0),
                bench: max(personalBests.bench, benchAttempts.compactMap{ $0 }.max() ?? 0.0),
                deadlift: max(personalBests.deadlift, deadliftAttempts.compactMap{ $0 }.max() ?? 0.0),
                total: max(personalBests.total, total),
                dots: max(personalBests.dots, dots)
            )
            
            let competition = Competition(
                placing: Int(columns[placingIndex]) ?? 0,
                federation: columns[federationIndex],
                date: columns[dateIndex],
                competitionName: columns[competitionNameIndex],
                division: columns[divisionIndex],
                equipment: columns[equipmentIndex],
                weightClass: columns[weightClassIndex],
                bodyweight: Double(columns[bodyweightIndex]) ?? 0.0,
                squatAttempts: squatAttempts,
                benchAttempts: benchAttempts,
                deadliftAttempts: deadliftAttempts,
                total: total,
                dots: dots
            )
            
            competitions.append(competition)
        }
        
        progress = Progress(
            squat: computeProgress(first: firstMeetSquat, best: personalBests.squat),
            bench: computeProgress(first: firstMeetBench, best: personalBests.bench),
            deadlift: computeProgress(first: firstMeetDeadlift, best: personalBests.deadlift),
            total: computeProgress(first: firstMeetTotal, best: personalBests.total),
            dots: computeProgress(first: firstMeetDots, best: personalBests.dots)
        )
        
        let lifter = Lifter(name: rows.dropFirst().first?.components(separatedBy: ",")[nameIndex] ?? "Unknown", personalBests: personalBests, progress: progress, competitions: competitions)
        
        let lifterData = LifterData(lifter: lifter, timestamp: Date())
        
        do {
            try db.collection("lifters").document(lifter.name).setData(from: lifterData)
            
            DispatchQueue.main.async {
                self.lifters = [lifter]
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error saving data to Firestore: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchSuggestions() {
        db.collection("lifters").getDocuments { [self] snapshot, error in
            guard let documents = snapshot?.documents else {
                return
            }
            
            self.suggestions = documents
                .sorted { getValue(from: $0, key: "personalBests.dots") > getValue(from: $1, key: "personalBests.dots") }
                .map { $0.documentID }
        }
    }
    
    func computeProgress(first: Double, best: Double) -> Int {
        guard first > 0 else { return 0 }
        
        return Int(((best - first) / first * 100).rounded())
    }
    
    func reset() {
        self.lifters = []
    }
    
    private func getValue(from document: QueryDocumentSnapshot, key: String) -> Double {
        let parts = key.split(separator: ".").map { String($0) }
        
        guard let data = (document.data()["lifter"] as? [String: Any])?[parts.first ?? key] as? [String: Any],
              let value = data[parts.last ?? key] as? Double else {
            return 0
        }
        
        return value
    }
}

struct LifterData: Codable {
    let lifter: Lifter
    let timestamp: Date
}

struct Lifter: Identifiable, Codable {
    var id = UUID()
    let name: String
    let personalBests: PersonalBests
    let progress: Progress
    let competitions: [Competition]
}

struct Competition: Identifiable, Codable {
    var id = UUID()
    let placing: Int
    let federation: String
    let date: String
    let competitionName: String
    let division: String
    let equipment: String
    let weightClass: String
    let bodyweight: Double
    let squatAttempts: [Double?]
    let benchAttempts: [Double?]
    let deadliftAttempts: [Double?]
    let total: Double
    let dots: Double
}

struct PersonalBests: Codable {
    let squat: Double
    let bench: Double
    let deadlift: Double
    let total: Double
    let dots: Double
}

struct Progress: Codable {
    let squat: Int
    let bench: Int
    let deadlift: Int
    let total: Int
    let dots: Int
}
