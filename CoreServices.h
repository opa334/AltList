#import <MobileCoreServices/LSApplicationProxy.h>
#import <MobileCoreServices/LSApplicationWorkspace.h>

@interface LSBundleProxy (Additions)
@property (nonatomic,readonly) BOOL if_isSystem;
@end

@interface LSApplicationRecord : NSObject
@property (nonatomic,readonly) NSArray* appTags; // 'hidden'
@end

@interface LSApplicationProxy (Additions)
@property (nonatomic,readonly) NSString* localizedName;
@property (nonatomic,readonly) NSString* applicationType; // (User/System)
@property (nonatomic,readonly) NSArray* appTags; // 'hidden'
+ (instancetype)applicationProxyForIdentifier:(NSString*)identifier;
- (LSApplicationRecord*)correspondingApplicationRecord;
@end

@interface LSApplicationWorkspace (Additions)
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
@end