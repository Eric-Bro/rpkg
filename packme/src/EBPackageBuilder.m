//
//  EBPackageBuilder.m
//  

#import "EBTerminalCommander.h"
#import "EBPackage.h"
#import "EBPackageBuilderItem.h"
#import "EBPackageBuilderLocale.h"
#import "EBPackageBuilder.h"
#import "EBPackageTemplates_defines.h"
#import "EBPackageTemplates.h"
#import "NSString+Utils.h"
#import "NSArray+Mapping.h"

#define kDefaultBuilderUtilityPath [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources/PackageMaker.app/Contents/MacOS/PackageMaker"]


#define bool2number(x) [NSNumber numberWithBool:(x)]
#define number2bool(x) [(x) boolValue]
#define bool2string(x) ((x)) ? @"true" : @"false"

@interface EBPackageBuilder (Private)
- (void)createTemporaryFolder;
- (void)cleanupWithPMDOCFilepath:(NSString *)pmdoc_path;
- (NSString *)createScriptFromRaw:(NSString *)raw_script;
+ (NSString *)infoFilenameFromID:(NSString *)idx andIndex:(NSInteger)index;

- (NSString *)composeFilesSection;
- (NSString *)composeChoiseSection;

- (void)createInfoFilesForAllPackagesInItem:(EBPackageBuilderItem *)item andTargetPath:(NSString *)path;
+ (NSString *)choiseSectionForItem:(EBPackageBuilderItem *)item;
+ (NSDictionary *)preferencesForItem:(EBPackageBuilderItem *)item;
- (NSArray *)fileSectionForItem:(EBPackageBuilderItem *)item totalCount:(NSInteger)tcount;

@end

@implementation EBPackageBuilder
@synthesize items = _items, title =_title, organizationIdentifier = _organization_id; 
@synthesize pathToBuildUtility = _path_to_packagemaker_utility, UIMode = _ui_mode, installationDomainFlags = _domain_flags;
@synthesize minimumReqiuredOS =_minimum_target_os, locales = _locales, backgroundImageFile = _background_file;
@synthesize backgroundAlignMode = _background_align, backgroundScaleMode = _background_scale;
@synthesize lastCreatedPMDOCFile = _last_pmdoc_file;

+ (id)builderWithTitle:(NSString *)title
{
    return [[[[self class] alloc] initWithTitle: title] autorelease];
}

- (id)initWithTitle:(NSString *)title
{
    if ((self = [super init]) && title) {
        _items = [[NSMutableArray alloc] init];
        _filenames = [[NSMutableArray alloc] init];
        _locales = [[NSMutableArray alloc] init];
        [self setTitle: title];
        [self setPathToBuildUtility: kDefaultBuilderUtilityPath];
        [self setOrganizationIdentifier: kOrganizationID];
        _ui_mode = kPackageUIModeCustom;
        _minimum_target_os = kPackageMinimumRequired105;
        _domain_flags = kPackageDomainAnywhereFlag;
        _tmp_files = [[NSMutableArray alloc] init];
        _tmp_folder = nil;
        _background_align = kEBLocaleAlignementTopLeftType;
        _background_scale = kEBLocaleScalingNoneType;
        _last_pmdoc_file = nil;
        [self createTemporaryFolder];
    } else self = nil;
    
    return self;
}

- (void)dealloc
{
    [_items release], [_tmp_files release];
    [_locales release], [_filenames release];
    [super dealloc];
}

- (void)reset
{
    
}


- (BOOL)addItem:(EBPackageBuilderItem *)item
{
    return (!item || ![[item packages] count] ? NO : ([_items addObject: item], YES));
}

- (BOOL)addLocale:(EBPackageBuilderLocale *)locale
{
    return (!locale || [locale isEmpty] ? NO : ([_locales addObject: locale], YES));
}

+ (NSString *)infoFilenameFromID:(NSString *)idx andIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"%.3i%@.xml",index, [idx stringByDeletingPathExtension]];
}


