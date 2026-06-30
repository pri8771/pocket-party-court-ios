import Foundation

enum AnalyticsEvent: String, CaseIterable {
    case appOpened = "app_opened"
    case gameStarted = "game_started"
    case deckSelected = "deck_selected"
    case caseDrawn = "case_drawn"
    case timerCompleted = "timer_completed"
    case voteCompleted = "vote_completed"
    case verdictGenerated = "verdict_generated"
    case sessionSaved = "session_saved"
    case historyViewed = "history_viewed"
    case caseRevealed = "case_revealed"
    case voteCast = "vote_cast"
    case verdictShared = "verdict_shared"
    case nextCaseStarted = "next_case_started"
    case newRoundStarted = "new_round_started"
    case gameRestarted = "game_restarted"
    case gameExited = "game_exited"
    case paywallViewed = "paywall_viewed"
    case deckUnlocked = "deck_unlocked"
    case aboutViewed = "about_viewed"
}
