//
//  StatisticsEngine.swift
//  TowerForge
//
//  Created by Rubesh on 11/4/24.
//

import Foundation

class StatisticsEngine {
    /// Core storage of Statistics
    var statistics = StatisticsDatabase()
    var eventStatisticLinks = EventStatisticLinkDatabase()
    var inferenceEngines: [InferenceEngineTypeWrapper: InferenceEngine] = [:]

    init() {
        self.initializeStatistics()
        self.setUpLinks()
        self.setUpInferenceEngines()
    }

    /// Add statistics links manually
    private func setUpLinks() {
        let links = StatisticsFactory.eventStatisticLinks
        for key in links.keys {
            links[key]?.forEach {
                eventStatisticLinks.addStatisticLink(for: key.type,
                                                     with: statistics.getStatistic(for: $0))
            }
        }
    }

    private func initializeStatistics() {
        eventStatisticLinks = StatisticsFactory.getDefaultEventLinkDatabase()
        loadStatistics()
    }

    private func setUpInferenceEngines() {
        InferenceEngineFactory.availableInferenceEngines.forEach { self.addInferenceEngine($0(self)) }
    }

    func addInferenceEngine(_ engine: InferenceEngine) {
        inferenceEngines[engine.asType] = engine
    }

    /// Main update function
   func update<T: TFEvent>(with event: T) {
       self.updateStatisticsOnReceive(event)
       self.notifyInferenceEngines()
    }

    /// Transfers over all transient metrics within statistics to permanent value.
    func finalize() {
        statistics.statistics.values.forEach { $0.finalizeStatistic() }
        saveStatistics()
    }

    /// Main update function
   private func updateStatisticsOnReceive<T: TFEvent>(_ event: T) {
        let eventType = TFEventTypeWrapper(type: T.self)
        guard let stats = eventStatisticLinks.getStatisticLinks(for: eventType) else {
            return
        }

        // stats.forEach { $0.update(for: eventType) }
        stats.forEach { $0.update(for: event) }
        saveStatistics()
    }

    /// TODO: Consider if passing the stats database directly is better or
    /// to follow delegate pattern and have unowned statsEngine/db variables inside
    /// InferenceEngines
    func notifyInferenceEngines() {
        inferenceEngines.values.forEach { $0.updateOnReceive() }
    }

    func getCurrentRank() -> Rank? {
        if let rankEngine = inferenceEngines[RankingEngine.asType] as? RankingEngine {
            return rankEngine.currentRank
        }
        return nil
    }

    func getCurrentExp() -> Double? {
        if let rankEngine = inferenceEngines[RankingEngine.asType] as? RankingEngine {
            return rankEngine.currentExp
        }
        return nil
    }

    private func saveStatistics() {
        _ = StorageManager.saveUniversally(statistics)
    }

    private func loadStatistics() {
        if let loadedStats = StorageManager.loadUniversally() {
            statistics = loadedStats
        }
    }

}
