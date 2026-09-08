public extension Task {
    func cancelAndWait() async {
        cancel()
        _ = try? await value
    }
}