- (BOOL)buildPackageByPath:(NSString *)path usingPMDOCFile:(NSString *)pmdoc;
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ( ! [file_manager fileExistsAtPath: [self pathToBuildUtility]]) {
        NSLog(@"ERR0R: Unable to find the PackageBuilder binary file");
        return NO;
    }
    pmdoc = [pmdoc stringByExpandingTildeInPath];
    path  = [path  stringByExpandingTildeInPath];
    
    if (!_tmp_folder) [self createTemporaryFolder];
    NSString *pmdoc_file_path = nil;
    if (!pmdoc || ![file_manager fileExistsAtPath: pmdoc]) {
        pmdoc_file_path = [NSString stringWithString: [_tmp_folder stringByAppendingPathComponent: 
                                                       [NSString randomFilenameWithLength: 4 andExtension:@"pmdoc"]]];
        if ( ! [self composePMDOCFileByPath: pmdoc_file_path]) {
            NSLog(@"ERR0R: Unable to create a .pmdoc file by path '%@'", pmdoc_file_path);
            [self cleanupWithPMDOCFilepath: pmdoc_file_path];
            return NO;
        }
    } else {
        pmdoc_file_path = [NSString stringWithString: pmdoc];
    }
    
    path = [path stringByExpandingTildeInPath];
    /* Check if we need to get the root access to create a pkg file at this path */
    /* TODO: check a folder's access rigths instead of it's location */
    BOOL root_required = !([path hasPrefix: [NSString stringWithFormat: @"/Users/", NSUserName()]]);
    [EBTerminalCommander runBinaryFile: [self pathToBuildUtility] 
                         withArguments: [NSArray arrayWithObjects: @"--doc", pmdoc_file_path, @"--out", path, nil] 
                           asSuperuser: root_required];
    if ( ! [file_manager fileExistsAtPath: path]) {
        NSLog(@"ERR0R: Unable to create the pkg file at path '%@'", path);
        [self cleanupWithPMDOCFilepath: pmdoc_file_path];
        return NO;
    }
    
    
    [self cleanupWithPMDOCFilepath: pmdoc_file_path];
    return YES;
}

/* Some cleanup work */
- (void)cleanupWithPMDOCFilepath:(NSString *)pmdoc_path
{
    __block NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath: pmdoc_path error: &error];
    if (error) {
        NSLog(@"ERR0R: Unable to remove temp .pmdoc file '%@' - %@", pmdoc_path, [error localizedDescription]);
    }
    error = nil;
    [[NSFileManager defaultManager] removeItemAtPath: _tmp_folder error: &error];
    if (error) {
        NSLog(@"ERR0R: Unable to remove the main temp directory of packme lib '%@' = %@", _tmp_folder,
              [error localizedDescription]);
    }
    [_filenames removeAllObjects];
    [_tmp_files removeAllObjects];
}

