//
//  EBKextPackageBuilder.h
//  

#import "EBPackageBuilder.h"
#import "EBKextPackage.h"


#define kEBInternalPackageMakerSubpath [[[NSBundle bundleWithIdentifier: @"org.eric-bro.packworks"] bundlePath] stringByAppendingPathComponent:@"/Versions/A/Resources/AppleMaker/Contents/MacOS/PackageMaker"]

@interface EBKextPackageBuilder : EBPackageBuilder
{
    NSString *_disabledChoiseName;
@protected
    NSArray *_kexts;
    enum EBKextDestination _destination;
}
@property enum EBKextDestination destination;
@property (nonatomic, retain) NSString *disabledChoiseName;

- (id)initWithTitle:(NSString *)title andKexts:(NSArray *)kexts;
@end
