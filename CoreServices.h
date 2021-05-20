@interface LSBundleProxy : NSObject
@property (nonatomic,readonly) NSString* bundleIdentifier;
@property (nonatomic,readonly) NSURL* bundleURL;
@end

@interface LSApplicationRecord : NSObject
@property (nonatomic,readonly) NSArray* appTags; // 'hidden'
@end

@interface LSApplicationProxy : LSBundleProxy
@property (nonatomic,readonly) NSString* localizedName;
@property (nonatomic,readonly) NSString* applicationType; // (User/System)
@property (nonatomic,readonly) NSArray* appTags; // 'hidden'
+ (instancetype)applicationProxyForIdentifier:(NSString*)identifier;
- (LSApplicationRecord*)correspondingApplicationRecord;
@end

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (NSArray<LSApplicationProxy*>*)allInstalledApplications;
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
@end