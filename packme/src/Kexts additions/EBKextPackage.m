//
//  EBKextPackage.m
//  

#import "shared_enums.h"
#import "EBKextPackage.h"
#import "Kexts_defines.h"
#import "EBPackageTemplates.h"
#import "EBTerminalCommander.h"


#define kEBKextBundleExtension          @".kext"
#define kEBBundleInfoPlistSubpath       @"/Contents/Info.plist"
#define kEBBundleExecutableSubpath      @"/Contents/MacOS"
#define kEBBundleInfoPlistVersionKey    @"CFBundleVersion"
#define kEBBundleInfoPlistIdentifierKey @"CFBundleIdentifier"
#define kEBBundleInfoPlistExecutableKey @"CFBundleExecutable"

#define kExtraFolderDestination @"/Extra/Extensions"
#define kSLEFolderDestination   @"/System/Library/Extensions"
#define kEFIFolderDestination   @"/efi/kext"

#define kEB32BitDetectorString @"i386"
#define kEB64BitDetectorString @"x86_64"


#ifdef __TARGET_FRAMEWORK__
	#define EBFastResource(x,y) [[NSBundle bundleWithIdentifier: @"org.eric-bro.packworks"] pathForResource: (x) ofType: (y)]
#else	
	#define EBFastResource(x,y) [[NSBundle mainBundle] pathForResource: (x) ofType: (y)]
#endif




@interface EBKextPackage (Private)
- (int)currentOSMinorVersion;
- (BOOL)generateScripts;
@end

@implementation EBKextPackage
@synthesize  type =_type, temporaryFolder = _tmp_folder, EFIFolder = _efi_folder, destination =_destination;

- (id)initWithKextBundle:(NSString *)bundle	
              identifier:(NSString *)identifer 
             destination:(enum EBKextDestination)target 
                    type:(enum EBKextPackageType)type 
     autogenerateScripts:(BOOL)autogen
{
    if ( ! ([[NSFileManager defaultManager] fileExistsAtPath: bundle] 
            && [bundle hasSuffix: kEBKextBundleExtension])) {
        
        return (self = nil, self);
    }
    
    NSDictionary *kexts_info_plist = [NSDictionary dictionaryWithContentsOfFile: 
                                      [bundle stringByAppendingPathComponent: kEBBundleInfoPlistSubpath]];
    
    if (self = [super initWithID: [kexts_info_plist valueForKey: kEBBundleInfoPlistIdentifierKey] 
                         version: [kexts_info_plist valueForKey: kEBBundleInfoPlistVersionKey]  
                      sourceItem: bundle 
                   andTargetPath: target==kKextExtraFolderDestination ? kExtraFolderDestination : kSLEFolderDestination]) {
        
        _destination = target;
        /* Check binary bit depth */
        NSString *binary_file_path = [bundle stringByAppendingPathComponent:
                                      [NSString stringWithFormat:@"%@/%@", 
                                       kEBBundleExecutableSubpath, 
                                       [kexts_info_plist valueForKey: kEBBundleInfoPlistExecutableKey]]];
        NSString *output = [EBTerminalCommander runBinaryFile: @"/usr/bin/file"
                                                withArguments: [NSArray arrayWithObject: binary_file_path] 
                                                  asSuperuser: NO];
        _bit_depth_flags = 0;
        if ([output rangeOfString: kEB32BitDetectorString].location != NSNotFound) {
            _bit_depth_flags = kKext32Bit;
        }
        if ([output rangeOfString: kEB64BitDetectorString].location != NSNotFound) {
            _bit_depth_flags |= kKext64Bit;
        }
        
        [self setTemporaryFolder: kEBKextPackageDefaultTargetPath];
        [self setEFIFolder: kEFIFolderDestination];
        _type = type;
        
        if (autogen) {
            [self generateScripts];
        }
    } else {
        self = nil;
    }
    
    return self;
}


- (NSArray *)currentScripts
{
    if (self.rawPreinstallScript && self.rawPostInstallScript) {
        return [NSArray arrayWithObjects: self.preinstallScriptFile, self.postinstallScriptFile, nil];
    }
    
    NSDictionary *all_avaliable = [self allAvailableScripts];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (_type == kEthernetKextType || _type == kWirelessKextType) {
        if (self.destination == kKextExtraFolderDestination) {
            [result addObject: [all_avaliable valueForKey: @"Preinstall_Net_Extra"]];
            [result addObject: [all_avaliable valueForKey: @"Postinstall_Net_Extra"]];
        } else {
            [result addObject: [all_avaliable valueForKey: @"Postinstall_Net_SLE"]];
        }
    }
    if (self.destination == kKextExtraFolderDestination) {
        [result addObject: [all_avaliable valueForKey: @"Postinstall_Extra_EFI_"]];
    } else if (self.destination == kKextSLEFolderDestination) {
        [result addObject: [all_avaliable valueForKey: @"Postinstall_SLE_"]];
    }
    return ([result autorelease]);

}


- (NSDictionary *)allAvailableScripts
{
    NSString *bundle_name = [[self sourceItem] lastPathComponent];
    if (!bundle_name) return nil;
    
    NSMutableDictionary *result_dictionary = [[NSMutableDictionary alloc] initWithCapacity: 4];
        
    NSArray *all_raws_paths = [NSArray arrayWithObjects: 
                               EBFastResource(@"Postinstall_Net_Extra",@"sh"),
                               EBFastResource(@"Postinstall_Net_SLE",@"sh"),
                               EBFastResource(@"Postinstall_Extra_EFI_", @"sh"),
                               EBFastResource(@"Postinstall_SLE_", @"sh"),
                               EBFastResource(@"Preinstall_Net_Extra", @"sh"), nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [all_raws_paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        [dict removeAllObjects];
        NSString *tmp_str = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: NULL];
        [dict setValue: bundle_name forKey: packme_kexts_keys_kext_bundle_name];
        if (self.type == kEthernetKextType) {
            [dict setValue: packme_kexts_defaults_ethernet_root_kext_name forKey: packme_kexts_keys_root_kext_name];
        } else if (self.type == kWirelessKextType) {
            [dict setValue: packme_kexts_defaults_wireless_root_kext_name forKey: packme_kexts_keys_root_kext_name];
        } else {
            [dict setValue: @"" forKey: packme_kexts_keys_root_kext_name];
        }
        [dict setValue: self.temporaryFolder forKey: packme_kexts_keys_temporary_folder_name];
        [dict setValue: self.EFIFolder       forKey: packme_kexts_keys_efi_folder_name];
        [result_dictionary setValue: [EBPackageTemplates setValuesFromDictionary: dict inTemplate: tmp_str] 
                             forKey: [[path lastPathComponent] stringByDeletingPathExtension]];
    }];
    [dict release];
    return [(result_dictionary) autorelease];
}

- (BOOL)generateScripts
{
    
    NSArray *all_scripts = [self currentScripts];
    if (!all_scripts || [all_scripts count] == 0) return NO;
    
    if ([all_scripts count] > 1) {
        return ([self setScript: [all_scripts objectAtIndex: 0] type: kPackagePreinstallScript raw: YES] 
                &&
                [self setScript: [all_scripts objectAtIndex: 1] type: kPackagePostinstallScript raw: YES]);
    } else {
        return  [self setScript: [all_scripts objectAtIndex: 0] type: kPackagePostinstallScript raw: YES];
    }
}




static SInt32 current_minor_os = -1;

- (int)currentOSMinorVersion
{
    if (-1 == current_minor_os) {
       Gestalt(gestaltSystemVersionMinor, &current_minor_os); 
    }
    return  (int)current_minor_os;
}
@end
