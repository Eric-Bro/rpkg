//
//  EBPackage.m
//  

#import "EBPackage.h"
#import "EBTerminalCommander.h"
#import "shared_enums.h"

static const NSString *kExecutableScriptFileKey   = @"shell script text executable";

@interface EBPackage (Private)

@end

@implementation EBPackage
@synthesize version = _version, identifier = _identifier, targetPath = _target_path; 
@synthesize sourceItem = _source_path, preinstallScriptFile = _preinstall_script_file;
@synthesize postinstallScriptFile = _postinstall_script_file, requireAuthorizationWhileInstallation = _require_authorization;
@synthesize shouldIncludeContainigFolder = _include_containing_folder, rawPreinstallScript = _raw_preinstall_script;
@synthesize rawPostInstallScript = _raw_postinstall_script;


- (id)init
{
    return nil;
}

- (id)initWithID:(NSString *)identifier version:(NSString *)version sourceItem:(NSString *)source_path andTargetPath:(NSString *)target_path
{
    
    if ((self = [super init]) && identifier && source_path && target_path) {
        [self setIdentifier: identifier];
        [self setVersion: version ? version : @"1.0"];
        [self setSourceItem: [source_path stringByExpandingTildeInPath]];
        [self setTargetPath: [target_path stringByExpandingTildeInPath]];
        _postinstall_script_file = nil, _preinstall_script_file = nil;
        _raw_preinstall_script = nil, _raw_postinstall_script = nil;
        _require_authorization = NO, _include_containing_folder = YES;
    } else self = nil;
    
    return self;
}

- (BOOL)setScript:(NSString *)script type:(enum EBPackageScriptType)type raw:(BOOL)raw
{
    if (!script) return NO;
    if (raw) {
        return (type == kPackagePreinstallScript ? ([self setRawPreinstallScript: script], YES) 
                                                 : ([self setRawPostInstallScript: script], YES));
    } else {
        script = [script stringByExpandingTildeInPath];
        NSString *file_information = [EBTerminalCommander runBinaryFile: @"/usr/bin/file" withArguments: [NSArray arrayWithObject: script] asSuperuser: NO];
        if ([file_information rangeOfString: (NSString *)kExecutableScriptFileKey].location != NSNotFound) {
            return (type == kPackagePreinstallScript ?  ([self setPreinstallScriptFile: script], YES) 
                                                     :  ([self setPostinstallScriptFile: script], YES));
        } else {
            return NO;
        }
    }
}
@end
