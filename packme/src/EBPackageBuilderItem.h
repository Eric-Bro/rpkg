//
//  EBPackageMakerItem.h
//  

#import <Foundation/Foundation.h>
@class EBPackage;

@interface EBPackageBuilderItem : NSObject
{
@protected
    NSString *_title;
    NSString *_identifier;
    NSString *_description;
    BOOL _enabled_at_launch;
    BOOL _selected_at_launch;
    BOOL _hidden_at_launch;
    NSMutableArray *_packages;
    NSMutableArray *_subitems;
}
@property (nonatomic, copy) NSMutableArray *packages;
@property (nonatomic, copy) NSMutableArray *subitems;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *description;
@property BOOL enabledAtLaunch;
@property BOOL selectedAtLaunch;
@property BOOL hiddenAtLaunch;


- (id)init DEPRECATED_ATTRIBUTE;
- (id)initWithTitle:(NSString *)title andIdentifier:(NSString *)identifier;

- (BOOL)addSubitem:(EBPackageBuilderItem *)subitem;
- (BOOL)addPackage:(EBPackage *)package;
- (void)removePackage:(EBPackage *)package;
- (EBPackage *)packageWithID:(NSString *)idx;
@end
