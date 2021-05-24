@interface PSSpecifier : NSObject
{
@public
    id target;
    SEL getter;
    SEL setter;
}
- (BOOL)hasValidGetter;
- (id)performGetter;
- (BOOL)hasValidSetter;
- (void)performSetterWithValue:(id)value;
@end
