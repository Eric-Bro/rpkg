//
//  EBKextPackageBuilder.h
//  

#import "EBPackageBuilder.h"
#import "EBKextPackage.h"

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