- (BOOL)composePMDOCFileByPath:(NSString *)path
{
    __block NSError *error = nil;
    path = [path stringByExpandingTildeInPath];
    if ( ! [[path lastPathComponent] isEqualToString: @"pmdoc"]) {
        path = [path stringByAppendingPathExtension: @"pmdoc"];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath: path withIntermediateDirectories: YES attributes: nil error:&error];
    if (error) {
        NSLog(@"ERR0R: %@", [error localizedDescription]);
        return NO;
    }
    NSMutableDictionary *index_file_dict = [[NSMutableDictionary alloc] init];
    [index_file_dict setValue: [self title] forKey: packme_index_keys_title];
    [index_file_dict setValue: @""          forKey: packme_index_keys_target];
    [index_file_dict setValue: [self organizationIdentifier] forKey: packme_index_keys_organization];
    [index_file_dict setValue: [NSString stringWithFormat:@"%i", self.minimumReqiuredOS] 
                       forKey: packme_index_keys_min_target_os];
    switch ((int)_ui_mode) {
        case kPackageUIModeEasy: 
            [index_file_dict setValue: packme_index_templates_ui_mode_easy forKey: packme_index_keys_ui_mode];
            break;
        case kPackageUIModeCustom:
            [index_file_dict setValue: packme_index_templates_ui_mode_custom forKey: packme_index_keys_ui_mode];
            break;
        case kPackageUIModeBoth:
            [index_file_dict setValue: packme_index_templates_ui_mode_both forKey: packme_index_keys_ui_mode];
            break;
    }

    [index_file_dict setValue: [EBPackageTemplates resouresSectionWithLocales: _locales
                                                               backgroundFile: _background_file
                                                              backgroundScale: _background_scale 
                                                                     andAlign: _background_align] 
                       forKey: packme_index_keys_resources_section];
    [index_file_dict setValue:[NSNumber numberWithInt:_domain_flags] forKey: packme_index_keys_domain_flags];
    [index_file_dict setValue: [self composeChoiseSection] forKey: packme_index_keys_choise_section];
    [index_file_dict setValue: [self composeFilesSection]  forKey: packme_index_keys_files_section];
    NSMutableString *allMods = [NSMutableString stringWithFormat:@"<mod>properties.title</mod>%@",
                                [EBPackageTemplates modsSectionWithDomainFlags: _domain_flags]] ;

    if (self.UIMode == kPackageUIModeCustom || self.UIMode == kPackageUIModeBoth) {
        [allMods appendString: @"<mod>properties.customizeOption</mod>"];
    }
    [index_file_dict setValue: allMods
                       forKey: packme_index_keys_mods];
    error = nil;
    [[EBPackageTemplates indexFileWithParameters: index_file_dict] writeToFile: [path stringByAppendingPathComponent: @"index.xml"] 
                                                                    atomically: YES 
                                                                      encoding: NSUTF8StringEncoding 
                                                                          error: &error];
    [index_file_dict release];
    if (error) {
        NSLog(@"ERR0R: %@", [error localizedDescription]);
        return NO;
    }
    @try {
        [_items enumerateObjectsUsingBlock:^(EBPackageBuilderItem *item, NSUInteger idx, BOOL *stop) {
            [self createInfoFilesForAllPackagesInItem: item andTargetPath: path];
            [[item subitems] enumerateObjectsUsingBlock:^(EBPackageBuilderItem *subitem, NSUInteger idx, BOOL *stop) {
                [self createInfoFilesForAllPackagesInItem: subitem andTargetPath: path];
            }];
            
        }];
    }
    @catch (NSException *exception) {
        /* do some staff... */
        return NO;
    }
    _last_pmdoc_file = [NSString stringWithString: path];
    return YES;
}


