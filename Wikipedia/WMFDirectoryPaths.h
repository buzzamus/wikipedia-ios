
@import Foundation;

#ifndef WMFDirectoryPaths_h
#define WMFDirectoryPaths_h


#endif /* WMFDirectoryPaths_h */

static inline NSString* documentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

static inline NSString* cachesDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

static inline NSString* tempDirectory() {
    return NSTemporaryDirectory();
}

