//
//  NSArray+Mapping.m
//  

#import "NSArray+Mapping.h"

typedef void (^EBThrowBlock)(id obj);

@interface NSArray (NSArray_GoThrow)
- (void)throwItems:(EBThrowBlock)block;
@end

@implementation NSArray (NSArray_Mapping)

- (NSArray*)mappingUsingBlock:(EBMappingBlock)block
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self throwItems: ^void(id obj) {
        [result addObject: block(obj)];
    }];
    return [NSArray arrayWithArray:result];
}

- (void)throwItems:(EBThrowBlock)block
{
    [self enumerateObjectsUsingBlock: ^void (id obj, NSUInteger idx, BOOL *stop) { 
        block(obj);
    }];
}

- (NSArray *)mappingUsingBlock_1:(EBMappingBlock)block
{
    NSUInteger count = [self count];
    id *objects = malloc(sizeof(objects)*count);
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        objects[idx] = [block(obj) retain];
    }];
    NSArray *return_value = [NSArray arrayWithObjects: objects count: count];
    
    for (NSUInteger i = 0; i < count; i++) {
        [objects[i] release];
    }
    free(objects);
    return (return_value);
}

@end
