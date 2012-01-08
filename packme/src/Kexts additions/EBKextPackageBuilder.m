//
//  EBKextPackageBuilder.m
//  

#import "EBKextPackageBuilder.h"
#import "NSString+Utils.h"
#import "EBPackageTemplates.h"


#define EBFastRandomID [NSString stringWithFormat: @"org.packme.%@.id", [NSString randomFilenameWithLength:4 andExtension: @""]]

#ifdef __TARGET_FRAMEWORK__
	#define EBFastResource(x,y) [[NSBundle bundleWithIdentifier: @"org.eric-bro.packworks"] pathForResource: (x) ofType: (y)]
#else	
	#define EBFastResource(x,y) [[NSBundle mainBundle] pathForResource: (x) ofType: (y)]
#endif

#define EBFastEmptyFilePath EBFastResource(@"Empty", @"strings")

@implementation EBKextPackageBuilder
@synthesize destination =_destination, disabledChoiseName = _disabledChoiseName;

- (id)initWithTitle:(NSString *)title andKexts:(NSArray *)kexts
{
    if ((self = [super initWithTitle: title])) {
        _kexts = [[NSArray alloc] initWithArray: kexts];
        [self setPathToBuildUtility: kEBInternalPackageMakerSubpath];
    } else self = nil;

    return self;
}

- (void)dealloc
{
    if (_kexts)[_kexts release];
    [super dealloc];
}

- (BOOL)composePMDOCFileByPath:(NSString *)path
{
    /* Add default items (such a "Install to Bootloader" and "Install to SLE") */

    [_kexts enumerateObjectsUsingBlock:^(EBKextPackage* pkg, NSUInteger idx, BOOL *stop) {
       
        if (!pkg || [pkg isKindOfClass: NSClassFromString(@"NSNull")]) return;
        
        EBPackageBuilderItem *core_item = [[EBPackageBuilderItem alloc] initWithTitle: [[pkg sourceItem] lastPathComponent]
                                                                        andIdentifier: EBFastRandomID];
        EBPackage *core_package = [[EBPackage alloc] initWithID: [pkg identifier] 
                                                        version: [pkg version] 
                                                     sourceItem: [pkg sourceItem] 
                                                  andTargetPath: [pkg targetPath]];
        [core_item setHiddenAtLaunch: NO];
        [core_item setSelectedAtLaunch: YES];
        
        if (![core_item addPackage: core_package]) {
            /* Do something */
        }
        [core_package release];
        
        NSDictionary *pkgs_scripts = [pkg allAvailableScripts];
        
        /* -- -- -- -- -- -- -- -- -- */
        /* Extra section              */
        /* -- -- -- -- -- -- -- -- -- */
        if ( ! [_disabledChoiseName isEqualToString: @"extra"]) {
            
            EBPackageBuilderItem *extra_item = [[EBPackageBuilderItem alloc] initWithTitle: @"Install to Chameleon's Extra folder" 
                                                                             andIdentifier: EBFastRandomID];
            EBPackage *extra_scripts_package = [[EBPackage alloc] initWithID: EBFastRandomID 
                                                                     version: @"1.0" 
                                                                  sourceItem: EBFastEmptyFilePath
                                                               andTargetPath: [pkg targetPath]];
            
            
            [extra_item setSelectedAtLaunch: ([pkg destination] == kKextExtraFolderDestination)]; 
            if (pkg.type != kGeneralKextType) {
                [extra_scripts_package setScript: [pkgs_scripts valueForKey: @"Preinstall_Net_Extra"] type: kPackagePreinstallScript raw: YES];
                [extra_scripts_package setScript: [pkgs_scripts valueForKey: @"Postinstall_Net_Extra"] type: kPackagePostinstallScript raw: YES];
            } else {
                [extra_scripts_package setScript: [pkgs_scripts valueForKey: @"Postinstall_Extra"] type: kPackagePostinstallScript raw: YES];
            }
            
            [extra_item addPackage: extra_scripts_package];
            [extra_scripts_package release];
            
            [core_item addSubitem: extra_item];
            [extra_item release];
        }
        if ( ! [_disabledChoiseName isEqualToString: @"sle"]) {
            /* -- -- -- -- -- -- -- -- -- */
            /* SLE section                */
            /* -- -- -- -- -- -- -- -- -- */
            EBPackageBuilderItem *sle_item = [[EBPackageBuilderItem alloc] initWithTitle: @"Install to System/Library/Extensions" 
                                                                           andIdentifier: EBFastRandomID];
            [sle_item setSelectedAtLaunch: NO];
            EBPackage *sle_scripts_package = [[EBPackage alloc] initWithID: EBFastRandomID 
                                                                   version: @"1.0" 
                                                                sourceItem: EBFastEmptyFilePath
                                                             andTargetPath: [pkg targetPath]];
            if (pkg.type != kGeneralKextType) {
                [sle_scripts_package setScript: [pkgs_scripts valueForKey: @"Postinstall_Net_SLE"] type: kPackagePostinstallScript raw: YES];
            } else {
                [sle_scripts_package setScript: [pkgs_scripts valueForKey: @"Postinstall_SLE_"] type: kPackagePostinstallScript raw: YES];
            }
            [sle_item setSelectedAtLaunch: [pkg destination] == kKextSLEFolderDestination];
            [sle_item addPackage: sle_scripts_package];
            [sle_scripts_package release];
            [core_item addSubitem: sle_item];
            [sle_item release];
        }
        [self addItem: core_item];
        [core_item release];
        
    }];  

    return ([super composePMDOCFileByPath: path]);
}

@end
