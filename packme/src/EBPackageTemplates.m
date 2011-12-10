//
//  EBPackageTemplates.m
//  

#import "EBPackageBuilderLocale.h"
#import "EBPackage.h"
#import "EBPackageTemplates.h"
#import "EBPackageTemplates_defines.h"
#import "shared_enums.h"

/*!
 * TODO:
 * 1) replace templates names in (+infoFileWithParameters:);
 * 2) replace temps. names and flags constans in (+domainSectionWithFlags:);
 * 3) replace template name in (+infoFileWithParameters:);
 * 4) replace tmpls names in (+contentsFileFromSources:);
 * 5) string alloc in (+composeContentTreeForFolder:(NSString *)folder isRoot:(BOOL)root);
 */


@interface EBPackageTemplates (Private)
+ (char*)replaceSubstring:(const char*)substring withValue:(const char *)replace_with inSourceString:(const char *)string;
+ (NSString *)domainSectionWithFlags:(NSInteger)flags;
+ (NSString *)composeContentTreeForFolder:(NSString *)folder isRoot:(BOOL)root;
+ (NSDictionary *)propertiesForFile:(NSString *)path isRoot:(BOOL)root;
@end



@implementation EBPackageTemplates

- (id)init
{
    if (self = [super init]) {
        // Initialization code here.
    } else self =  nil;
    
    return self;
}

+ (char*)replaceSubstring:(const char *)substring withValue:(const char *)replace_with inSourceString:(const char *)source
{
    size_t substring_s    = strlen(substring);
    size_t replace_with_s = strlen(replace_with);
    size_t source_s       = strlen(source);
    
    char *result = malloc(source_s + 1);
    char *ptr = result;
    if(!ptr) return 0;
    
    while(*source) {
        if (strncmp(source, substring, substring_s)) {
            *ptr++ = *source++;
        } else {
            ptr  -= (int)result;
            result = realloc(result, source_s += (replace_with_s - substring_s));
            ptr  += strlen(strcpy(ptr = result + (int)ptr, replace_with));
            source  += substring_s;
        }  
    }
    *ptr = 0;
    return result;
}

+ (NSString *)setValue:(NSString *)aValue byKey:(NSString *)aKey inTemplate:(NSString *)aTemplate
{
    return [NSString stringWithCString: 
            [EBPackageTemplates replaceSubstring: cstring(aKey) 
                                       withValue: cstring(aValue)
                                  inSourceString: cstring(aTemplate)] 
                              encoding: NSUTF8StringEncoding];
}

+ (NSString *)setValuesFromDictionary:(NSDictionary *)aDictionary inTemplate:(NSString *)aTemplate
{
    NSMutableString *return_value = [[[NSMutableString alloc] initWithString:aTemplate] autorelease];
    [aDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [return_value  setString: [EBPackageTemplates setValue: obj byKey: key inTemplate: return_value]];
    }];
    return [NSString stringWithString: return_value];
}

#pragma mark index.xml

+ (NSString *)resouresSectionWithLocales:(NSArray *)locales backgroundFile:(NSString *)path backgroundScale:(NSString *)scale andAlign:(NSString *)align;

{
    if ( !locales || ![locales count]) return @"";
    
    NSMutableString *all_locales = [[NSMutableString alloc] init];
    [locales enumerateObjectsUsingBlock:^(EBPackageBuilderLocale *locale, NSUInteger idx, BOOL *stop) {
        [all_locales appendString: [locale composed]];
    }];
    if (path) {
        [all_locales appendString: [EBPackageTemplates setValue: path 
                                                    byKey: packme_index_keys_resources_background_filepath 
                                               inTemplate: packme_index_templates_resources_background]];
    }
    NSDictionary *res_dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              scale, packme_index_keys_resources_bg_scale,
                              align, packme_index_keys_resources_bg_align,
                              all_locales, packme_index_keys_resources_section_content, nil];
    [all_locales release];
    return [EBPackageTemplates setValuesFromDictionary: res_dict inTemplate: packme_index_templates_resources_section];
    
}

+ (NSString*)choiseSectionWithParameters:(NSDictionary *)parameters
{
    return [EBPackageTemplates setValuesFromDictionary: parameters inTemplate: packme_index_templates_choise_section];
}

+ (NSString *)itemsSectionWithFilenames:(NSArray *)filenames 
{
    __block NSMutableString *return_value = [NSMutableString string];
    [filenames enumerateObjectsUsingBlock:^(id filename, NSUInteger idx, BOOL *stop) {    
        [return_value appendString: [EBPackageTemplates setValue: filename byKey: packme_index_keys_xml_filename
                                                inTemplate: packme_index_templates_refs]];
    }];
    return (return_value);
}

+ (NSString*)pkgrefsSectionWithPackagesIDs:(NSArray *)packagesIDs
{
    __block NSMutableString *return_value = [[NSMutableString alloc] init];
    [packagesIDs enumerateObjectsUsingBlock:^(id pid, NSUInteger idx, BOOL *stop) {
        [return_value appendString: [EBPackageTemplates setValue: pid byKey: packme_index_keys_refs_id 
                                                inTemplate: packme_index_templates_refs]];
    }];
     return ([return_value autorelease]);
}
     

