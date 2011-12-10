//
//  EBPackageMakerItem.m
//  

#import "EBPackageBuilderItem.h"
#import "EBPackage.h"

@implementation EBPackageBuilderItem

@synthesize  packages = _packages, title = _title, description = _description;
@synthesize  identifier = _identifier, enabledAtLaunch = _enabled_at_launch;
@synthesize  selectedAtLaunch = _selected_at_launch, hiddenAtLaunch = _hidden_at_launch;
@synthesize  subitems = _subitems;


- (id)init
{
    return nil;
}

- (id)initWithTitle:(NSString *)title andIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
        _packages = [[NSMutableArray alloc] init];
        _subitems = [[NSMutableArray alloc] init];
        [self setTitle: title ? title : @"tmppkgTitle"];
        [self setIdentifier: identifier];
        [self setDescription: nil];
        _enabled_at_launch = _selected_at_launch = YES;
        _hidden_at_launch = NO;
    } else self = nil;
    
    return self;
}

- (void)dealloc
{
    [_packages release];
    [_subitems release];
    [super dealloc];
}

- (BOOL)addPackage:(EBPackage *)package
{
    if ([_packages containsObject: package]) return NO;
    BOOL file_exists = [[NSFileManager defaultManager] fileExistsAtPath: [package sourceItem]];
    return file_exists ? ([_packages addObject:package], YES) : NO;
}

- (BOOL)addSubitem:(EBPackageBuilderItem *)subitem
{
    if ([_subitems containsObject: subitem]) return NO;
    return (subitem ? ([_subitems addObject: subitem], YES) : NO);
}

- (void)removePackage:(EBPackage *)package
{
    [_packages removeObject: package];
}

- (EBPackage *)packageWithID:(NSString *)idx
{
    __block EBPackage *return_value = nil;
#if NS_BLOCKS_AVAILABLE
    [_packages enumerateObjectsUsingBlock:^(id pkg, NSUInteger number, BOOL *stop) {
#else
    for (id pkg in _packages) {
#endif
        if ([[(EBPackage*)pkg identifier] isEqualToString: idx]) {
            return_value = [pkg retain];
        }
#if NS_BLOCKS_AVAILABLE
    }];
#else
    }
#endif
     return (return_value);
}
     
    

@end
