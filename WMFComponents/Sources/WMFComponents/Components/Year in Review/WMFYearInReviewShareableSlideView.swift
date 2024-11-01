import SwiftUI

struct WMFYearInReviewShareableSlideView: View {

    @ObservedObject var appEnvironment = WMFAppEnvironment.current

    var theme: WMFTheme {
        return appEnvironment.theme
    }

    var slide: Int
    var slideImage: String
    var slideTitle: String
    var slideSubtitle: String
    var hashtag: String
    var username: String?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    Image("W-share-logo", bundle: .module)
                        .frame(height: 70)
                        .frame(maxWidth: .infinity)

                    Image(slideImage, bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(slideTitle)
                        .font(Font(WMFFont.for(.boldTitle1, compatibleWith: UITraitCollection(preferredContentSizeCategory: .medium))))
                        .foregroundStyle(Color(uiColor: theme.text))
                    Text(slideSubtitle)
                        .font(Font(WMFFont.for(.title3, compatibleWith: UITraitCollection(preferredContentSizeCategory: .medium))))
                        .foregroundStyle(Color(uiColor: theme.text))
                }
                .padding(.top, 10)
                .padding(.horizontal, 28)

                Spacer(minLength: 10)

                HStack {
                    Image("globe", bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text(hashtag)
                            .font(Font(WMFFont.for(.boldTitle3, compatibleWith: UITraitCollection(preferredContentSizeCategory: .medium))))
                            .foregroundStyle(Color(uiColor: theme.link))

                        if let username {
                            Text(username)
                                .font(Font(WMFFont.for(.georgiaTitle3, compatibleWith: UITraitCollection(preferredContentSizeCategory: .medium))))
                                .foregroundStyle(Color(uiColor: theme.text))
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(uiColor: theme.paperBackground))
                .cornerRadius(12)
                .shadow(color: Color.gray.opacity(0.4), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .frame(height: 80)
                .padding(.bottom, 60)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(uiColor: theme.paperBackground))
        }
        .frame(width: 402, height: 847)
    }
}
