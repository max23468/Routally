import Foundation

public struct LocalDay: Codable, Equatable, Hashable, Sendable {
  public let year: Int
  public let month: Int
  public let day: Int
  public let timeZoneIdentifier: String

  public init(year: Int, month: Int, day: Int, timeZoneIdentifier: String) {
    self.year = year
    self.month = month
    self.day = day
    self.timeZoneIdentifier = timeZoneIdentifier
  }

  public init(date: Date, timeZoneIdentifier: String) {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .gmt
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    self.init(
      year: components.year ?? 1,
      month: components.month ?? 1,
      day: components.day ?? 1,
      timeZoneIdentifier: timeZoneIdentifier
    )
  }
}

public struct DomainCalendar: Equatable, Sendable {
  public let timeZoneIdentifier: String
  public let firstWeekday: Int
  public let minimumDaysInFirstWeek: Int

  public init(
    timeZoneIdentifier: String = "UTC",
    firstWeekday: Int = 2,
    minimumDaysInFirstWeek: Int = 4
  ) {
    self.timeZoneIdentifier = timeZoneIdentifier
    self.firstWeekday = firstWeekday
    self.minimumDaysInFirstWeek = minimumDaysInFirstWeek
  }

  public var foundationCalendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .gmt
    calendar.firstWeekday = firstWeekday
    calendar.minimumDaysInFirstWeek = minimumDaysInFirstWeek
    return calendar
  }
}

public enum CalendarIntervalUnit: String, Codable, Equatable, Hashable, Sendable {
  case day
  case week
  case month
  case year
}

public struct CalendarIntervalRule: Codable, Equatable, Hashable, Sendable {
  public let value: Int
  public let unit: CalendarIntervalUnit
  public let preferredDayOfMonth: Int?

  public init(value: Int, unit: CalendarIntervalUnit, preferredDayOfMonth: Int? = nil) {
    self.value = value
    self.unit = unit
    self.preferredDayOfMonth = preferredDayOfMonth
  }

  public func date(after start: Date, calendar domainCalendar: DomainCalendar) -> Date? {
    guard value > 0 else { return nil }
    let calendar = domainCalendar.foundationCalendar

    switch unit {
    case .day:
      return calendar.date(byAdding: .day, value: value, to: start)
    case .week:
      return calendar.date(byAdding: .weekOfYear, value: value, to: start)
    case .month:
      return monthOrYearDate(after: start, months: value, calendar: calendar)
    case .year:
      return monthOrYearDate(after: start, months: value * 12, calendar: calendar)
    }
  }

  private func monthOrYearDate(after start: Date, months: Int, calendar: Calendar) -> Date? {
    let source = calendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second], from: start)
    guard
      let firstOfSourceMonth = calendar.date(
        from: DateComponents(year: source.year, month: source.month, day: 1)
      ),
      let firstOfTargetMonth = calendar.date(
        byAdding: .month,
        value: months,
        to: firstOfSourceMonth
      ),
      let validDays = calendar.range(of: .day, in: .month, for: firstOfTargetMonth)
    else {
      return nil
    }

    let targetMonth = calendar.dateComponents([.year, .month], from: firstOfTargetMonth)
    let desiredDay = preferredDayOfMonth ?? source.day ?? 1
    return calendar.date(
      from: DateComponents(
        year: targetMonth.year,
        month: targetMonth.month,
        day: min(desiredDay, validDays.count),
        hour: source.hour,
        minute: source.minute,
        second: source.second
      )
    )
  }
}

public enum Weekday: Int, Codable, CaseIterable, Hashable, Sendable {
  case sunday = 1
  case monday
  case tuesday
  case wednesday
  case thursday
  case friday
  case saturday
}

public struct LocalTime: Codable, Equatable, Hashable, Sendable {
  public let hour: Int
  public let minute: Int

  public init(hour: Int, minute: Int) {
    self.hour = hour
    self.minute = minute
  }
}

public enum ScheduledRule: Codable, Equatable, Hashable, Sendable {
  case weekdays(Set<Weekday>, everyWeeks: Int, time: LocalTime, anchor: Date)
  case dayOfMonth(Int, time: LocalTime)
  case interval(CalendarIntervalRule, time: LocalTime, anchor: Date)

