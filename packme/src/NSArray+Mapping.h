//
//  NSArray+Mapping.h
//  

#import <Foundation/Foundation.h>

typedef id (^EBMappingBlock)(id obj);

@interface NSArray (NSArray_Mapping)

- (NSArray *)mappingUsingBlock:(EBMappingBlock)block;
- (NSArray *)mappingUsingBlock_1:(EBMappingBlock)block;

@end
