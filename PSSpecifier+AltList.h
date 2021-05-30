@interface PSSpecifier (AltList)
- (BOOL)atl_hasValidGetter;
- (id)atl_performGetter;
- (BOOL)atl_hasValidSetter;
- (void)atl_performSetterWithValue:(id)value;
@end