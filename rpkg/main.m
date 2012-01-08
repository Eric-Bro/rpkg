//
//  main.m
//  shitbuilder
//
//

#import <Foundation/Foundation.h>
#import <getopt.h>
#import "packworks.h"
#import "NSArray+Mapping.h"
#import "NSString+Utils.h"

#define APPNAME @"rpkg"
#define APPVERSION @"0xd028"
#define VERSIONCOMMENT @""
#define COPYRIGTHS @"TrigenSoftware, 2011 eric.broska@me.com"


#define EBPackworksResource(x,y) [[NSBundle bundleWithIdentifier: @"org.eric-bro.packworks"] pathForResource: (x) ofType: (y)]

void QLog(NSString *format, ...);
void InfoPrint();

static struct option longopts[] = {
        {"lru",     required_argument, NULL,  'r'},
        {"len",     required_argument, NULL,  'e'},
        {"source",  required_argument, NULL,  's'},
        {"output",  required_argument, NULL,  'o'},
        {"pkgname", required_argument, NULL,  'n'},
        {"pkgtype", required_argument, NULL,  't'},
        {"builder", required_argument, NULL,  'b'},
        {"help"   , no_argument,       NULL,  'h'},
        {"disable", required_argument, NULL,  'c'},
        {NULL,      0,                 NULL,    0}
};

