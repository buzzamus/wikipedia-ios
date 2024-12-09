import UIKit
import PassKit
import SwiftUI
import WMFComponents
import WMFData
import CocoaLumberjackSwift

@objc(WMFYearInReviewCoordinator)
final class YearInReviewCoordinator: NSObject, Coordinator {

    var theme: Theme
    let dataStore: MWKDataStore

    var navigationController: UINavigationController
    private weak var viewModel: WMFYearInReviewViewModel?
    private let targetRects = WMFProfileViewTargetRects()
    let dataController: WMFYearInReviewDataController
    var donateCoordinator: DonateCoordinator?

    let yearInReviewDonateText = WMFLocalizedString("year-in-review-donate", value: "Donate", comment: "Year in review donate button")
    weak var badgeDelegate: YearInReviewBadgeDelegate?

    // Collective base numbers that will change for header
    var collectiveNumArticlesNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(63590000)
        return formatter.string(from: number) ?? "63,590,000"
    }

    var collectiveNumReadingLists: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(31600000)
        return formatter.string(from: number) ?? "31,600,000"
    }

    var collectiveNumEditsNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(452257)
        return formatter.string(from: number) ?? "452,257"
    }

    var collectiveNumEditsPerMinuteNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(342)
        return formatter.string(from: number) ?? "342"
    }

    var collectiveNumViewsNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(1522941831)
        return formatter.string(from: number) ?? "1,522,941,831"
    }

    var languageCode: String? {
        dataStore.languageLinkController.appLanguage?.languageCode
    }

    var aboutWikimediaURL: String {
        if let languageCode {
            "https://www.mediawiki.org/wiki/Wikimedia_Apps/About_the_Wikimedia_Foundation/\(languageCode)"
        } else {
            "https://www.mediawiki.org/wiki/Wikimedia_Apps/About_the_Wikimedia_Foundation"
        }
    }

    var aboutYIRURL: URL? {
        if let languageCode {
            URL(string: "https://www.mediawiki.org/wiki/Wikimedia_Apps/Team/iOS/Personalized_Wikipedia_Year_in_Review/How_your_data_is_used/\(languageCode)")
        } else {
            URL(string: "https://www.mediawiki.org/wiki/Wikimedia_Apps/Team/iOS/Personalized_Wikipedia_Year_in_Review/How_your_data_is_used")
        }
    }
    
    private lazy var localizedStrings: WMFYearInReviewViewModel.LocalizedStrings = {
        return WMFYearInReviewViewModel.LocalizedStrings.init(
         donateButtonTitle: CommonStrings.donateTitle,
            doneButtonTitle:CommonStrings.doneTitle,
         shareButtonTitle: CommonStrings.shortShareTitle,
         nextButtonTitle: CommonStrings.nextTitle,
            finishButtonTitle: WMFLocalizedString("year-in-review-finish", value: "Finish", comment: "Year in review finish button. Displayed on last slide and dismisses feature view."),
            firstSlideTitle: CommonStrings.exploreYiRTitle,
            firstSlideSubtitle: WMFLocalizedString("year-in-review-subtitle", value: "See insights about which articles you read on the Wikipedia app and the edits you made. Your reading history is kept protected. Reading insights are calculated using locally stored data on your device.", comment: "Year in review page information"),
            firstSlideCTA: CommonStrings.getStartedTitle,
            firstSlideLearnMore: CommonStrings.learnMoreTitle(),
            shareText: WMFLocalizedString("year-in-review-share-text", value: "Here's my Wikipedia Year In Review. Created with the Wikipedia iOS app", comment: "Text shared the Year In Review slides"),
         wIconAccessibilityLabel: WMFLocalizedString("year-in-review-wikipedia-w-accessibility-label", value: "Wikipedia w logo", comment: "Accessibility label for the Wikipedia w logo"),
         globeImageAccessibilityLabel: WMFLocalizedString("year-in-review-wikipedia-globe-accessibility-label", value: "Wikipedia globe logo", comment: "Accessibility label for the Wikipedia globe logo"),
         wmfLogoImageAccessibilityLabel: WMFLocalizedString("year-in-review-wmf-logo-accessibility-label", value: "Wikimedia Foundation logo", comment: "Accessibility label for the Wikimedia Foundation logo")
        )
    }()

    @objc public init(navigationController: UINavigationController, theme: Theme, dataStore: MWKDataStore, dataController: WMFYearInReviewDataController) {
        self.navigationController = navigationController
        self.theme = theme
        self.dataStore = dataStore
        self.dataController = dataController
    }

    func formatNumber(_ number: NSNumber, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: number) ?? "\(number)"
    }

    // MARK: - Base Slide Strings
    
    var baseSlide1Title: String {
        WMFLocalizedString("year-in-review-base-reading-title", value: "Reading brought us together", comment: "Year in review, collective reading article count slide title")
    }

    var baseSlide1Subtitle: String {
        let format = WMFLocalizedString("year-in-review-base-reading-subtitle", value: "Wikipedia had %1$@ million articles across over %2$@ active languages this year. You joined millions in expanding knowledge and exploring diverse topics.", comment: "Year in review, collective reading count slide subtitle. %1$@ is replaced with a formatted number of articles available across Wikipedia, e.g. \"63.59\". %2$@ is replaced with the number of active languages available on Wikipedia, e.g. \"332\"")

        let numArticlesString = formatNumber(63.59, fractionDigits: 2)
        let numLanguagesString = formatNumber(332, fractionDigits: 0)

        return String.localizedStringWithFormat(format, numArticlesString, numLanguagesString)
    }

    var baseSlide2Title: String {
        let format = WMFLocalizedString("year-in-review-base-viewed-title", value: "We have viewed Wikipedia articles %1$@ Billion times", comment: "Year in review, collective article view count slide title. %1$@ is replaced with the text representing the number of article views across Wikipedia, e.g. \"1.5\".")

        let numArticleViewsString = formatNumber(1.5, fractionDigits: 2)

        return String.localizedStringWithFormat(format, numArticleViewsString)
    }

    var baseSlide2Subtitle: String {
        let format = WMFLocalizedString("year-in-review-base-viewed-subtitle", value: "iOS app users have viewed Wikipedia articles %1$@ Billion times. For people around the world, Wikipedia is the first stop when answering a question, looking up information for school or work, or learning a new fact.", comment: "Year in review, collective article view count subtitle, %1$@ is replaced with the number of article views text, e.g. \"1.5\"")

        let numArticleViewsString = formatNumber(1.5, fractionDigits: 2)

        return String.localizedStringWithFormat(format, numArticleViewsString)
    }

    var baseSlideSavedArticlesTitle: String {
        let format = WMFLocalizedString("year-in-review-base-saved-title", value: "We had over %1$@ Million reading lists", comment: "Year in review, collective saved articles count slide title, %1$@ is replaced with the number of saved articles text, e.g. \"31.6\".")

        let numSavedArticlesString = formatNumber(31.6, fractionDigits: 2)
        return String.localizedStringWithFormat(format, numSavedArticlesString)
    }

    var baseSlideSavedArticlesSubtitle: String {
        let format = WMFLocalizedString("year-in-review-base-saved-subtitle", value: "Active iOS users had over %1$@ million reading lists this year. Adding articles to Reading lists allows you to access articles even while offline. You can also log in to sync reading lists across devices.", comment: "Year in review, collective saved articles count slide subtitle, %1$@ is replaced with the number of saved articles text, e.g. \"31.6\".")
        let numSavedArticlesString = formatNumber(31.6, fractionDigits: 2)
        return String.localizedStringWithFormat(format, numSavedArticlesString)
    }

    var baseSlide3Title: String {
        let format = WMFLocalizedString("year-in-review-base-editors-title", value: "Editors on the iOS app made more than %1$@ edits", comment: "Year in review, collective edits count slide title, %1$@ is replaced with the number of edits text, e.g. \"452,257\".")

        let numEditsString = formatNumber(452257, fractionDigits: 0)

        return String.localizedStringWithFormat(format, numEditsString)
    }

    var baseSlide3Subtitle: String {
        let format = WMFLocalizedString("year-in-review-base-editors-subtitle", value: "Wikipedia's community of volunteer editors made more than %1$@ edits on the iOS app so far this year. The heart and soul of Wikipedia is our global community of volunteer contributors, donors, and billions of readers like yourself – all united to share unlimited access to reliable information.", comment: "Year in review, collective edits count slide subtitle, %1$@ is replaced with the number of edits text, e.g. \"452,257\"")

        let numEditsString = formatNumber(452257, fractionDigits: 0)

        return String.localizedStringWithFormat(format, numEditsString)
    }

    var baseSlide4Title: String {
        let format = WMFLocalizedString("year-in-review-base-edits-title", value: "Wikipedia was edited %1$@ times per minute", comment: "Year in review, collective edits per minute slide title, %1$@ is replaced with the number of edits per minute text, e.g. \"342\".")

        let numEditsPerMinString = formatNumber(342, fractionDigits: 0)

        return String.localizedStringWithFormat(format, numEditsPerMinString)
    }

    var baseSlide4Subtitle: String {
        let format = WMFLocalizedString("year-in-review-base-edits-subtitle", value: "This year, Wikipedia was edited at an average rate of %1$@ times per minute. Articles are collaboratively created and improved using reliable sources. All of us have knowledge to share, [learn how to participate](%2$@).", comment: "Year in review, collective edits per minute slide subtitle, %1$@ is replaced with the number of edits per minute text, e.g. \"342\". %2$@ is replaced with a link to the Mediawiki Apps team FAQ about editing.")
        let numEditsPerMinString = formatNumber(342, fractionDigits: 0)
        var editingFAQ: String
        if languageCode == "es" {
            editingFAQ = "https://www.mediawiki.org/wiki/Wikimedia_Apps/iOS_FAQ/es#Edici%C3%B3n"
        } else {
            editingFAQ = "https://www.mediawiki.org/wiki/Special:MyLanguage/Wikimedia_Apps/iOS_FAQ#Editing"
        }
        return String.localizedStringWithFormat(format, numEditsPerMinString, editingFAQ)
    }

    var baseSlide5Title: String {
        return WMFLocalizedString("year-in-review-base-donate-title", value: "0 ads served on Wikipedia", comment: "Year in review, donate slide title when user has not made any donations that year.")
    }

    func baseSlide5Subtitle() -> String {
        let format = WMFLocalizedString("year-in-review-base-donate-subtitle", value: "Wikipedia is hosted by the Wikimedia Foundation and funded by individual donations. We work to keep Wikimedia sites available to all, build features and tools to make it easy to share knowledge, support communities of volunteer editors, and more. [Learn more about our work](%1$@).", comment: "Year in review, donate slide subtitle when user has not made any donations that year. %1%@ is replaced with a MediaWiki url with more information about WMF. Do not alter markdown when translating.")
        return String.localizedStringWithFormat(format, aboutWikimediaURL)
    }
    
    
    // MARK: - Personalized Slide Strings

    func personalizedSlide1Title(readCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-reading-title-format", value: "You read {{PLURAL:%1$d|%1$d article|%1$d articles}} this year", comment: "Year in review, personalized reading article count slide title for users that read articles. %1$d is replaced with the number of articles the user read.")
        return String.localizedStringWithFormat(format, readCount)
    }

    func personalizedSlide1Subtitle(readCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-reading-subtitle-format", value: "This year, you read {{PLURAL:%1$d|%1$d article|%1$d articles}}, and Wikipedia had %2$@ million articles available across over %3$@ active languages. You joined millions in expanding knowledge and exploring diverse topics.", comment: "Year in review, personalized reading article count slide subtitle for users that read articles. %1$d is replaced with the number of articles the user read. %2$@ is replaced with the number of articles available across Wikipedia, for example, \"63.59\". %3$@ is replaced with the number of active languages available on Wikipedia, for example \"332\"")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let numArticles = NSNumber(63.59)
        let numArticlesString = formatter.string(from: numArticles) ?? "63.59"

        formatter.maximumFractionDigits = 0
        let numLanguages = NSNumber(332)
        let numLanguagesString = formatter.string(from: numLanguages) ?? "332"

        return String.localizedStringWithFormat(format, readCount, numArticlesString, numLanguagesString)
    }

    func personalizedSlide1Overlay(readCount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(value: readCount)
        return formatter.string(from: number) ?? String(readCount)
    }
    
    func personalizedSlide2Title(day: Int) -> String {
        let format = WMFLocalizedString(
            "year-in-review-personalized-day-title-format",
            value: "You read most on %1$@.",
            comment: "Year in review, personalized slide title for users that displays the weekday they read most. %1$@ is replaced with the weekday."
        )
        
        return String.localizedStringWithFormat(format, getLocalizedDay(day: day))
    }
    
    func personalizedSlide2Subtitle(day: Int) -> String {
        let format = WMFLocalizedString(
            "year-in-review-personalized-day-subtitle-format",
            value: "You read the most articles on %1$@. It's clear that %1$@ are your prime day for exploring new content. Thanks for making the most of your reading time!",
            comment: "Year in review, personalized slide subtitle for users that displays the weekday they read most. %1$@ is replaced with the weekday."
        )
        return String.localizedStringWithFormat(format, getLocalizedDay(day: day))
    }
    
    func personalizedSaveCountSlideOverlay(saveCount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(value: saveCount)
        return formatter.string(from: number) ?? String(saveCount)
    }
    
    func getLocalizedDay(day: Int) -> String {
        let localizedDay: String
        switch day {
        case 1: // Sunday
            localizedDay = WMFLocalizedString(
                "year-in-review-day-sunday",
                value: "Sundays",
                comment: "Localized name for Sunday in plural form."
            )
        case 2: // Monday
            localizedDay = WMFLocalizedString(
                "year-in-review-day-monday",
                value: "Mondays",
                comment: "Localized name for Monday in plural form."
            )
        case 3: // Tuesday
            localizedDay = WMFLocalizedString(
                "year-in-review-day-tuesday",
                value: "Tuesdays",
                comment: "Localized name for Tuesday in plural form."
            )
        case 4: // Wednesday
            localizedDay = WMFLocalizedString(
                "year-in-review-day-wednesday",
                value: "Wednesdays",
                comment: "Localized name for Wednesday in plural form."
            )
        case 5: // Thursday
            localizedDay = WMFLocalizedString(
                "year-in-review-day-thursday",
                value: "Thursdays",
                comment: "Localized name for Thursday in plural form."
            )
        case 6: // Friday
            localizedDay = WMFLocalizedString(
                "year-in-review-day-friday",
                value: "Fridays",
                comment: "Localized name for Friday in plural form."
            )
        case 7: // Saturday
            localizedDay = WMFLocalizedString(
                "year-in-review-day-saturday",
                value: "Saturdays",
                comment: "Localized name for Saturday in plural form."
            )
        default:
            localizedDay = "Invalid day"
        }
        
        return localizedDay
    }

    func personalizedSlide3Title(editCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-editing-title-format", value: "You edited Wikipedia {{PLURAL:%1$d|%1$d time|%1$d times}}", comment: "Year in review, personalized editing article count slide title for users that edited articles. %1$d is replaced with the number of edits the user made.")
        return String.localizedStringWithFormat(format, editCount)
    }

    func personalizedSlide3Title500Plus() -> String {
        let format = WMFLocalizedString("year-in-review-personalized-editing-title-format-500plus", value: "You edited Wikipedia 500+ times", comment: "Year in review, personalized editing article count slide title for users that edited articles 500+ times.")
        return String.localizedStringWithFormat(format)
    }

    func personalizedSlide3Subtitle(editCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-editing-subtitle-format", value: "You edited Wikipedia {{PLURAL:%1$d|%1$d time|%1$d times}}. Thank you for being one of the volunteer editors making a difference on Wikimedia projects around the world.", comment: "Year in review, personalized editing article count slide subtitle for users that edited articles. %1$d is replaced with the number of edits the user made.")
        return String.localizedStringWithFormat(format, editCount)
    }

    func personalizedSlide3Subtitle500Plus() -> String {
        let format = WMFLocalizedString("year-in-review-personalized-editing-subtitle-format-500plus", value: "You edited Wikipedia 500+ times. Thank you for being one of the volunteer editors making a difference on Wikimedia projects around the world.", comment: "Year in review, personalized editing article count slide subtitle for users that edited articles more than 500 times.")
        return String.localizedStringWithFormat(format)
    }

    func personalizedSlide3Overlay(editCount: Int) -> String {
        guard editCount < 500 else {
            return "500+"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(value: editCount)
        return formatter.string(from: number) ?? String(editCount)
    }
    
    func personalizedSlide4Title(views: Int) -> String {
        let format = WMFLocalizedString(
            "year-in-review-personalized-edit-views-title-format",
            value: "Your edits were viewed more than %1$@ times recently",
            comment: "Year in review, personalized slide title for users that display how many views their edits have. %1$@ is replaced with the amount of edit views."
        )
        
        return String.localizedStringWithFormat(format, String(views))
    }
    
    func personalizedSlide4Subitle(views: Int) -> String {
        let format = WMFLocalizedString(
            "year-in-review-personalized-edit-views-subtitle-format",
            value: "Readers around the world appreciate your contributions. In the last 2 months, articles you've edited have received %1$@ total views. Thanks to editors like you, Wikipedia is a steadily improving, fact-based, and reliable knowledge resource for to the world",
            comment: "Year in review, personalized slide subtitle for users that display how many views their edits have. %1$@ is replaced with the amount of edit views."
        )
        
        return String.localizedStringWithFormat(format, String(views))
    }
    
    var personalizedSlide5Title: String {
        return WMFLocalizedString("year-in-review-personalized-donate-title", value: "Thank you for your contribution!", comment: "Year in review, personalized donate slide title for users that donated at least once that year. ")
    }

    func personalizedSlide5Subtitle(languageCode: String?) -> String {

        let urlString: String
        if let languageCode {
            urlString = "https://www.mediawiki.org/wiki/Wikimedia_Apps/About_the_Wikimedia_Foundation/\(languageCode)"
        } else {
            urlString = "https://www.mediawiki.org/wiki/Wikimedia_Apps/About_the_Wikimedia_Foundation"
        }

        let format = WMFLocalizedString("year-in-review-personalized-donate-subtitle", value: "Thank you for supporting Wikipedia and a world where knowledge is free for everyone. Every single edit and donation helps improve people’s access to accurate and reliable information, especially in a rapidly changing world. [Learn more about our work](%1$@).", comment: "Year in review, personalized donate slide subtitle for users that donated at least once that year. %1$@ is replaced with a MediaWiki url with more information about WMF. Do not alter markdown when translating.")
        return String.localizedStringWithFormat(format, urlString)
    }

    func personalizedSaveCountSlideTitle(saveCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-saved-title-format", value: "You saved {{PLURAL:%1$d|%1$d article|%1$d articles}}", comment: "Year in review, personalized saved articles slide subtitle. %1$d is replaced with the number of articles the user saved.")
        return String.localizedStringWithFormat(format, saveCount)
    }

    func personalizedSaveCountSlideSubtitle(saveCount: Int, articleNames: [String]) -> String {
        
        let articleName1 = articleNames.count >= 3 ? articleNames[0] : ""
        let articleName2 = articleNames.count >= 3 ? articleNames[1] : ""
        let articleName3 = articleNames.count >= 3 ? articleNames[2] : ""
        
        let format = WMFLocalizedString("year-in-review-personalized-saved-subtitle-format", value: "You saved {{PLURAL:%1$d|%1$d article|%1$d articles}} this year, including \"%2$@\", \"%3$@\" and \"%4$@\". Each saved article reflects your interests and helps build a personalized knowledge base on Wikipedia.", comment: "Year in review, personalized saved articles slide subtitle. %1$D is replaced with the number of articles the user saved, %2$@, %3$@ and %4$@ are replaced with the names  three random articles the user saved.")
        return String.localizedStringWithFormat(format, saveCount, articleName1, articleName2, articleName3)
    }

    // MARK: - Funcs

    private struct PersonalizedSlides {
        let readCount: YearInReviewSlideContent?
        let editCount: YearInReviewSlideContent?
        let donateCount: YearInReviewSlideContent?
        let saveCount: YearInReviewSlideContent?
        let mostReadDay: YearInReviewSlideContent?
        let viewCount: YearInReviewSlideContent?
    }

    func shoudlHideDonateButton() -> Bool {
        guard let dataController = try? WMFYearInReviewDataController() else {
            return false
        }
        return dataController.shouldHideDonateButton()
    }

    private func getPersonalizedSlides() -> PersonalizedSlides {

        guard let dataController = try? WMFYearInReviewDataController(),
              let report = try? dataController.fetchYearInReviewReport(forYear: WMFYearInReviewDataController.targetYear) else {
            return PersonalizedSlides(readCount: nil, editCount: nil, donateCount: nil, saveCount: nil, mostReadDay: nil, viewCount: nil)
        }

        var readCountSlide: YearInReviewSlideContent? = nil
        var editCountSlide: YearInReviewSlideContent? = nil
        var donateCountSlide: YearInReviewSlideContent? = nil
        var saveCountSlide: YearInReviewSlideContent? = nil
        var mostReadDaySlide: YearInReviewSlideContent? = nil
        var viewCountSlide: YearInReviewSlideContent? = nil
        
        for slide in report.slides {
            switch slide.id {
            case .readCount:
                if slide.display == true,
                   let data = slide.data {
                    let decoder = JSONDecoder()
                    if let readCount = try? decoder.decode(Int.self, from: data) {
                        readCountSlide = YearInReviewSlideContent(
                            imageName: "read",
                            textOverlay: personalizedSlide1Overlay(readCount: readCount),
                            title: personalizedSlide1Title(readCount: readCount),
                            informationBubbleText: nil,
                            subtitle: personalizedSlide1Subtitle(readCount: readCount),
                            loggingID: "read_count_custom",
                            infoURL: aboutYIRURL,
                            hideDonateButton: shoudlHideDonateButton())
                    }
                }
            case .editCount:
                if slide.display == true,
                   let data = slide.data {
                    let decoder = JSONDecoder()
                    if let editCount = try? decoder.decode(Int.self, from: data) {
                        editCountSlide = YearInReviewSlideContent(
                            imageName: "edits",
                            textOverlay: personalizedSlide3Overlay(editCount: editCount),
                            title: editCount >= 500 ? personalizedSlide3Title500Plus() : personalizedSlide3Title(editCount: editCount),
                            informationBubbleText: nil,
                            subtitle: editCount >= 500 ? personalizedSlide3Subtitle500Plus() : personalizedSlide3Subtitle(editCount: editCount),
                            loggingID: "edit_count_custom",
                            infoURL: aboutYIRURL,
                            hideDonateButton: shoudlHideDonateButton())
                    }
                }
            case .donateCount:
                if slide.display == true,
                   let data = slide.data {
                    let decoder = JSONDecoder()
                    if let donateCount = try? decoder.decode(Int.self, from: data),
                       donateCount > 0 {
                        donateCountSlide = YearInReviewSlideContent(
                            imageName: "thankyou",
                            imageOverlay: "wmf-logo",
                            imageOverlayAccessibilityLabel: localizedStrings.wmfLogoImageAccessibilityLabel,
                            title: personalizedSlide5Title,
                            informationBubbleText: nil,
                            subtitle: personalizedSlide5Subtitle(languageCode: dataStore.languageLinkController.appLanguage?.languageCode),
                            loggingID: "thank_custom",
                            infoURL: aboutYIRURL,
                            hideDonateButton: true)
                    }
                }
            case .saveCount:
                if slide.display == true,
                   let data = slide.data {
                    let decoder = JSONDecoder()
                    if let savedSlideData = try? decoder.decode(SavedArticleSlideData.self, from: data),
                       savedSlideData.savedArticlesCount > 3,
                       savedSlideData.articleTitles.count >= 3 {
                        let count = savedSlideData.savedArticlesCount
                        saveCountSlide = YearInReviewSlideContent(
                            imageName: "read",
                            textOverlay: personalizedSaveCountSlideOverlay(saveCount: count),
                            title: personalizedSaveCountSlideTitle(saveCount: count),
                            informationBubbleText: nil,
                            subtitle: personalizedSaveCountSlideSubtitle(saveCount: count, articleNames: savedSlideData.articleTitles),
                            loggingID: "saved_count_custom",
                            infoURL: aboutYIRURL,
                            hideDonateButton: false)
                    }
                }
            case .mostReadDay:
                if slide.display == true,
                   let data = slide.data {
                    let decoder = JSONDecoder()
                    if let mostReadDay = try? decoder.decode(WMFPageViewDay.self, from: data),
                       mostReadDay.getViewCount() > 0 {
                        mostReadDaySlide = YearInReviewSlideContent(
                            imageName: "viewed",
                            textOverlay: getLocalizedDay(day: mostReadDay.getDay()),
                            title: personalizedSlide2Title(day: mostReadDay.getDay()),
                            informationBubbleText: nil,
                            subtitle: personalizedSlide2Subtitle(day: mostReadDay.getDay()),
                            loggingID: "most_read_day_custom",
                            infoURL: aboutYIRURL,
                            hideDonateButton: shoudlHideDonateButton())
                    }
                }
            case .viewCount:
                if slide.display == true,
                   let data = slide.data {
                    let decoder = JSONDecoder()
                    if let viewCount = try? decoder.decode(Int.self, from: data),
                       viewCount > 0 {
                        viewCountSlide = YearInReviewSlideContent(
                            imageName: "viewed",
                            textOverlay: String(viewCount),
                            title: personalizedSlide4Title(views: viewCount),
                            informationBubbleText: nil,
                            subtitle: personalizedSlide4Subitle(views: viewCount),
                            loggingID: "view_count_custom",
                            infoURL: aboutYIRURL,
                            hideDonateButton: true)
                    }
                }
                break
            }
        }
        return PersonalizedSlides(readCount: readCountSlide, editCount: editCountSlide, donateCount: donateCountSlide, saveCount: saveCountSlide, mostReadDay: mostReadDaySlide, viewCount: viewCountSlide)
    }

    func start() {
        var firstSlide = YearInReviewSlideContent(
           imageName: "read",
           textOverlay: collectiveNumArticlesNumber,
           title: baseSlide1Title,
           informationBubbleText: nil,
           subtitle: baseSlide1Subtitle,
           loggingID: "read_count_base",
           infoURL: aboutYIRURL,
           hideDonateButton: shoudlHideDonateButton())

        var secondSlide = YearInReviewSlideContent(
            imageName: "viewed",
            textOverlay: collectiveNumViewsNumber,
            title: baseSlide2Title,
            informationBubbleText: nil,
            subtitle: baseSlide2Subtitle,
            loggingID: "read_view_base",
            infoURL: aboutYIRURL,
            hideDonateButton: shoudlHideDonateButton())

        var thirdSlide = YearInReviewSlideContent(
            imageName: "edits",
            textOverlay: collectiveNumReadingLists,
            title: baseSlideSavedArticlesTitle,
            informationBubbleText: nil,
            subtitle: baseSlideSavedArticlesSubtitle,
            loggingID: "saved_count_base",
            infoURL: aboutYIRURL,
            hideDonateButton: shoudlHideDonateButton())

        var fourthSlide = YearInReviewSlideContent(
           imageName: "edits",
           textOverlay: collectiveNumEditsNumber,
           title: baseSlide3Title,
           informationBubbleText: nil,
           subtitle: baseSlide3Subtitle,
           loggingID: "edit_count_base",
           infoURL: aboutYIRURL,
           hideDonateButton: shoudlHideDonateButton())
        
        var fifthSlide = YearInReviewSlideContent(
            imageName: "editedPerMinute",
            textOverlay: collectiveNumEditsPerMinuteNumber,
            title: baseSlide4Title,
            informationBubbleText: nil,
            subtitle: baseSlide4Subtitle,
            loggingID: "edit_rate_base",
            infoURL: aboutYIRURL,
            hideDonateButton: shoudlHideDonateButton())
        
        var sixthSlide = YearInReviewSlideContent(
            imageName: "thankyou",
            imageOverlay: "wmf-logo",
            imageOverlayAccessibilityLabel: localizedStrings.wmfLogoImageAccessibilityLabel,
            title: baseSlide5Title,
            informationBubbleText: nil,
            subtitle: baseSlide5Subtitle(),
            loggingID: "ads_served_base",
            infoURL: aboutYIRURL,
            hideDonateButton: shoudlHideDonateButton())

        let personalizedSlides = getPersonalizedSlides()
       
        if let readCountSlide = personalizedSlides.readCount {
            firstSlide = readCountSlide
        }

        if let mostReadDaySlide = personalizedSlides.mostReadDay {
            secondSlide = mostReadDaySlide
        }

        if let saveCountSlide = personalizedSlides.saveCount {
            thirdSlide = saveCountSlide
        }
        
        if let viewCountSlide = personalizedSlides.viewCount {
            fifthSlide = viewCountSlide
        }

        if let editCountSlide = personalizedSlides.editCount {
            sixthSlide = editCountSlide
        }


        var hasPersonalizedDonateSlide = false
        if let donateCountSlide = personalizedSlides.donateCount {
            sixthSlide = donateCountSlide
            hasPersonalizedDonateSlide = true
        }
       
       let slides: [YearInReviewSlideContent] = [
           firstSlide,
           secondSlide,
           thirdSlide,
           fourthSlide,
           sixthSlide
       ]

       let appShareLink = WMFYearInReviewDataController.appShareLink
       let hashtag = "#WikipediaYearInReview"

        let viewModel = WMFYearInReviewViewModel(localizedStrings: localizedStrings, slides: slides, shareLink: appShareLink, hashtag: hashtag, hasPersonalizedDonateSlide: hasPersonalizedDonateSlide, coordinatorDelegate: self, loggingDelegate: self, badgeDelegate: badgeDelegate)

        let yirview = WMFYearInReviewView(viewModel: viewModel)

        self.viewModel = viewModel
        let finalView = yirview.environmentObject(targetRects)
        let hostingController = UIHostingController(rootView: finalView)
        hostingController.modalPresentationStyle = .pageSheet

        if let sheetPresentationController = hostingController.sheetPresentationController {
            sheetPresentationController.detents = [.large()]
            sheetPresentationController.prefersGrabberVisible = false
        }

        hostingController.presentationController?.delegate = self

        (self.navigationController as? RootNavigationController)?.turnOnForcePortrait()
        navigationController.present(hostingController, animated: true, completion: nil)
    }

    private func presentSurveyIfNeeded() {
        if !self.dataController.hasPresentedYiRSurvey {
            let surveyVC = surveyViewController()
            navigationController.present(surveyVC, animated: true, completion: {
                DonateFunnel.shared.logYearInReviewSurveyDidAppear()
            })
            self.dataController.hasPresentedYiRSurvey = true
        }
    }

    private func needsLoginPrompt() -> Bool {
        return !dataStore.authenticationManager.authStateIsPermanent
    }

    private func presentLoginPrompt() {
        let title = WMFLocalizedString("year-in-review-login-title", value: "Improve your Year in Review", comment: "Title of alert that asks user to login. Displayed after they completed the feature for the first time.")
        let subtitle = WMFLocalizedString("year-in-review-login-subtitle", value: "Login or create an account to be eligible for more personalied insights", comment: "Subtitle of alert that asks user to login. Displayed after they completed the feature for the first time.")
        let button1Title = CommonStrings.joinLoginTitle
        let button2Title = CommonStrings.noThanksTitle

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        let action1 = UIAlertAction(title: button1Title, style: .default) { [weak self] action in

            guard let self else { return }

            DonateFunnel.shared.logYearInReviewLoginPromptDidTapLogin()
            let loginCoordinator = LoginCoordinator(navigationController: self.navigationController, theme: self.theme)
            loginCoordinator.start()
        }
        let action2 = UIAlertAction(title: button2Title, style: .default) { action in
            DonateFunnel.shared.logYearInReviewLoginPromptDidTapNoThanks()
        }
        alert.addAction(action1)
        alert.addAction(action2)

        DonateFunnel.shared.logYearInReviewLoginPromptDidAppear()

        navigationController.present(alert, animated: true)
    }

    private func surveyViewController() -> UIViewController {
        let title = WMFLocalizedString("year-in-review-survey-title", value: "Satisfaction survey", comment: "Year in review survey title. Survey is displayed after user has viewed the last slide of their year in review feature.")
        let subtitle = WMFLocalizedString("year-in-review-survey-subtitle", value: "Help improve the Wikipedia Year in Review. Are you satisfied with this feature? What would like to see next year?", comment: "Year in review survey subtitle. Survey is displayed after user has viewed the last slide of their year in review feature.")
        let additionalThoughts = WMFLocalizedString("year-in-review-survey-additional-thoughts", value: "Any additional thoughts?", comment: "Year in review survey placeholder for additional thoughts textfield. Survey is displayed after user has viewed the last slide of their year in review feature.")

        let verySatisfied = WMFLocalizedString("year-in-review-survey-very-satisfied", value: "Very satisfied", comment: "Year in review survey option 1 text. Survey is displayed after user has viewed the last slide of their year in review feature.")
        let satisfied = WMFLocalizedString("year-in-review-survey-satisfied", value: "Satisfied", comment: "Year in review survey option 2 text. Survey is displayed after user has viewed the last slide of their year in review feature.")
        let neutral = WMFLocalizedString("year-in-review-survey-neutral", value: "Neutral", comment: "Year in review survey option 3 text. Survey is displayed after user has viewed the last slide of their year in review feature.")
        let unsatisfied = WMFLocalizedString("year-in-review-survey-unsatisfied", value: "Unsatisfied", comment: "Year in review survey option 4 text. Survey is displayed after user has viewed the last slide of their year in review feature.")
        let veryUnsatisfied = WMFLocalizedString("year-in-review-survey-very-unsatisfied", value: "Very unsatisfied", comment: "Year in review survey option 5 text. Survey is displayed after user has viewed the last slide of their year in review feature.")

        let surveyLocalizedStrings = WMFSurveyViewModel.LocalizedStrings(
            title: title,
            cancel: CommonStrings.cancelActionTitle,
            submit: CommonStrings.surveySubmitActionTitle,
            subtitle: subtitle,
            instructions: nil,
            otherPlaceholder: additionalThoughts
        )

        let surveyOptions = [
            WMFSurveyViewModel.OptionViewModel(text: verySatisfied, apiIdentifer: "v_satisfied"),
            WMFSurveyViewModel.OptionViewModel(text: satisfied, apiIdentifer: "satisfied"),
            WMFSurveyViewModel.OptionViewModel(text: neutral, apiIdentifer: "neutral"),
            WMFSurveyViewModel.OptionViewModel(text: unsatisfied, apiIdentifer: "unsatisfied"),
            WMFSurveyViewModel.OptionViewModel(text: veryUnsatisfied, apiIdentifer: "v_unsatisfied")
        ]

        let surveyView = WMFSurveyView(viewModel: WMFSurveyViewModel(localizedStrings: surveyLocalizedStrings, options: surveyOptions, selectionType: .single), cancelAction: { [weak self] in

            self?.navigationController.dismiss(animated: true, completion: { [weak self] in
                guard let self else { return }

                if self.needsLoginPrompt() {
                    presentLoginPrompt()
                }
            })
            DonateFunnel.shared.logYearInReviewSurveyDidTapCancel()
        }, submitAction: { [weak self] options, otherText in
            DonateFunnel.shared.logYearInReviewSurveyDidSubmit(selected: options, other: otherText)
            self?.navigationController.dismiss(animated: true, completion: { [weak self] in

                guard let self else { return }

                if self.needsLoginPrompt() {
                    presentLoginPrompt()
                } else {
                    let image = UIImage(systemName: "checkmark.circle.fill")
                    WMFAlertManager.sharedInstance.showBottomAlertWithMessage(CommonStrings.feedbackSurveyToastTitle, subtitle: nil, image: image, type: .custom, customTypeName: "feedback-submitted", dismissPreviousAlerts: true)
                    DonateFunnel.shared.logYearinReviewSurveySubmitSuccessToast()
                }
            })
        })

        let hostedView = WMFComponentHostingController(rootView: surveyView)
        return hostedView
    }
}

