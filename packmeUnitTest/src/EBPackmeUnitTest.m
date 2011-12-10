//
//  EBPackmeUnitTest.m
//  

#import <GHUnit/GHUnit.h>
#import "EBPackageBuilder.h"
#import "EBKextPackageBuilder.h"


@interface EBPackmeUnitTest: GHTestCase {}
@end

@implementation EBPackmeUnitTest


- (void)testKextPackage
{    
    EBKextPackage *kext = [[EBKextPackage alloc] initWithKextBundle: @"/System/Library/Extensions/KLog.kext" 
                                                         identifier: @"org.packme.tests.kext.package" 
                                                        destination: kKextExtraFolderDestination
                                                               type: kGeneralKextType
                                                autogenerateScripts: YES];
    [kext setTargetPath: kEBKextPackageDefaultTargetPath];
    [kext setShouldIncludeContainigFolder: YES];
    
    EBKextPackageBuilder *kBuilder = [[EBKextPackageBuilder alloc] initWithTitle: @"My_test_kp" 
                                                                        andKexts: [NSArray arrayWithObject: kext]];
    [kext release];
    EBPackageBuilderLocale *locale= [[EBPackageBuilderLocale alloc] initWithLanguage:@"ru" andContent:@""];
    [kBuilder addLocale: locale];
    [locale release];
    
    [kBuilder setOrganizationIdentifier: @"org.problems.jpeg"];
    [kBuilder setPathToBuildUtility: @"/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker"];
    [kBuilder setUIMode: kPackageUIModeCustom];
    [kBuilder setMinimumReqiuredOS: kPackageMinimumRequired105];
    [kBuilder setInstallationDomainFlags: (kPackageDomainAnywhereFlag)];
    
    
    GHAssertTrue([kBuilder composePMDOCFileByPath: @"~/Documents/666/kkkkeeexts"],
                 @"Unable to create a .pmdoc file for the kext '%@' package at this path",
                 [kBuilder title]);
    
    GHAssertTrue([kBuilder buildPackageByPath: @"~/Documents/666/kkkext.pkg"
                              usingPMDOCFile: kBuilder.lastCreatedPMDOCFile],
                 @"Unable to create the package '%@' at this path",
                 [kBuilder title]);
    [kBuilder release];
}



- (void)testPackageCreation 
{
    EBPackageBuilder *builder = [[EBPackageBuilder alloc] initWithTitle: @"My awesome package"];
    
    GHAssertNotNil(builder, @"#builder alloc/init has failed.");
    
    [builder setOrganizationIdentifier: @"org.problems.jpeg"];
    [builder setPathToBuildUtility: @"/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker"];
    [builder setUIMode: kPackageUIModeBoth];
    [builder setMinimumReqiuredOS: kPackageMinimumRequired105];
    [builder setInstallationDomainFlags: (kPackageDomainAnywhereFlag | kPackageDomainUserFlag)];
    
    // ******************** //
    
    EBPackageBuilderItem *firstItem = [[EBPackageBuilderItem alloc] initWithTitle: @"My first super-duper item" 
                                                                    andIdentifier: @"first.item.tt"];
    [firstItem setDescription: @"This is a sample item with one text file (one package) included."];
    EBPackage *packageN1 = [[EBPackage alloc] initWithID: @"this.is.horoshiy.package_1" 
                                                 version: @"0.666" 
                                              sourceItem: @"~/usbdriver.m"
                                           andTargetPath: @"/666"];
    
    GHAssertTrue([firstItem addPackage: packageN1], 
                 @"Fail to add the package with id '%@' into item '%@'", 
                 [packageN1 identifier], [firstItem identifier]);
    
    [packageN1 release];
    
    GHAssertTrue([builder addItem: firstItem], 
                 @"Fail to add the item '%@' into the builder '%@'", 
                 [firstItem identifier], [builder title]);
    
    [firstItem release];
    
    // ******************** //
    
    EBPackageBuilderItem *secondItem = [[EBPackageBuilderItem alloc] initWithTitle: @"Another one so"
                                                                     andIdentifier: @"another.one.so"];
    [secondItem setDescription: @"This one with some pre- and postinstall scripts included."];
    EBPackage *someCoolPackage = [[EBPackage alloc] initWithID: @"ololo.bash.na.bash" 
                                                       version: @"9.1" 
                                                    sourceItem: @"~/rodionov.pas"
                                                 andTargetPath: @"/666"];
    [someCoolPackage setShouldIncludeContainigFolder: NO];
    
    GHAssertTrue([someCoolPackage setScript:@"#!/bin/bash \necho \"He, pre!\" \nexit" type: kPackagePreinstallScript raw: YES],
                 @"Unable to add a raw script into the '%@' package",
                 [someCoolPackage identifier]);
    
    GHAssertTrue([someCoolPackage setScript:@"~/postinstall" type: kPackagePostinstallScript raw: NO], 
                 @"Unable to add a script file '~/postinstall' script into the '%@' package",
                 [someCoolPackage identifier]);
    
    GHAssertTrue([secondItem addPackage: someCoolPackage], 
                 @"Unable to add the '%@' package into the '' item", 
                 [someCoolPackage identifier], [secondItem identifier]);
    
    [someCoolPackage release];
    
    GHAssertTrue([builder addItem: secondItem], 
                 @"Unable to add the item '%@' into the builder '%@'", 
                 [secondItem identifier], [builder title]);
    
    [secondItem release];
    
    // ******************** //
    
    GHAssertTrue([builder composePMDOCFileByPath: @"~/Documents/666/packme"],
                 @"Unable to create a .pmdoc file for the '%@' package at this path",
                 [builder title]);

    GHAssertTrue([builder buildPackageByPath: @"~/Documents/666/packme.pkg"
                              usingPMDOCFile: builder.lastCreatedPMDOCFile],
                 @"Unable to create the package '%@' at this path",
                 [builder title]);
    
    NSLog(@"So complete");
    
    [builder release];
    
}

@end