+ (NSString *)indexFileWithParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *tmp_mut = [NSMutableDictionary dictionaryWithDictionary: parameters];
    NSInteger raw_domain_flags = [[tmp_mut objectForKey: packme_index_keys_domain_flags] integerValue];
    [tmp_mut setValue: [EBPackageTemplates domainSectionWithFlags: raw_domain_flags] 
               forKey: packme_index_keys_domain_flags];
    return  [EBPackageTemplates setValuesFromDictionary: tmp_mut inTemplate: packme_index_templates_body];
}

+ (NSString *)domainSectionWithFlags:(NSInteger)flags
{
    NSMutableString *return_value = [[NSMutableString alloc] init];
    if (flag(kPackageDomainAnywhereFlag, flags)) {
        [return_value appendString: packme_index_templates_domain_anywhere];
    }
    if (flag(kPackageDomainSystemFlag, flags)) {
        [return_value appendString: packme_index_templates_domain_system];
    }
    if (flag(kPackageDomainUserFlag, flags)) {
        [return_value appendString: packme_index_templates_domain_user];
    }
    return [EBPackageTemplates setValue: [return_value autorelease] byKey: @"*" inTemplate: packme_index_templates_domain];
}

/* Its no more than cosmetic addition rigth now */
+ (NSString *)modsSectionWithDomainFlags:(int)flags
{
    NSMutableString *return_value = [[NSMutableString alloc] init];
    [return_value appendFormat:@"%@%@%@", packme_index_templates_mod_domain_anywhere,
     packme_index_templates_mod_domain_user, packme_index_templates_mod_domain_system];
    return ([return_value autorelease]);
}

#pragma mark info.xml

+ (NSString *)infoFileWithParameters:(NSDictionary *)parameters
{
    return [EBPackageTemplates setValuesFromDictionary: parameters inTemplate: packme_info_templates_body];
}

#pragma mark info+contens.xml

+ (NSDictionary *)propertiesForFile:(NSString *)path isRoot:(BOOL)root
{
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath: path]) return nil;
    
    NSMutableDictionary *return_value = [[NSMutableDictionary alloc] init];
    NSError *error = nil;
    NSDictionary *tmp_dict = [[NSFileManager defaultManager] attributesOfItemAtPath: path error: &error];
    if (error) {
        [return_value release], tmp_dict = nil;
        error = nil;
        return nil;
    }
    [return_value setValue: [path lastPathComponent] forKey: packme_contents_keys_filename];
    [return_value setValue: [tmp_dict valueForKey:NSFileOwnerAccountName]  forKey: packme_contents_keys_owner];
    [return_value setValue: [tmp_dict valueForKey:NSFileGroupOwnerAccountName] forKey: packme_contents_keys_owner_group];
    if (root) [return_value setValue: path forKey: packme_contents_keys_path];
    tmp_dict = nil, error = nil;
    return ([return_value autorelease]);    
}

+ (NSString *)composeContentTreeForFolder:(NSString *)folder isRoot:(BOOL)root
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *tmp_string = (root) ? [EBPackageTemplates setValuesFromDictionary: [EBPackageTemplates propertiesForFile:folder isRoot: YES] 
                                                               inTemplate: packme_contents_templates_root_folder]
                                  : [EBPackageTemplates setValuesFromDictionary: [EBPackageTemplates propertiesForFile:folder isRoot: NO] 
                                                               inTemplate: packme_contents_templates_folder];
    NSArray *files = [file_manager contentsOfDirectoryAtPath: folder error: NULL];
    __block BOOL is_dir = NO;
    __block NSMutableString *return_value = [NSMutableString stringWithString: tmp_string];
    [files enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        /* (# .DS_Store -> /Users/eric_bro/.DS_Store) */
        filename = [folder stringByAppendingFormat:@"/%@", filename];
        if (([file_manager fileExistsAtPath: filename isDirectory: &is_dir]), is_dir) {
            [return_value appendString: [EBPackageTemplates composeContentTreeForFolder: filename isRoot: NO]];
        } else {
            [return_value appendString: [EBPackageTemplates setValuesFromDictionary: [EBPackageTemplates propertiesForFile: filename isRoot: NO] 
                                                                   inTemplate: packme_contents_templates_file]];
        }
    }];
     [return_value appendString: @"</f>"];
     return (return_value);
}


+ (NSString *)contentsFileFromSources:(NSArray *)paths
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    __block BOOL is_dir = NO;
    __block NSMutableString *return_value = [[NSMutableString alloc] initWithString: packme_contents_templates_open_tag];
    [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        if ([file_manager fileExistsAtPath: path isDirectory: &is_dir] && is_dir) {
            [return_value appendString: [EBPackageTemplates composeContentTreeForFolder: path isRoot: YES]];
        } else {
            [return_value appendString: [EBPackageTemplates setValuesFromDictionary: [EBPackageTemplates propertiesForFile: path isRoot: YES]
                                                                   inTemplate: packme_contents_templates_root_file]];
        }
    }];
     [return_value appendString: packme_contents_templates_close_tag];
     return ([return_value autorelease]);
}


+ (NSString *)componentSectionForPackage:(EBPackage *)package
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: 
                          [package version], packme_info_keys_component_version,
                          [package identifier], packme_info_keys_component_id,
                          [package sourceItem],packme_info_keys_component_path,
                          [NSString stringWithFormat:@"%@/Contents/version.plist", [package sourceItem]],
                          packme_info_keys_component_version_plist,nil];
    return [[self class] setValuesFromDictionary: dict inTemplate: packme_info_templates_component];
}
@end
