//
//  EBKextPackage.h
//  

#import "EBPackage.h"
#define kEBCurrentMacOSVersion (1 << 2)
#define kEBKextPackageDefaultTargetPath @"/usr/rox/tmp"

/* -- -- -- -- -- -- -- -- -- -- */
enum EBKextBitDepth {
    kKext32Bit = 0x1,
    kKext64Bit = 0x2
}EBKextBitDepth;

enum EBKextDestination {
    kKextExtraFolderDestination = 0x1,
    kKextSLEFolderDestination   = 0x2
}EBKextDestination;

enum EBKextPackageType {
    kGeneralKextType  = 0x1,
    kEthernetKextType = 0x2,
    kWirelessKextType = 0x3
}EBKextPackageType;
/* -- -- -- -- -- -- -- -- -- -- */

@interface EBKextPackage : EBPackage
{
@protected
    NSString *_tmp_folder, *_efi_folder;
    enum EBKextPackageType _type;
    enum EBKextBitDepth _bit_depth_flags;
    enum EBKextDestination _destination;
}
@property (nonatomic, retain) NSString *temporaryFolder;
@property (nonatomic, retain) NSString *EFIFolder;
@property enum EBKextDestination destination;
@property enum EBKextPackageType type;


- (id)initWithKextBundle:(NSString *)bundle	
              identifier:(NSString *)identifer 
             destination:(enum EBKextDestination)target 
                    type:(enum EBKextPackageType)type 
     autogenerateScripts:(BOOL)autogen;

- (NSArray *)currentScripts;
- (NSDictionary *)allAvailableScripts;


/* -- -- -- DEPRECATED -- -- -- - */
- (id)initWithTitle:(NSString *)title andIdentifier:(NSString *)identifier             DEPRECATED_ATTRIBUTE;
- (id)initWithID:(NSString *)identifier version:(NSString *)version sourceItem:(NSString *)source_path andTargetPath:(NSString *)target_path DEPRECATED_ATTRIBUTE;
- (BOOL)setScript:(NSString *)script type:(enum EBPackageScriptType)type raw:(BOOL)raw DEPRECATED_ATTRIBUTE;
/* -- -- -- -- -- -- -- -- -- -- */
@end
