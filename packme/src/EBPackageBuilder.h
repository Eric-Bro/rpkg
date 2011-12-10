//
//  EBPackageBuilder.h
//  

#import <Foundation/Foundation.h>
#import "EBPackageBuilderItem.h"
#import "EBPackageBuilderLocale.h"
#import "shared_enums.h"

#define kOrganizationID @"org.eric_bro"

/* Alignement types */
#define kEBLocaleAlignementCenterType   @"center"
#define kEBLocaleAlignementTopType      @"top"
#define kEBLocaleAlignementTopLeftType  @"topleft"
#define kEBLocaleAlignementTopRightType @"topright"
#define kEBLocaleAlignementLeftType     @"left"
#define kEBLocaleAlignementBottomType   @"bottom"
#define kEBLocaleAlignementBottomLeft   @"bottomleft"
#define kEBLocaleAlignementBottomRight  @"bottomright"
#define kEBLocaleAlignementRight        @"right"
/* Scale types */
#define kEBLocaleScalingToFitType @"tofit"
#define kEBLocaleScalingNoneType  @"none"
#define kEBLocaleScalingProportional @"proportional"


@interface EBPackageBuilder : NSObject
{
@protected
    NSMutableArray *_items, *_locales;
    NSString *_path_to_packagemaker_utility;
    NSString *_title, *_organization_id, *_background_file;
    NSString *_background_align, *_background_scale;
    enum EBPackageUIMode _ui_mode;
    enum EBPackageMinimumRequiredOS _minimum_target_os;
    enum EBPackageDomainFlag _domain_flags;
    NSMutableArray *_filenames, *_tmp_files;
    NSString *_tmp_folder, *_last_pmdoc_file;
}
@property (nonatomic, copy) NSMutableArray *items;
@property (nonatomic, copy) NSMutableArray *locales;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *backgroundImageFile;
@property (nonatomic, retain) NSString *organizationIdentifier;
@property (nonatomic, retain) NSString *backgroundAlignMode;
@property (nonatomic, retain) NSString *backgroundScaleMode;
@property (nonatomic, retain) NSString *pathToBuildUtility;
@property (nonatomic, readonly) NSString *lastCreatedPMDOCFile;
@property enum EBPackageUIMode UIMode;
@property enum EBPackageMinimumRequiredOS minimumReqiuredOS;
@property enum EBPackageDomainFlag installationDomainFlags;

- (id)initWithTitle:(NSString *)title;
+ (id)builderWithTitle:(NSString *)title;

- (BOOL)addItem:(EBPackageBuilderItem *)item;
- (BOOL)addLocale:(EBPackageBuilderLocale *)locale;

- (BOOL)composePMDOCFileByPath:(NSString *)path;
- (BOOL)buildPackageByPath:(NSString *)path usingPMDOCFile:(NSString *)pmdoc;

- (void)reset;
@end
