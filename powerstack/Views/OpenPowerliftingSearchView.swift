//
//  OpenPowerliftingSearch.swift
//  powerstack
//
//  Created by Abdul Haseeb on 2024-12-08.
//

import SwiftUI
import SwiftSoup

struct OpenPowerliftingSearchView: View {
    @State private var searchText: String = ""
    @State private var debounceTimer: Timer? = nil
    @State private var personalBestTable: [LifterPersonalBests] = []
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                TextField("Search", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disableAutocorrection(true)
                    .onChange(of: searchText) {
                        debounceTimer?.invalidate()
                        
                        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                            searchLifter()
                        }
                    }
                
                if !personalBestTable.isEmpty {
                    Text("Personal Bests")
                        .font(.title)
                        .bold()
                        .padding()
                        .padding(.top, 20)
                    
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                        Text("Squat")
                            .bold()
                            .foregroundColor(.white)
                        Text("Bench")
                            .bold()
                            .foregroundColor(.white)
                        Text("Deadlift")
                            .bold()
                            .foregroundColor(.white)
                        Text("Total")
                            .bold()
                            .foregroundColor(.white)
                        Text("Dots")
                            .bold()
                            .foregroundColor(.white)
                        
                        ForEach(personalBestTable) { lifter in
                            Text("\(lifter.bestSquat, specifier: "%.1f")")
                                .foregroundColor(.white)
                            Text("\(lifter.bestBench, specifier: "%.1f")")
                                .foregroundColor(.white)
                            Text("\(lifter.bestDeadlift, specifier: "%.1f")")
                                .foregroundColor(.white)
                            Text("\(lifter.bestTotal, specifier: "%.1f")")
                                .foregroundColor(.white)
                            Text("\(lifter.bestDots, specifier: "%.2f")")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                 
                Spacer()
            }
            .padding(.top, -25)
        }
        .dismissKeyboardOnTap()
        .ignoresSafeArea(.keyboard)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("OpenPowerlifting Search")
            }
        }
    }
    
    func searchLifter() {
        let lifterUrl = "https://www.openpowerlifting.org/u/\(searchText.lowercased().replacingOccurrences(of: " ", with: ""))"
        
        Task {
            do {
                let html = try await fetchHtml(url: lifterUrl)
                let parsedHtml = try parseLifterHtml(html: html)
                
                personalBestTable = parsedHtml
            } catch {
                //
            }
        }
    }
    
    func fetchHtml(url: String) async throws -> String {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func parseLifterHtml(html: String) throws -> [LifterPersonalBests] {
        let doc: Document = try SwiftSoup.parse(html)
        
        let personalBestTable = try doc.select(".mixed-content table tbody tr")
        var res: [LifterPersonalBests] = []
        
        let squat = try personalBestTable.first!.select(".squat").text()
        let bench = try personalBestTable.first!.select(".bench").text()
        let deadlift = try personalBestTable.first!.select(".deadlift").text()
        let total = try personalBestTable.first!.select("td:nth-child(5)").text()
        let dots = try personalBestTable.first!.select("td:nth-child(6)").text()
        
        res.append(
            LifterPersonalBests(
                bestSquat: Double(squat) ?? 0,
                bestBench: Double(bench) ?? 0,
                bestDeadlift: Double(deadlift) ?? 0,
                bestTotal: Double(total) ?? 0,
                bestDots: Double(dots) ?? 0
            )
        )
        
        return res
    }
}

struct LifterPersonalBests: Identifiable {
    let id = UUID()
    let bestSquat: Double
    let bestBench: Double
    let bestDeadlift: Double
    let bestTotal: Double
    let bestDots: Double
}
