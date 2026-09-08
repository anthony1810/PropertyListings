import ListingsAPI
import Testing

@Suite struct ListingsPageTests {
    @Test func nextFrom_isTheOffsetAfterThisPageWhenMoreItemsExist() {
        let page = makePage(from: 0, size: 5, total: 12, maxFrom: 10)

        #expect(page.nextFrom == 5)
    }

    @Test func nextFrom_isNilWhenThisPageReachesTheTotal() {
        let page = makePage(from: 5, size: 5, total: 9, maxFrom: 5)

        #expect(page.nextFrom == nil)
    }

    @Test func nextFrom_isNilWhenTheServerServesNoFurtherOffset() {
        let page = makePage(from: 10, size: 5, total: 100, maxFrom: 10)

        #expect(page.nextFrom == nil)
    }

    @Test func nextFrom_isNilForTheSinglePagePayload() {
        let page = makePage(from: 0, size: 100, total: 9, maxFrom: 0)

        #expect(page.nextFrom == nil)
    }

    // MARK: - Helpers

    private func makePage(from: Int, size: Int, total: Int, maxFrom: Int) -> ListingsPage {
        ListingsPage(listings: [], from: from, size: size, total: total, maxFrom: maxFrom)
    }
}
