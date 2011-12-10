//
//  EBPackageBuilderLocale.h
//  

#import <Cocoa/Cocoa.h>
/* If defined - also check all adding files */
#define EBPackageLocaleVerboseDef

/* Some types of resources files */
#define kEBLocaleReadmeFileType   @"readme"
#define kEBLocaleLicenseFileType  @"license"
#define kEBLocaleWelcomeFileType  @"welcome" 
/* Some most useful files MIME-types */
#define kEBLocaleTextMIMEType      @"text"
#define kEBLocaleRichtextMIMEType  @"text\rtf"


@interface EBPackageBuilderLocale : NSObject
{
    NSString *_language;
    NSMutableString *_resources_string;
    NSArray *_check_types_array;
}
@property (nonatomic, retain) NSString *language;

- (BOOL)setBackgroundFile:(NSString *)background;
- (id)initWithLanguage: (NSString *)lang andContent:(NSString *)content;
- (BOOL)addFileAtPath:(NSString *)path withType:(NSString *)type;
- (BOOL)addEmbeddedFile:(NSString *)content MIMEType:(NSString *)mime_type andType:(NSString *)type;
- (NSString *)composed;
- (BOOL)isEmpty;
@end