  public func nextDate(after date: Date, calendar domainCalendar: DomainCalendar) -> Date? {
    let calendar = domainCalendar.foundationCalendar

    switch self {
    case .weekdays(let weekdays, let everyWeeks, let time, let anchor):
      guard !weekdays.isEmpty, everyWeeks > 0 else { return nil }
      let start = calendar.startOfDay(for: date)
      for dayOffset in 0...(everyWeeks * 14 + 7) {
        guard let day = calendar.date(byAdding: .day, value: dayOffset, to: start) else {
          continue
        }
        let weekday = Weekday(rawValue: calendar.component(.weekday, from: day))
        guard weekday.map(weekdays.contains) == true else { continue }
        let weeks =
          calendar.dateComponents(
            [.weekOfYear],
            from: calendar.startOfDay(for: anchor),
            to: day
          ).weekOfYear ?? 0
        guard weeks >= 0, weeks % everyWeeks == 0 else { continue }
        guard
          let candidate = calendar.date(
            bySettingHour: time.hour,
            minute: time.minute,
            second: 0,
            of: day
          ), candidate > date
        else {
          continue
        }
        return candidate
      }
      return nil

    case .dayOfMonth(let desiredDay, let time):
      guard (1...31).contains(desiredDay) else { return nil }
      let currentMonth = calendar.dateComponents([.year, .month], from: date)
      for monthOffset in 0...24 {
        guard
          let first = calendar.date(
            from: DateComponents(year: currentMonth.year, month: currentMonth.month, day: 1)
          ),
          let month = calendar.date(byAdding: .month, value: monthOffset, to: first),
          let days = calendar.range(of: .day, in: .month, for: month)
        else {
          continue
        }
        let components = calendar.dateComponents([.year, .month], from: month)
        guard
          let candidate = calendar.date(
            from: DateComponents(
              year: components.year,
              month: components.month,
              day: min(desiredDay, days.count),
              hour: time.hour,
              minute: time.minute
            )
          ), candidate > date
        else {
          continue
        }
        return candidate
      }
      return nil

    case .interval(let rule, let time, let anchor):
      guard rule.value > 0 else { return nil }
      let recurrenceRule: CalendarIntervalRule
      switch rule.unit {
      case .month, .year:
        recurrenceRule = CalendarIntervalRule(
          value: rule.value,
          unit: rule.unit,
          preferredDayOfMonth: rule.preferredDayOfMonth
            ?? calendar.component(.day, from: anchor)
        )
      case .day, .week:
        recurrenceRule = rule
      }
      guard
        var candidate = calendar.date(
          bySettingHour: time.hour,
          minute: time.minute,
          second: 0,
          of: anchor
        )
      else {
        return nil
      }
      while candidate <= date {
        guard let advanced = recurrenceRule.date(after: candidate, calendar: domainCalendar) else {
          return nil
        }
        candidate = advanced
      }
      return candidate
    }
  }
}

public enum PeriodUnit: String, Codable, Equatable, Hashable, Sendable {
  case day
  case week
  case month
  case year
}

public enum LocalPeriodKey: Codable, Comparable, Hashable, Sendable {
  case day(year: Int, month: Int, day: Int)
  case week(year: Int, week: Int)
  case month(year: Int, month: Int)
  case year(Int)

  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.sortKey.lexicographicallyPrecedes(rhs.sortKey)
  }

  public static func containing(
    _ localDay: LocalDay,
    unit: PeriodUnit,
    calendar domainCalendar: DomainCalendar
  ) -> Self {
    switch unit {
    case .day:
      return .day(year: localDay.year, month: localDay.month, day: localDay.day)
    case .month:
      return .month(year: localDay.year, month: localDay.month)
    case .year:
      return .year(localDay.year)
    case .week:
      var calendar = domainCalendar.foundationCalendar
      calendar.timeZone = TimeZone(identifier: localDay.timeZoneIdentifier) ?? calendar.timeZone
      let date =
        calendar.date(
          from: DateComponents(year: localDay.year, month: localDay.month, day: localDay.day)
        ) ?? .distantPast
      let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
      return .week(
        year: components.yearForWeekOfYear ?? localDay.year,
        week: components.weekOfYear ?? 1
      )
    }
  }

  private var sortKey: [Int] {
    switch self {
    case .day(let year, let month, let day):
      return [year, month, day, 0]
    case .week(let year, let week):
      return [year, week, 0, 1]
    case .month(let year, let month):
      return [year, month, 0, 2]
    case .year(let year):
      return [year, 0, 0, 3]
    }
  }
}
