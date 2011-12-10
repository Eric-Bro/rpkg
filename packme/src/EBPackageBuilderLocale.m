//
//  EBPackageBuilderLocale.m
//  

#import "EBPackageBuilderLocale.h"
#import "EBPackageTemplates_defines.h"
#import "EBPackageTemplates.h"

@implementation EBPackageBuilderLocale
@synthesize language = _language;

- (id)initWithLanguage:(NSString *)lang andContent:(NSString *)content
{
    if (!lang) return (self=nil, self);
    if ((self = [super init])) {
        [self setLanguage: lang];
        _resources_string = [[NSMutableString alloc] initWithString: content];
        _check_types_array = [[NSArray alloc ] initWithObjects: kEBLocaleLicenseFileType, kEBLocaleReadmeFileType, kEBLocaleWelcomeFileType, nil];
    } else self =  nil;
    return self;
}

- (void)dealloc
{
    [_resources_string release];
    [_check_types_array release];
    [super dealloc];
}

- (BOOL)addFileAtPath:(NSString *)path withType:(NSString *)type
{
#ifdef EBPackageLocaleVerboseDef
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
#endif
    
    NSDictionary *file_prefs = [NSDictionary dictionaryWithObjectsAndKeys: 
                                path, packme_index_keys_resources_file_general_content,
                                type, packme_index_keys_resources_file_general_type, nil];
    [_resources_string appendString: [EBPackageTemplates setValuesFromDictionary: file_prefs 
                                                                      inTemplate: packme_index_templates_resources_file_external]];
    return YES;
}

- (BOOL)addEmbeddedFile:(NSString *)content MIMEType:(NSString *)mime_type andType:(NSString *)type
{
    if ( !content || [content isEqualToString: @""]) return NO;
#ifdef EBPackageLocaleVerboseDef
    if ( ! [_check_types_array containsObject: type]) return NO;
#endif
    NSDictionary *file_prefs = [NSDictionary dictionaryWithObjectsAndKeys: 
                                content, packme_index_keys_resources_file_general_content,
                                mime_type, packme_index_keys_resources_file_embedded_mimetype,
                                type, packme_index_keys_resources_file_general_type, nil];
    [_resources_string appendString: [EBPackageTemplates setValuesFromDictionary: file_prefs 
                                                                      inTemplate: packme_index_templates_resources_file_embedded]];
    return YES;
}

- (BOOL)setBackgroundFile:(NSString *)background
{
#ifdef EBPackageLocaleVerboseDef
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath: background]) return NO;
#endif
    [_resources_string appendString: [EBPackageTemplates setValue: [background stringByExpandingTildeInPath] 
                                                            byKey: packme_index_keys_resources_background_filepath 
                                                       inTemplate: packme_index_templates_resources_background]];
    return YES;
}

- (BOOL)isEmpty
{
    return (!_resources_string);
}

- (NSString *)composed
{
    if ([_resources_string isEqualToString: @""]) {
        return [EBPackageTemplates setValue: _language 
                                      byKey: packme_index_keys_resources_locale_language 
                                 inTemplate: packme_index_templates_resources_locale_no_files];
    }
    NSDictionary *locale_prefs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  _language, packme_index_keys_resources_locale_language,
                                  _resources_string, packme_index_keys_resources_locale_section_content, nil];
    return [EBPackageTemplates setValuesFromDictionary: locale_prefs inTemplate: packme_index_templates_resources_locale_section];
}

@end
