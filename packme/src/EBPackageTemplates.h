//
//  EBPackageTemplates.h
//  

#import <Foundation/Foundation.h>

@class EBPackage;

@interface EBPackageTemplates : NSObject
{
}

/* Common methods */
+ (NSString *)setValue:(NSString *)aValue byKey:(NSString *)aKey inTemplate:(NSString *)aTemplate;
+ (NSString *)setValuesFromDictionary:(NSDictionary *)aDictionary inTemplate:(NSString *)aTemplate;

/* Section composing */
+ (NSString *)resouresSectionWithLocales:(NSArray *)locales backgroundFile:(NSString *)path backgroundScale:(NSString *)scale andAlign:(NSString *)align;
+ (NSString *)pkgrefsSectionWithPackagesIDs:(NSArray *)packagesIDs;
+ (NSString *)choiseSectionWithParameters:(NSDictionary *)parameters;
+ (NSString *)itemsSectionWithFilenames:(NSArray *)filenames;
+ (NSString *)modsSectionWithDomainFlags:(int)flags;
+ (NSString *)componentSectionForPackage:(EBPackage *)package;

/* Files composing */
/* index.xml - the file which describes all package's items (content) and some parameters */
+ (NSString *)indexFileWithParameters:(NSDictionary *)parameters;
/* ${item_name}.xml - the file which describes package's item parameters */
+ (NSString *)infoFileWithParameters:(NSDictionary *)parameters;
/* ${item_name}+contents.xml -the file which describes package's item contents (file structure) 
   Where $path - the path to a separate file or a folder. */
+ (NSString *)contentsFileFromSources:(NSArray *)paths;

@end
