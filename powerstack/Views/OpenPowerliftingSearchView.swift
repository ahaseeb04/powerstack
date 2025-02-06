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
    @AppStorage("openPowerliftingSearchPounds") private var pounds: Bool = false
    
    @State private var suggestion: String? = nil
    
    @State private var invoked: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
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
                        
                        lifterPersonalBestsView
                        
                        if settings.progressCalculationType == SettingsManager.progressCalculationTypePercentage {
                            lifterProgressViewPercentage
                        } else {
                            lifterProgressViewTotalIncrease
                        }
                        
                        lifterCompetitionsView
                    }
                    
                    Spacer()
                }
            }
            .dismissKeyboardOnTap()
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("OpenPowerlifting Search")
            }
        }
        .onAppear {            
            viewModel.fetchSuggestions()
        }
        .onLeftSwipe {
            dismiss()
        }
    }
    
    private var searchTextField: some View {
        ZStack(alignment: .leading) {
            HStack(alignment: .center) {
                TextField("Enter lifter name", text: $lifterName)
                    .modifier(CustomTextFieldModifier())
                    .overlay(ClearableTextFieldOverlay(text: $lifterName))
                    .onChange(of: lifterName) {
                        if let lastChar = lifterName.last, !lastChar.isLetter && !lastChar.isNumber {
                            return
                        }
                        
                        if lifterName.isEmpty {
                            viewModel.reset()
                        }
                        
                        getSuggestion()
                        
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
                .overlay(ClearableTextFieldOverlay(text: $lifterName))
                .padding(.horizontal)
                .onChange(of: lifterName) {
                    if let lastChar = lifterName.last, !lastChar.isLetter && !lastChar.isNumber {
                        return
                    }
                    
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
                let (squat, bench, deadlift, total, dots) = (
                    pounds ? lifter.personalBests.squat * SettingsManager.lbsPerKg : lifter.personalBests.squat,
                    pounds ? lifter.personalBests.bench * SettingsManager.lbsPerKg : lifter.personalBests.bench,
                    pounds ? lifter.personalBests.deadlift * SettingsManager.lbsPerKg : lifter.personalBests.deadlift,
                    pounds ? lifter.personalBests.total * SettingsManager.lbsPerKg : lifter.personalBests.total,
                    lifter.personalBests.dots
                )
                
                Card(
                    title: "Personal Bests",
                    data: [
                        (label: "Squat", value: formatValue(squat, decimals: 1)),
                        (label: "Bench", value: formatValue(bench, decimals: 1)),
                        (label: "Deadlift", value: formatValue(deadlift, decimals: 1)),
                        (label: "Total", value: formatValue(total, decimals: 1)),
                        (label: "Dots", value: formatValue(dots, decimals: 2))
                    ]
                )
            }
        }
    }
    
    private var lifterProgressViewPercentage: some View {
        Group {
            if let lifter = viewModel.lifters.first, lifter.competitions.count > 1 {
                let (squat, bench, deadlift, total, dots) = calculateProgressPercentage(
                    personalBests: lifter.personalBests, firstCompetition: lifter.firstCompetition
                )
                
                Card(
                    title: "Progress",
                    data: [
                        (label: "Squat", value: "\(squat)%"),
                        (label: "Bench", value: "\(bench)%"),
                        (label: "Deadlift", value: "\(deadlift)%"),
                        (label: "Total", value: "\(total)%"),
                        (label: "Dots", value: "\(dots)%")
                    ]
                )
            }
        }
    }
    
    private var lifterProgressViewTotalIncrease: some View {
        Group {
            if let lifter = viewModel.lifters.first, lifter.competitions.count > 1 {
                let (squat, bench, deadlift, total, dots) = calculateProgressTotalIncrease(
                    personalBests: lifter.personalBests, firstCompetition: lifter.firstCompetition
                )
                
                Card(
                    title: "Progress",
                    data: [
                        (label: "Squat", value: "+\(formatValue(squat, decimals: 1))"),
                        (label: "Bench", value: "+\(formatValue(bench, decimals: 1))"),
                        (label: "Deadlift", value: "+\(formatValue(deadlift, decimals: 1))"),
                        (label: "Total", value: "+\(formatValue(total, decimals: 1))"),
                        (label: "Dots", value: "+\(formatValue(dots, decimals: 2))")
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
                    HStack(spacing: 15) {
                        Text(competition.federation)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        Text(competition.date)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        let weightClass = getCompetitionWeightClass(for: competition)
                        
                        Text(weightClass == "0" ? competition.division : "\(weightClass) \(competition.division)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        Text(competition.equipment)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                    }
                    
                    Text(competition.competitionName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    let total = pounds ? competition.total * SettingsManager.lbsPerKg : competition.total
                    let bodyweight = pounds ? competition.bodyweight * SettingsManager.lbsPerKg : competition.bodyweight
                    let formattedTotal = String(format: "%.1f", total).replacingOccurrences(of: ".0", with: "")
                    let formattedBodyweight = String(format: "%.1f", bodyweight)
                    let dots = String(format: "%.2f", competition.dots)
                    let placing = ordinal(of: competition.placing)
                    let placeEmoji = getPlaceEmoji(for: competition.placing)

                    HStack {
                        if formattedTotal == "0" {
                            Text("DQ")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            Text("\(formattedTotal) @ \(formattedBodyweight)")
                                .font(.subheadline)
                                .foregroundColor(.gray) +
                            
                            Text(placing == "0th" ? "" : ", \(placing) Place \(placeEmoji)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(dots) DOTS")
                                .multilineTextAlignment(.trailing)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

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
    
    private func calculateProgressPercentage(personalBests: PersonalBests, firstCompetition: FirstCompetition) -> (squat: Int, bench: Int, deadlift: Int, total: Int, dots: Int) {
        let bests = [personalBests.squat, personalBests.bench, personalBests.deadlift, personalBests.total, personalBests.dots]
        let firsts = [firstCompetition.squat, firstCompetition.bench, firstCompetition.deadlift, firstCompetition.total, firstCompetition.dots]
        
        let progress = zip(bests, firsts).map { best, first in
            Int(((best - first) / first * 100).rounded())
        }
        
        return (
            squat: progress[0],
            bench: progress[1],
            deadlift: progress[2],
            total: progress[3],
            dots: progress[4]
        )
    }
    
    private func calculateProgressTotalIncrease(personalBests: PersonalBests, firstCompetition: FirstCompetition) -> (squat: Double, bench: Double, deadlift: Double, total: Double, dots: Double) {
        let bests = [personalBests.squat, personalBests.bench, personalBests.deadlift, personalBests.total, personalBests.dots]
        let firsts = [firstCompetition.squat, firstCompetition.bench, firstCompetition.deadlift, firstCompetition.total, firstCompetition.dots]
        
        let progress = zip(bests, firsts).map { best, first in
            Double(best - first)
        }
        
        return (
            squat: pounds ? progress[0] * SettingsManager.lbsPerKg : progress[0],
            bench: pounds ? progress[1] * SettingsManager.lbsPerKg : progress[1],
            deadlift: pounds ? progress[2] * SettingsManager.lbsPerKg : progress[2],
            total: pounds ? progress[3] * SettingsManager.lbsPerKg : progress[3],
            dots: progress[4]
        )
    }
    
    private func getCompetitionWeightClass(for competition: Competition) -> String {
        let rawWeightClass = competition.weightClass
        let numericPart = rawWeightClass
            .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
            .joined()
        
        let weightClass = Double(numericPart) ?? 0
        let convertedWeight = pounds ? weightClass * SettingsManager.lbsPerKg : weightClass
        
        let suffix = rawWeightClass.last == "+" ? "+" : ""
        
        let formattedWeight = pounds
            ? String(format: "%.1f", convertedWeight).replacingOccurrences(of: "\\..*", with: "", options: .regularExpression)
            : String(format: "%.1f", convertedWeight).replacingOccurrences(of: ".0", with: "")
        
        return formattedWeight + suffix
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
        let res = attempts.compactMap { attempt -> String? in
            guard let attemptValue = attempt else { return nil }
            
            var formattedAttempt = String(format: "%.1f", pounds ? attemptValue * SettingsManager.lbsPerKg : attemptValue).replacingOccurrences(of: ".0", with: "")
            
            if formattedAttempt.hasPrefix("-") {
                formattedAttempt = formattedAttempt.replacingOccurrences(of: "-", with: "") + "x"
            }
            
            return formattedAttempt
        }.joined(separator: "/")
        
        return res.isEmpty ? "0/0/0" : res
    }
    
    private func getSuggestion() {
        guard lifterName.count >= 3 else {
            suggestion = nil
            return
        }
        
        suggestion = viewModel.suggestions
            .first { $0.lowercased().hasPrefix(lifterName.lowercased()) }
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
            .replacingOccurrences(of: "[^a-zA-Z0-9]", with: "", options: .regularExpression)
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
        
        var seenRows = Set<String>()
        var competitions: [Competition] = []
        var personalBests = PersonalBests(squat: 0.0, bench: 0.0, deadlift: 0.0, total: 0.0, dots: 0.0)
        
        var firstMeetSquat: Double = 0
        var firstMeetBench: Double = 0
        var firstMeetDeadlift: Double = 0
        var firstMeetTotal: Double = 0
        var firstMeetDots: Double = 0
        
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            guard columns.count > max(placingIndex, dotsIndex, totalIndex) else { continue }
            
            let rowIdentifier = "\(columns[dateIndex]) \(columns[bodyweightIndex]) \(columns[dotsIndex])"
            
            guard !seenRows.contains(rowIdentifier) else { continue }
            seenRows.insert(rowIdentifier)
            
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
            
            if total != 0 {
                personalBests = PersonalBests(
                    squat: max(personalBests.squat, squatAttempts.compactMap{ $0 }.max() ?? 0.0),
                    bench: max(personalBests.bench, benchAttempts.compactMap{ $0 }.max() ?? 0.0),
                    deadlift: max(personalBests.deadlift, deadliftAttempts.compactMap{ $0 }.max() ?? 0.0),
                    total: max(personalBests.total, total),
                    dots: max(personalBests.dots, dots)
                )
            }
            
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
        
        let firstCompetition = FirstCompetition(
            squat: firstMeetSquat,
            bench: firstMeetBench,
            deadlift: firstMeetDeadlift,
            total: firstMeetTotal,
            dots: firstMeetDots
        )
        
        let lifter = Lifter(
            name: rows.dropFirst().first?.components(separatedBy: ",")[nameIndex] ?? "Unknown",
            personalBests: personalBests,
            firstCompetition: firstCompetition,
            competitions: competitions
        )
        
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
        let cacheKey = "cachedSuggestions"
        let timestampKey = "lastSuggestionFetchTimestamp"
        let cacheExpiration: TimeInterval = 60 * 60
        
        if let cachedSuggestions = UserDefaults.standard.array(forKey: cacheKey) as? [String],
           let cacheTimestamp = UserDefaults.standard.object(forKey: timestampKey) as? Date {
            self.suggestions = cachedSuggestions
            
            if Date().timeIntervalSince(cacheTimestamp) < cacheExpiration {
                return
            }
        }
        
        db.collection("lifters").getDocuments { [self] snapshot, error in
            guard let documents = snapshot?.documents else {
                return
            }
            
            let suggestions = documents
                .sorted { getValue(from: $0, key: "personalBests.dots") > getValue(from: $1, key: "personalBests.dots") }
                .map { $0.documentID }
            
            UserDefaults.standard.set(suggestions, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: timestampKey)
            
            self.suggestions = suggestions
        }
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
    let firstCompetition: FirstCompetition
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

struct FirstCompetition: Codable {
    let squat: Double
    let bench: Double
    let deadlift: Double
    let total: Double
    let dots: Double
}
