import Foundation
import Observation

@Observable
final class HomeViewModel {
    let headline = "Court is now in session."
    let subtitle = "Put silly disputes on trial, argue your case, vote, and crown a winner — all in one phone."

    /// Rotating one-liners shown under the hero for a little life.
    let taglines = [
        "Settle it in five minutes flat.",
        "No backend. No login. Just verdicts.",
        "The gavel decides. You just argue.",
        "Order in the living room."
    ]
}
