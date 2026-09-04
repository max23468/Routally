import RoutallyDomain
import XCTest

final class PerformanceTests: XCTestCase {
  private let fixture = ReferenceDomainFixture.make()
  private var consumedCount = 0

  func testResolvedEventsPerformance() {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
      consumedCount = fixture.ledger.resolvedEvents(asOf: fixture.asOf).count
    }
    XCTAssertEqual(consumedCount, 9_900)
  }

  func testDomainReductionPerformance() {
    measureReduction(catalog: fixture.catalog)
  }

  func testDomainReductionWithoutCyclesPerformance() {
    measureReduction(
      catalog: DomainCatalog(
        routines: fixture.catalog.routines,
        links: fixture.catalog.links
      )
    )
  }

  func testDomainReductionWithoutLinksOrCyclesPerformance() {
    measureReduction(catalog: DomainCatalog(routines: fixture.catalog.routines))
  }

  private func measureReduction(catalog: DomainCatalog) {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
      consumedCount = try! DomainEngine.reduce(
        catalog: catalog,
        ledger: fixture.ledger,
        asOf: fixture.asOf,
        calendar: fixture.calendar
      ).processedEventIDs.count
    }
    XCTAssertEqual(consumedCount, 9_900)
  }

  private var options: XCTMeasureOptions {
    let options = XCTMeasureOptions()
    options.iterationCount = 5
    return options
  }
}
