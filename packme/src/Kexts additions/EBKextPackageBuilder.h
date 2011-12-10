//
//  EBKextPackageBuilder.h
//  

#import "EBPackageBuilder.h"
#import "EBKextPackage.h"

@interface EBKextPackageBuilder : EBPackageBuilder
{
@protected
    NSArray *_kexts;
    enum EBKextDestination _destination;
}
@property enum EBKextDestination destination;

- (id)initWithTitle:(NSString *)title andKexts:(NSArray *)kexts;
@end
