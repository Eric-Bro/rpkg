//
//  main.m
//  shitbuilder
//
//

#import <Foundation/Foundation.h>
#import <getopt.h>
#import "EBKextPackage.h"
#import "packworks.h"
#import "NSArray+Mapping.h"
#import "NSString+Utils.h"

#define APPNAME @"rpkg"
#define APPVERSION @"0xd023"
#define VERSIONCOMMENT @"(without PackageBuilder included)"
#define COPYRIGTHS @"TrigenSoftware, 2011 eric.broska@me.com"

void QLog(NSString *format, ...);

static struct option longopts[] = {
        {"lru",     required_argument, NULL,  'r'},
        {"len",     required_argument, NULL,  'e'},
        {"source",  required_argument, NULL,  's'},
        {"output",  required_argument, NULL,  'o'},
        {"pkgname", required_argument, NULL,  'n'},
        {"pkgtype", required_argument, NULL,  't'},
        {"builder", required_argument, NULL,  'b'} ,
        {NULL,      0,                 NULL,    0}
};

int main (int argc, char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
       
    QLog(@"\n%@ v.%@  %@\n%@\n--- --- --- ---", APPNAME, APPVERSION, VERSIONCOMMENT, COPYRIGTHS);
    
    NSMutableArray *sources = [[NSMutableArray alloc] init];
    NSString *output_path = nil, *package_name = nil, *maker_path = nil, *ru_readme = nil, *en_readme = nil;
    int package_type = 0;
    int sources_flag = 0, type_flag = 0, utility_flag = 0;
    const char *optstring = "r:e:s:o:n:t:b:";
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
            case 't':
                package_type = [[NSString stringWithCString: optarg encoding: NSUTF8StringEncoding] intValue];
                type_flag++;
                break;
            case 'b':
                maker_path = [[NSString stringWithCString: optarg encoding: NSUTF8StringEncoding] stringByExpandingTildeInPath];
                utility_flag++;
                break;
            default:
                /* TODO: print how-to-use-it info */
                QLog(@"usage: rpkg [arg][value] ...");
                QLog(@"Arguments [required]:");
                QLog(@"   -s (--source)  : a .kext file which will be added to the package;");
                QLog(@"   -o (--output)  : an output .pkg full filename;");
                QLog(@"   -t (--pkgtype) : a type of the package");
                QLog(@"                    (1=General kexts, 2=Ethernet kexts, 3=Wireless kexts);");
                QLog(@"Arguments [optional]:");
                QLog(@"   -n (--pkgname) : a name of the package;");
                QLog(@"   -r (--lru)     : a Russian ReadMe file;");
                QLog(@"   -e (--len)     : an English ReadMe file;");
                QLog(@"   -b (--builder) : a path to the Apple's PackageMaker utility;");
                QLog(@"\nwith love, \n%@\n", APPNAME);
                [sources release];
                [pool drain];
                return 0;            
        }
    }
    /* Error handling part */
    if (!sources_flag) {
        QLog(@"FATAL: Its nothing to do with (you forgot to set some source item). Try again.");
        [sources release];
        [pool drain];
        return -1;
    }
    if (!output_path) {
        QLog(@"FATAL: You forgot to set an output filename for the package. Try again.");
        [sources release];
        [pool drain];
        return -1;
    }
    if (!type_flag || (package_type != kGeneralKextType && package_type != kEthernetKextType && package_type != kWirelessKextType)) {
        QLog(@"FATAL: You forgot to set a type of the package. Try again.");
        [sources release];
        [pool drain];
        return -1;
    }
    if (utility_flag && ! [[NSFileManager defaultManager] fileExistsAtPath: maker_path]) {
        QLog(@"FATAL: The PackageMaker utility doesn't exists at the path you set. Try again and be careful.");
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
        [kp setTargetPath: kEBKextPackageDefaultTargetPath];
        [kp setShouldIncludeContainigFolder: YES];
        return [kp autorelease];
    }]];
    
    EBKextPackageBuilder *builder = [[EBKextPackageBuilder alloc] initWithTitle: package_name ? package_name : @"Roxy extension package" 
                                                                       andKexts: kexts];
    [builder setBackgroundAlignMode: kEBLocaleAlignementBottomLeft];
    /* By default adds only English localization... */
    EBPackageBuilderLocale *en_locale = [[EBPackageBuilderLocale alloc] initWithLanguage:@"en" andContent:@""];
    [en_locale setBackgroundFile:[[NSBundle mainBundle] pathForResource:@"logo_bk" ofType:@"png"]];
    if (en_readme) {
        [en_locale addFileAtPath:en_readme withType:kEBLocaleReadmeFileType];
    }
    [builder addLocale:en_locale];
    [en_locale release];
    /* ...and Russian localization if exists so */
    if (ru_readme) {
        EBPackageBuilderLocale * ru_locale = [[EBPackageBuilderLocale alloc] initWithLanguage: @"ru" andContent: @""];
        [ru_locale setBackgroundFile: [[NSBundle mainBundle] pathForResource: @"logo_bk" ofType: @"png"]];
        [ru_locale addFileAtPath: ru_readme withType: kEBLocaleReadmeFileType];
        [builder addLocale: ru_locale];
        [ru_locale release];
    }

    [builder setOrganizationIdentifier: @"org.rox"];
    [builder setPathToBuildUtility: maker_path ? maker_path 
                                  : @"/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker"];
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