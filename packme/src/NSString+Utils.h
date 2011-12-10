//
//  NSString+UUID.h
//  
#import <Foundation/Foundation.h>

@interface NSString (NSString_UUID)
+ (NSString *)generateUUID;
+ (NSString *)randomFilenameWithLength:(int)length andExtension:(NSString *)extension;
@end