- (void)createInfoFilesForAllPackagesInItem:(EBPackageBuilderItem *)item andTargetPath:(NSString *)path
{
    NSMutableDictionary *info_file_dict = [[NSMutableDictionary alloc] init];
    __block NSString *pkg_id = nil, *info_filename = nil, *contents_filename = nil;
    __block NSInteger pkg_index = 0;
    __block NSError *error = nil;
    
    [[item packages] enumerateObjectsUsingBlock:^(EBPackage * package, NSUInteger idx, BOOL *stop) {
        pkg_id = [package identifier];
        pkg_index = [_filenames indexOfObject: pkg_id] + 1;
        info_filename = [[self class] infoFilenameFromID: pkg_id andIndex: pkg_index];
        contents_filename = [NSString stringWithFormat:@"%@-contents.xml", 
                            [info_filename stringByDeletingPathExtension]];
        
        [info_file_dict setValue: pkg_id forKey: packme_info_keys_id];
        
        [info_file_dict setValue: @"" forKey: packme_info_keys_mods];
        [info_file_dict setValue: [NSString generateUUID] forKey: packme_info_keys_uuid];
        [info_file_dict setValue: [package version] forKey:packme_info_keys_version];
        [info_file_dict setValue: [package sourceItem] ? [package sourceItem] : @"" forKey: packme_info_keys_source_path];
        [info_file_dict setValue: [package targetPath] ? [package targetPath] : @"" forKey: packme_info_keys_destination];
        [info_file_dict setValue: [package requireAuthorizationWhileInstallation] ? packme_info_templates_require_authorization
                                : @""
                          forKey: packme_info_keys_require_auth];
        if ([package shouldIncludeContainigFolder]) {
            [info_file_dict setValue: packme_info_templates_include_root_attribute forKey: packme_info_keys_include_root_attribute];
            [info_file_dict setValue: packme_info_templates_include_containing_folder forKey: packme_info_keys_include_containing_folder];
        } else {
            [info_file_dict setValue: @"" forKey: packme_info_keys_include_root_attribute];
            [info_file_dict setValue: @"" forKey: packme_info_keys_include_containing_folder];
        }
        
        [info_file_dict setValue: contents_filename forKey: packme_info_keys_contents_filename];
        
        if ([[package sourceItem] hasSuffix: @"kext"]) {
            [info_file_dict setValue: [EBPackageTemplates componentSectionForPackage: package] forKey: packme_info_keys_component_section];
        } else {
            [info_file_dict setValue: @"" forKey: packme_info_keys_component_section];
        }
        
        NSMutableString *scripts = [[NSMutableString alloc] init];
        NSString *tmp_name = nil;
        if ([package preinstallScriptFile]) {
            tmp_name = [package preinstallScriptFile];
        } else if ([package rawPreinstallScript]) {
            tmp_name = [self createScriptFromRaw: [package rawPreinstallScript]];
        }
        if (tmp_name) [scripts appendString: [EBPackageTemplates setValue:tmp_name 
                                                                    byKey:@"*" 
                                                               inTemplate:packme_info_templates_preinstall_script]];
        tmp_name = nil;
        if ([package postinstallScriptFile]) {
            tmp_name = [package postinstallScriptFile];
        } else if ([package rawPostInstallScript]) {
            tmp_name = [self createScriptFromRaw: [package rawPostInstallScript]];
        }
        if (tmp_name) [scripts appendString: [EBPackageTemplates setValue:tmp_name 
                                                                    byKey:@"*" 
                                                               inTemplate:packme_info_templates_postinstall_script]];
        [info_file_dict setValue: scripts forKey: packme_info_keys_scripts_section];
        [scripts release];
        error = nil;
        [[EBPackageTemplates infoFileWithParameters: info_file_dict] writeToFile: [path stringByAppendingPathComponent: info_filename] 
                                                                      atomically: YES
                                                                        encoding: NSUTF8StringEncoding 
                                                                           error: &error];
        //
        if (error) {
            NSLog(@"ERR0R: %@", [error localizedDescription]);
            /* Throw the exeption to initiate exit from the block */
            [info_file_dict release];
            @throw [NSException exceptionWithName: @"error_3" reason:[error localizedDescription] userInfo: nil];
        }
        
        error = nil;
        [[EBPackageTemplates contentsFileFromSources: 
          [NSArray arrayWithObject:[package sourceItem]]] writeToFile: [path stringByAppendingPathComponent: contents_filename] 
         atomically: YES
         encoding: NSUTF8StringEncoding 
         error: &error];
        if (error) {
            [info_file_dict release];
            NSLog(@"ERR0R: %@", [error localizedDescription]);
            @throw [NSException exceptionWithName: @"error_4" reason:[error localizedDescription] userInfo: nil];
        }                
    }];
    [info_file_dict release];
}



- (void)createTemporaryFolder
{
    NSString *tmp_folder_raw = [NSTemporaryDirectory() stringByAppendingPathComponent:
                                [NSString stringWithFormat:@"org.eric_bro.packme.%@",
                                 [NSString generateUUID]]];
    char *c_folder_name = strdup([tmp_folder_raw fileSystemRepresentation]);
    char *result = mkdtemp(c_folder_name);
    if (!result) {
        NSLog(@"ERR0R:  Unable to create the temp folder for package");
        free(c_folder_name);
        return;
    }
    _tmp_folder = [[NSFileManager defaultManager] stringWithFileSystemRepresentation: c_folder_name 
                                                                              length: strlen(result)];
}

