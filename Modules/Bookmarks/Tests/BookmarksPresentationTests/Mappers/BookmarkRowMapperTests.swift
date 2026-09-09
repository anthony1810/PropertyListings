import BookmarksFeature
import BookmarksPresentation
import BookmarksTestSupport
import Foundation
import SharedPresentation
import Testing

@Suite struct BookmarkRowMapperTests {
    private let locale = Locale(identifier: "de_CH")

    @Test func map_formatsPriceAndAddressAndKeepsIdentityAndImage() {
        let bookmark = makeBookmark(id: "42", title: "Haus am See", imageURL: anyImageURL)

        let row = BookmarkRowMapper.map(bookmark, locale: locale)

        #expect(row == BookmarkRow(
            id: "42",
            title: "Haus am See",
            priceText: PriceFormatter.text(
                amount: 1_000,
                currency: "CHF",
                locale: locale
            ),
            addressText: AddressFormatter.text(
                street: "A street",
                postalCode: "8000",
                locality: "A locality"
            ),
            imageURL: anyImageURL
        ))
    }

    @Test func map_formatsMissingPriceAsOnRequest() {
        let bookmark = makeBookmark(price: nil)

        let row = BookmarkRowMapper.map(bookmark, locale: locale)

        #expect(row.priceText == PriceFormatter.text(amount: nil, currency: nil, locale: locale))
    }

    // MARK: - Helpers

    private let anyImageURL = URL(string: "https://a-url.com/image.jpg")
}
