import Foundation
import Testing
@testable import SharedPresentation

@Suite struct AddressFormatterTests {
    @Test func text_fullAddress_joinsStreetAndCityLine() {
        #expect(AddressFormatter.text(street: "Musterstrasse 999", postalCode: "2406", locality: "La Brévine") == "Musterstrasse 999, 2406 La Brévine")
    }

    @Test func text_withoutStreet_showsPostalCodeAndLocality() {
        #expect(AddressFormatter.text(street: nil, postalCode: "2406", locality: "La Brévine") == "2406 La Brévine")
    }

    @Test func text_withoutPostalCode_showsStreetAndLocality() {
        #expect(AddressFormatter.text(street: "Musterstrasse 999", postalCode: nil, locality: "La Brévine") == "Musterstrasse 999, La Brévine")
    }

    @Test func text_withLocalityOnly_showsLocality() {
        #expect(AddressFormatter.text(street: nil, postalCode: nil, locality: "La Brévine") == "La Brévine")
    }

    @Test func text_treatsBlankStreetAsMissing() {
        #expect(AddressFormatter.text(street: "  ", postalCode: "2406", locality: "La Brévine") == "2406 La Brévine")
    }
}
