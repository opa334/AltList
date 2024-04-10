@interface PSSpecifier (AltList)
- (BOOL)atl_hasValidGetter;
- (id)atl_performGetter;
- (BOOL)atl_hasValidSetter;
- (void)atl_performSetterWithValue:(id)value;
@end

@interface PSSpecifier (Private)
- (id)userInfo;
- (void)setUserInfo:(id)arg1;
@end