extension YearInReviewCoordinator: WMFYearInReviewLoggingDelegate {

    func logYearInReviewSlideDidAppear(slideLoggingID: String) {
        DonateFunnel.shared.logYearInReviewSlideImpression(slideLoggingID: slideLoggingID)
    }

    func logYearInReviewDidTapDone(slideLoggingID: String) {
        DonateFunnel.shared.logYearInReviewDidTapDone(slideLoggingID: slideLoggingID)
    }

    func logYearInReviewDidTapDonate(slideLoggingID: String) {
        if let metricsID = DonateCoordinator.metricsID(for: .yearInReview, languageCode: dataStore.languageLinkController.appLanguage?.languageCode) {
            DonateFunnel.shared.logYearInReviewDidTapDonate(slideLoggingID: slideLoggingID, metricsID: metricsID)
        }
    }

    func logYearInReviewIntroDidTapContinue() {
        DonateFunnel.shared.logYearInReviewDidTapIntroContinue()
    }

    func logYearInReviewIntroDidTapLearnMore() {
        DonateFunnel.shared.logYearInReviewDidTapIntroLearnMore()
    }

    func logYearInReviewDonateDidTapLearnMore(slideLoggingID: String) {
        DonateFunnel.shared.logYearInReviewDonateSlideDidTapLearnMoreLink(slideLoggingID: slideLoggingID)
    }

