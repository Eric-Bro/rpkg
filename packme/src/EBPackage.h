//
//  EBPackage.h
//  

#import <Foundation/Foundation.h>
#import "shared_enums.h"

@interface EBPackage : NSObject
{
@protected
    NSString *_identifier, *_version;
    NSString *_target_path, *_source_path;
    BOOL _require_authorization, _include_containing_folder;
    NSString *_preinstall_script_file, *_postinstall_script_file;
    NSString *_raw_preinstall_script, *_raw_postinstall_script;
}
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *targetPath;
@property (nonatomic, retain) NSString *sourceItem;
@property (nonatomic, retain) NSString *preinstallScriptFile;
@property (nonatomic, retain) NSString *postinstallScriptFile;
@property (nonatomic, retain) NSString *rawPreinstallScript;
@property (nonatomic, retain) NSString *rawPostInstallScript;
@property BOOL requireAuthorizationWhileInstallation;
@property BOOL shouldIncludeContainigFolder;

- (id)init DEPRECATED_ATTRIBUTE;
- (id)initWithID:(NSString *)identifier version:(NSString *)version sourceItem:(NSString *)source_path andTargetPath:(NSString *)target_path;
- (BOOL)setScript:(NSString *)script type:(enum EBPackageScriptType)type raw:(BOOL)raw;
@end