- (NSString *)createScriptFromRaw:(NSString *)raw_script
{

    if (!_tmp_folder) [self createTemporaryFolder];
    NSString *filename;
    NSError *error = nil;
    filename = [NSString randomFilenameWithLength: 5 andExtension: @""];
    filename = [_tmp_folder stringByAppendingPathComponent: filename];  
    [raw_script writeToFile: filename atomically: YES encoding: NSUTF8StringEncoding error: &error];
    if (error) {
        NSLog(@"ERR0R: Unable to create temp script file ('%@')",filename);
        return nil;
    }
    return ([_tmp_files addObject: filename], filename);
}


- (NSString *)composeChoiseSection
{
    NSMutableString *return_value = [[NSMutableString alloc] init];
    [_items enumerateObjectsUsingBlock:^(EBPackageBuilderItem *item, NSUInteger idx, BOOL *stop) {
        [return_value appendString: [[self class] choiseSectionForItem: item]];
    }];
    
    return ([return_value autorelease]);
}

+ (NSString *)choiseSectionForItem:(EBPackageBuilderItem *)item
{
    NSMutableString *return_value = [[NSMutableString alloc] init];
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithDictionary:
                                   [[self class] preferencesForItem: item]];             
    [return_value appendString: [EBPackageTemplates choiseSectionWithParameters: prefs]];
    [prefs release];
    
    if ([[item subitems] count] != 0) {
        [[item subitems] enumerateObjectsUsingBlock:^(EBPackageBuilderItem *subitem, NSUInteger idx, BOOL *stop) {
            [return_value appendString: [[self class] choiseSectionForItem: subitem]];
        }];        
    }
    
    [return_value appendString: packme_index_templates_choise_section_close_tag];
    return ([return_value autorelease]);
}

+ (NSDictionary *)preferencesForItem:(EBPackageBuilderItem *)item
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue: [EBPackageTemplates pkgrefsSectionWithPackagesIDs: 
                      [[item packages] mappingUsingBlock:^id(id obj) {
        return [obj identifier];
    }]] 
                  forKey: packme_index_keys_refs_section];
    [dictionary setValue: [item title]      forKey: packme_index_keys_item_title];
    [dictionary setValue: [item identifier] forKey: packme_index_keys_item_id];
    [dictionary setValue: [item description] ? [item description] : @"" 
                  forKey: packme_index_keys_item_description];
    [dictionary setValue: bool2string([item enabledAtLaunch])  forKey: packme_index_keys_item_enabled];
    [dictionary setValue: bool2string([item selectedAtLaunch]) forKey: packme_index_keys_item_selected];
    [dictionary setValue: bool2string([item hiddenAtLaunch])   forKey: packme_index_keys_item_hidden];
    return [dictionary autorelease];
}

- (NSArray *)fileSectionForItem:(EBPackageBuilderItem *)item totalCount:(NSInteger)tcount;
{
    NSMutableArray *return_value = [[NSMutableArray alloc] init];
    __block NSInteger files_count = tcount;
    [return_value addObjectsFromArray: [[item packages] mappingUsingBlock:^id(EBPackage * pkg) {
        files_count++;
        [_filenames addObject: [pkg identifier]];
        return [EBPackageTemplates setValue: [EBPackageBuilder infoFilenameFromID: [pkg identifier] andIndex: files_count] 
                                      byKey: packme_index_keys_xml_filename 
                                 inTemplate: packme_index_templates_items];
    }]];
    
    return ([return_value autorelease]);  
}


- (NSString *)composeFilesSection
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    __block NSInteger file_count = 0;
    __block id temp;
    [_items enumerateObjectsUsingBlock:^(EBPackageBuilderItem *item, NSUInteger idx, BOOL *stop) {
        temp = [self fileSectionForItem: item totalCount: file_count];
        [array addObjectsFromArray: temp];
        file_count += [temp count];
        [[item subitems] enumerateObjectsUsingBlock:^(EBPackageBuilderItem *subitem, NSUInteger idx, BOOL *stop) {
            temp = [self fileSectionForItem: subitem totalCount: file_count];
            [array addObjectsFromArray: temp];
            file_count += [temp count];            
        }];
    }];
    
    return  ([array componentsJoinedByString: @""]);
}
@end
