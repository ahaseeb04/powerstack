//
//  OpenPowerliftingSearchView.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-08.
//

import SwiftUI
import Combine

struct OpenPowerliftingSearchView: View {
    @StateObject private var viewModel = LifterViewModel()
    @State private var lifterName: String = ""
    @State private var debounceTimer: Timer? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    searchTextField
                    lifterCompetitionsView
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
    }

    private var searchTextField: some View {
        TextField("Enter lifter name", text: $lifterName)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)
            .disableAutocorrection(true)
            .onChange(of: lifterName) {
                debounceTimer?.invalidate()
                
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    viewModel.fetchLifters(for: lifterName)
                }
            }
    }

    private var lifterCompetitionsView: some View {
        Group {
            if let lifter = viewModel.lifters.first {
                VStack(spacing: 10) {
                    ForEach(lifter.competitions) { competition in
                        ScrollView(.horizontal, showsIndicators: false) {
                            competitionView(for: competition)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func competitionView(for competition: Competition) -> some View {
        ZStack {
            HStack(spacing: 0) {
                Text(ordinal(of: competition.placing))
                    .frame(width: 30, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(competition.federation)
                    .frame(width: 50, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(competition.date)
                    .frame(width: 100, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(competition.competitionName)
                    .frame(width: 225, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(competition.division)
                    .frame(width: 80, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(competition.equipment)
                    .frame(width: 80, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(competition.weightClass)
                    .frame(width: 60, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(String(competition.bodyweight))
                    .frame(width: 60, alignment: .leading)
                    .padding(.horizontal, 10)
                
                ForEach(competition.squatAttempts, id: \.self) { attempt in
                    let nonOptionalAttempt = attempt ?? 0.0
                    
                    Text(String(nonOptionalAttempt).replacingOccurrences(of: ".0", with: ""))
                        .frame(width: 60, alignment: .leading)
                        .padding(.horizontal, 5)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                ForEach(competition.benchAttempts, id: \.self) { attempt in
                    let nonOptionalAttempt = attempt ?? 0.0
                    
                    Text(String(nonOptionalAttempt).replacingOccurrences(of: ".0", with: ""))
                        .frame(width: 60, alignment: .leading)
                        .padding(.horizontal, 5)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                ForEach(competition.deadliftAttempts, id: \.self) { attempt in
                    let nonOptionalAttempt = attempt ?? 0.0
                    
                    Text(String(nonOptionalAttempt).replacingOccurrences(of: ".0", with: ""))
                        .frame(width: 60, alignment: .leading)
                        .padding(.horizontal, 5)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Text(String(competition.total))
                    .frame(width: 60, alignment: .leading)
                    .padding(.horizontal, 10)
                
                Text(String(competition.dots))
                    .frame(width: 70, alignment: .leading)
                    .padding(.horizontal, 10)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
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
}


class LifterViewModel: ObservableObject {
    @Published var lifters: [Lifter] = []
    @Published var errorMessage: String? = nil
    
    func fetchLifters(for lifterName: String) {
        let formattedName = lifterName.replacingOccurrences(of: " ", with: "").lowercased()
        
        guard let url = URL(string: "https://www.openpowerlifting.org/api/liftercsv/\(formattedName)") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                
                return
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
        let bodyWeightIndex = headers.firstIndex(of: "BodyweightKg") ?? 6
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
        
        var parsedCompetitions: [Competition] = []
        var personalBests: (squat: Double, bench: Double, deadlift: Double, total: Double, dots: Double) = (0.0, 0.0, 0.0, 0.0, 0.0)
        
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
            
            personalBests = (
                max(personalBests.squat, squatAttempts.compactMap{ $0 }.max() ?? 0.0),
                max(personalBests.bench, benchAttempts.compactMap{ $0 }.max() ?? 0.0),
                max(personalBests.deadlift, deadliftAttempts.compactMap{ $0 }.max() ?? 0.0),
                max(personalBests.total, total),
                max(personalBests.dots, dots)
            )
            
            let competition = Competition(
                federation: columns[federationIndex],
                competitionName: columns[competitionNameIndex],
                division: columns[divisionIndex],
                equipment: columns[equipmentIndex],
                weightClass: columns[weightClassIndex],
                bodyweight: Double(columns[bodyWeightIndex]) ?? 0.0,
                squatAttempts: squatAttempts,
                benchAttempts: benchAttempts,
                deadliftAttempts: deadliftAttempts,
                total: total,
                dots: dots,
                placing: Int(columns[placingIndex]) ?? 0,
                date: columns[dateIndex]
            )
            
            parsedCompetitions.append(competition)
        }
        
        let lifter = Lifter(name: rows.dropFirst().first?.components(separatedBy: ",")[nameIndex] ?? "Unknown", personalBests: personalBests, competitions: parsedCompetitions)
        
        DispatchQueue.main.async {
            self.lifters = [lifter]
        }
    }
}

struct Lifter: Identifiable {
    let id = UUID()
    let name: String
    let personalBests: (squat: Double, bench: Double, deadlift: Double, total: Double, dots: Double)
    let competitions: [Competition]
}

struct Competition: Identifiable {
    let id = UUID()
    let federation: String
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
    let placing: Int
    let date: String
}
