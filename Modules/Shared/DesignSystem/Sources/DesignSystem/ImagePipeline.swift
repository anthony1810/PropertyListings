import Foundation
import Kingfisher

public enum ImagePipeline {
    public static func configure(memoryLimitMB: Int = 64, diskLimitMB: Int = 256, diskExpiryDays: Int = 30) {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = memoryLimitMB * 1024 * 1024
        cache.diskStorage.config.sizeLimit = UInt(diskLimitMB) * 1024 * 1024
        cache.diskStorage.config.expiration = .days(diskExpiryDays)
        KingfisherManager.shared.downloader.downloadTimeout = 15
    }
}