    func logYearInReviewDidTapNext(slideLoggingID: String) {
        DonateFunnel.shared.logYearInReviewDidTapNext(slideLoggingID: slideLoggingID)
    }

    func logYearInReviewDidTapShare(slideLoggingID: String) {
        DonateFunnel.shared.logYearInReviewDidTapShare(slideLoggingID: slideLoggingID)
    }
}

extension YearInReviewCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        viewModel?.logYearInReviewDidTapDone()
        (self.navigationController as? RootNavigationController)?.turnOffForcePortrait()
    }
}

extension YearInReviewCoordinator: YearInReviewCoordinatorDelegate {
    func handleYearInReviewAction(_ action: WMFComponents.YearInReviewCoordinatorAction) {
        switch action {
        case .donate(let rect):
            let donateCoordinator = DonateCoordinator(navigationController: navigationController, donateButtonGlobalRect: rect, source: .yearInReview, dataStore: dataStore, theme: theme, navigationStyle: .present, setLoadingBlock: {  [weak self] loading in
                guard let self,
                      let viewModel = self.viewModel else {
                    return
                }

                viewModel.isLoading = loading
            })

            self.donateCoordinator = donateCoordinator
            donateCoordinator.start()

        case .share(let image):
            guard let viewModel else { return }
            let contentProvider = YiRShareActivityContentProvider(text: viewModel.localizedStrings.shareText, appStoreURL: viewModel.shareLink, hashtag: viewModel.hashtag)
            let imageProvider = ShareAFactActivityImageItemProvider(image: image)

            let activityItems: [Any] = [contentProvider, imageProvider]

            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityController.excludedActivityTypes = [.print, .assignToContact, .addToReadingList]

            if let visibleVC = self.navigationController.visibleViewController {
                if let popover = activityController.popoverPresentationController {
                    popover.sourceRect = visibleVC.view.bounds
                    popover.sourceView = visibleVC.view
                    popover.permittedArrowDirections = []
                }

                visibleVC.present(activityController, animated: true, completion: nil)
            }
        case .dismiss(let hasSeenTwoSlides):
            (self.navigationController as? RootNavigationController)?.turnOffForcePortrait()
            navigationController.dismiss(animated: true, completion: { [weak self] in
                guard let self else { return }

                guard hasSeenTwoSlides else { return }

                self.presentSurveyIfNeeded()
            })

        case .introLearnMore:

            guard let presentedViewController = navigationController.presentedViewController else {
                DDLogError("Unexpected navigation controller state. Skipping Learn More presentation.")
                return
            }
            var languageCodeSuffix = ""
            if let primaryAppLanguageCode = dataStore.languageLinkController.appLanguage?.languageCode {
                languageCodeSuffix = "\(primaryAppLanguageCode)"
            }
            if let url = URL(string: "https://www.mediawiki.org/wiki/Special:MyLanguage/Wikimedia_Apps/Team/iOS/Personalized_Wikipedia_Year_in_Review/How_your_data_is_used?uselang=\(languageCodeSuffix)") {
                let config = SinglePageWebViewController.StandardConfig(url: url, useSimpleNavigationBar: true)
                let webVC = SinglePageWebViewController(configType: .standard(config), theme: theme)
                let newNavigationVC = WMFThemeableNavigationController(rootViewController: webVC, theme: theme)
                newNavigationVC.modalPresentationStyle = .formSheet
                presentedViewController.present(newNavigationVC, animated: true)
            }

        case .learnMore(let url, let shouldShowDonateButton):

            guard let presentedViewController = navigationController.presentedViewController else {
                DDLogError("Unexpected navigation controller state. Skipping Learn More presentation.")
                return
            }

            let webVC: SinglePageWebViewController
            let slideLoggingID: String

            if shouldShowDonateButton {
                let config = SinglePageWebViewController.YiRLearnMoreConfig(url: url, donateButtonTitle:  WMFLocalizedString("year-in-review-donate-now", value: "Donate now", comment: "Year in review donate now button title. Displayed on top of Learn more in-app web view."))
                webVC = SinglePageWebViewController(configType: .yirLearnMore(config), theme: theme)
                slideLoggingID = "about_wikimedia_base"
            } else {
                let config = SinglePageWebViewController.StandardConfig(url: url, useSimpleNavigationBar: true)
                webVC = SinglePageWebViewController(configType: .standard(config), theme: theme)
                slideLoggingID = "about_wikimedia_custom"
            }

            let newNavigationVC = WMFThemeableNavigationController(rootViewController: webVC, theme: theme)
            newNavigationVC.modalPresentationStyle = .formSheet
            presentedViewController.present(newNavigationVC, animated: true, completion: { DonateFunnel.shared.logYearInReviewDonateSlideLearnMoreWebViewDidAppear(slideLoggingID: slideLoggingID)})
        case .info(let url):
            guard let presentedViewController = navigationController.presentedViewController else {
                DDLogError("Unexpected navigation controller state. Skipping Info presentation.")
                return
            }

            let config = SinglePageWebViewController.StandardConfig(url: url, useSimpleNavigationBar: true)
            let webVC = SinglePageWebViewController(configType: .standard(config), theme: theme)
            let newNavigationVC = WMFThemeableNavigationController(rootViewController: webVC, theme: theme)
            newNavigationVC.modalPresentationStyle = .formSheet
            presentedViewController.present(newNavigationVC, animated: true)
        }
    }
}


class YiRShareActivityContentProvider: UIActivityItemProvider, @unchecked Sendable {
    let text: String
    let appStoreURL: String
    let hashtag: String

    required init(text: String, appStoreURL: String, hashtag: String) {
        self.text = text
        self.appStoreURL = appStoreURL
        self.hashtag = hashtag
        super.init(placeholderItem: YiRShareActivityContentProvider.messageRepresentation(text: text, appStoreURL: appStoreURL, hashtag: hashtag))
    }

    override var item: Any {
        return  YiRShareActivityContentProvider.messageRepresentation(text: text, appStoreURL: appStoreURL, hashtag: hashtag)
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        switch activityType {
        case .postToFacebook:
            return nil
        default:
            if let activityType,
               activityType.rawValue.contains("instagram") {
                return nil
            }
            
            return item
        }
    }

    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return hashtag
    }

    static func messageRepresentation(text: String, appStoreURL: String, hashtag: String) -> String {
        return "\(text) (\(appStoreURL)) \(hashtag)"
    }
}
