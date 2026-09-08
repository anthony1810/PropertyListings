import Foundation
import ListingsFeature
import ListingsPresentation
import ListingsTestSupport
import SharedPresentation
import Testing

@Suite struct ListingRowMapperTests {
    private let locale = Locale(identifier: "de_CH")

    @Test func map_formatsPriceAndAddressAndKeepsIdentityAndImage() {
        let listing = makeListing(id: "42", title: "Haus am See", imageURL: anyImageURL)

        let row = ListingRowMapper.map(listing, isBookmarked: false, locale: locale)

        #expect(row == ListingRow(
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
            imageURL: anyImageURL,
            isBookmarked: false
        ))
    }

    @Test func map_formatsMissingPriceAsOnRequest() {
        let listing = makeListing(price: nil)

        let row = ListingRowMapper.map(listing, isBookmarked: false, locale: locale)

        #expect(row.priceText == PriceFormatter.text(amount: nil, currency: nil, locale: locale))
    }

    @Test(arguments: [true, false])
    func map_passesBookmarkStateThrough(isBookmarked: Bool) {
        let row = ListingRowMapper.map(makeListing(), isBookmarked: isBookmarked, locale: locale)

        #expect(row.isBookmarked == isBookmarked)
    }

    // MARK: - Helpers

    private let anyImageURL = URL(string: "https://a-url.com/image.jpg")
}
