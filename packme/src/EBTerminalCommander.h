//
//  EBTerminalCommander.h
//  eric_bro (eric.broska@me.com)

#import <Foundation/Foundation.h>
#import <SecurityFoundation/SFAuthorization.h>

#define kApplicationIdentifier "org.eric_bro.rpkg"

@interface EBTerminalCommander : NSObject

+ (NSString *)runBinaryFile:(NSString *)binary_path withArguments:(NSArray *)args asSuperuser:(BOOL)as_root;

@end