int main (int argc, char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
       
    QLog(@"\n%@ v.%@  %@\n%@\n--- --- --- ---", APPNAME, APPVERSION, VERSIONCOMMENT, COPYRIGTHS);
    
    NSMutableArray *sources = [[NSMutableArray alloc] init];
    NSString *output_path = nil, *package_name = nil, *maker_path = nil, *ru_readme = nil, *en_readme = nil;
    NSString *disable_choise = nil, *tmp_type_string = nil;
    int package_type = 0, sources_flag = 0, type_flag = 0, utility_flag = 0;
    const char *optstring = "r:e:s:o:n:t:b:hc:";
    int tmp; 
    while ((tmp = getopt_long(argc, argv, optstring, longopts, NULL)) != -1) {
        switch (tmp) {
            case 'r':
                ru_readme = [[NSString stringWithCString: optarg encoding: NSUTF8StringEncoding] stringByExpandingTildeInPath];
                break;
            case 'e':
                en_readme = [[NSString stringWithCString: optarg encoding: NSUTF8StringEncoding] stringByExpandingTildeInPath];
                break;
            case 's':
                [sources addObject: [[NSString stringWithCString: optarg encoding: NSUTF8StringEncoding] stringByExpandingTildeInPath]];
                sources_flag++;
                break;
            case 'o':
                output_path = [[NSString stringWithCString: optarg encoding: NSUTF8StringEncoding] stringByExpandingTildeInPath];
                break;
            case 'n':
                package_name = [NSString stringWithCString: optarg encoding: NSUTF8StringEncoding];
                break;
            case 'c':
                disable_choise = [[NSString stringWithCString: optarg encoding: NSUTF8StringEncoding] lowercaseString];
                if (![disable_choise isEqualToString: @"extra"] && ![disable_choise isEqualToString:@"sle"]) {
                    disable_choise = nil;
                }
                break;
            case 't':
                tmp_type_string = [NSString stringWithCString: optarg encoding: NSUTF8StringEncoding];
                if ([tmp_type_string isEqualToString: @"general"])  package_type = kGeneralKextType;
                if ([tmp_type_string isEqualToString: @"ethernet"]) package_type = kEthernetKextType;
                if ([tmp_type_string isEqualToString: @"wireless"]) package_type = kWirelessKextType;
                if (package_type) {
                    type_flag++;
                }
                break;
            case 'b':
                maker_path = [[NSString stringWithCString: optarg encoding: NSUTF8StringEncoding] stringByExpandingTildeInPath];
                utility_flag++;
                break;
            case 'h':
                InfoPrint();
                [sources release];
                [pool drain];
                return 0;
            default:
                break;
        }
    }
    /* Error handling part */
    if (!sources_flag) {
        QLog(@"FATAL: Its nothing to do with (you forgot to set some source item). Try again.\n--- --- --- ---");
        InfoPrint();
        [sources release];
        [pool drain];
        return -1;
    }
    if (!output_path) {
        QLog(@"FATAL: You forgot to set an output filename for the package. Try again.\n--- --- --- ---");
        InfoPrint();
        [sources release];
        [pool drain];
        return -1;
    }
    if (!type_flag || (package_type != kGeneralKextType && package_type != kEthernetKextType && package_type != kWirelessKextType)) {
        QLog(@"FATAL: You forgot to set a type of the package. Try again.\n--- --- --- ---");
        InfoPrint(); 
        [sources release];
        [pool drain];
        return -1;
    }
    if (utility_flag && ! [[NSFileManager defaultManager] fileExistsAtPath: maker_path]) {
        QLog(@"FATAL: The PackageMaker utility doesn't exists at the path you set. Try again and be careful.\n--- --- --- ---");
        InfoPrint();
        [sources release];
        [pool drain];
        return -1;
    }
    
    QLog(@"Composing...");
    /* Composing part */
    NSArray *kexts =  [NSArray arrayWithArray: [sources mappingUsingBlock:^id(NSString *path) {
        EBKextPackage *kp = [[EBKextPackage alloc] initWithKextBundle: path 
                                                          identifier: [NSString stringWithFormat: @"org.shitbuilder.%@.pkg",
                                                                       [NSString randomFilenameWithLength: 5 andExtension: @""]]  
                                                         destination: kKextExtraFolderDestination 
                                                                type: package_type 
                                                 autogenerateScripts: YES]; 
        if (!kp) {
            //[kp release];
            return [NSNull null];
        }
        [kp setTargetPath: kEBKextPackageDefaultTargetPath];
        [kp setShouldIncludeContainigFolder: YES];
        return [kp autorelease];
    }]];
    
    EBKextPackageBuilder *builder = [[EBKextPackageBuilder alloc] initWithTitle: package_name ? package_name : @"Roxy extension package" 
                                                                       andKexts: kexts];
    [builder setBackgroundAlignMode: kEBLocaleAlignementBottomLeft];
    if (disable_choise) {
        [builder setDisabledChoiseName: disable_choise];
    }
    
    EBPackageBuilderLocale *en_locale = [[EBPackageBuilderLocale alloc] initWithLanguage:@"en" andContent:@""];
    [en_locale setBackgroundFile: EBPackworksResource(@"logo_bk", @"png")];
    if (en_readme) {
        [en_locale addFileAtPath:en_readme withType:kEBLocaleReadmeFileType];
    }
    [en_locale addFileAtPath: EBPackworksResource(@"License_eng", @"txt") withType: kEBLocaleLicenseFileType];
    [builder addLocale:en_locale];
    [en_locale release];
    
    EBPackageBuilderLocale * ru_locale = [[EBPackageBuilderLocale alloc] initWithLanguage: @"ru" andContent: @""];
    [ru_locale setBackgroundFile: EBPackworksResource(@"logo_bk", @"png")];
    [ru_locale addFileAtPath: EBPackworksResource(@"License_ru", @"txt") withType: kEBLocaleLicenseFileType];
    [builder addLocale: ru_locale];
    [ru_locale release];
    if (ru_readme) {
        [ru_locale addFileAtPath: ru_readme withType: kEBLocaleReadmeFileType];
    }

    [builder setOrganizationIdentifier: @"org.rox"];
    [builder setPathToBuildUtility: maker_path ? maker_path 
                                  : kEBInternalPackageMakerSubpath];
    [builder setUIMode: kPackageUIModeCustom];
    [builder setMinimumReqiuredOS: kPackageMinimumRequired105];
    [builder setInstallationDomainFlags: (kPackageDomainAnywhereFlag)];
    
    QLog(@"Building the package...");
    [builder composePMDOCFileByPath: [NSString stringWithFormat:@"~/Library/%@",
                                      [NSString randomFilenameWithLength: 4 andExtension: @"pmdoc"]]];
    
    if ([builder buildPackageByPath: output_path usingPMDOCFile: builder.lastCreatedPMDOCFile]) {
        QLog(@"The package '%@' has been successfully created at path '%@'\n", [builder title], output_path);
    } else {
        QLog(@"ERR0R:\nUnable to create the package %@ at this path ('%@')\n", [builder title], output_path);
    }
    [builder release];
    [pool drain];
    return 0;
}


/* --- --- --- --- */
/* QuiteLog()      */

void QLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *tmp = [[NSString alloc] initWithFormat: format arguments: args];
    va_end(args);
    printf("%s\n", [tmp UTF8String]);
    [tmp release];
}

void InfoPrint()
{
    QLog(@"usage: rpkg [arg][value] ...");
    QLog(@"Arguments [required]:");
    QLog(@"     -s (--source)  : a .kext file which will be added to the package;");
    QLog(@"     -o (--output)  : an output .pkg full filename;");
    QLog(@"     -t (--pkgtype) : a type of the package");
    QLog(@"                    ('general', 'ethernet', 'wireless');");
    QLog(@"Arguments [optional]:");
    QLog(@"     -n (--pkgname) : a name of the package;");
    QLog(@"     -r (--lru)     : a Russian ReadMe file;");
    QLog(@"     -e (--len)     : an English ReadMe file;");
    QLog(@"     -c (--disable) : disable one of two choices in a package");
    QLog(@"                    ('extra' or 'sle');");
    QLog(@"     -b (--builder) : a custom path to the Apple's PackageMaker utility;");
    QLog(@"\nwith love, \n%@\n", APPNAME);
}