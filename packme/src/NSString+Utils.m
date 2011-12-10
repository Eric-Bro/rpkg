//
//  NSString+UUID.m
//  

#import "NSString+Utils.h"

@implementation NSString (NSString_UUID)
+ (NSString*)generateUUID;
{
    return [(NSString*)CFUUIDCreateString(nil, CFUUIDCreate(nil)) autorelease];
}

static const char * alphabet = "abcdefghijklmnopqrstuvwxyz-0123456789";
static const int chars_count = 37;
+ (NSString *)randomFilenameWithLength:(int)length andExtension:(NSString *)extension
{
    if (!length) return nil;
    char *random_string = malloc(sizeof(*random_string)*(length-1));
    for (int i = length-1; i >= 0; i--) {
        random_string[i] = alphabet[arc4random() % chars_count];
    }
    if ( ! [extension hasPrefix:@"."] && extension && ![extension isEqualToString:@""]) {
        extension = [NSString stringWithFormat:@".%@", extension];
    }
    NSString *return_value = [[NSString alloc] initWithFormat:@"%s%@", random_string, extension];
    free(random_string);
    return ([return_value autorelease]);
}
@end
