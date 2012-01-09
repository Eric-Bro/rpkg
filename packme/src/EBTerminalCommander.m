//
//  EBTerminalCommander.m
//  eric_bro (eric.broska@me.com)

#import "EBTerminalCommander.h"

static AuthorizationRef auth_ref = NULL;

@interface EBTerminalCommander ()
+ (NSString *)execute_binary_as_root:(NSString *)binary_path withArguments:(NSArray *)args;
+ (NSString *)execute_binary:(NSString *)binary_path withArguments:(NSArray *)args;
@end

@implementation EBTerminalCommander

+ (NSString *)runBinaryFile:(NSString *)binary_path withArguments:(NSArray *)args asSuperuser:(BOOL)as_root
{
    return as_root ? [EBTerminalCommander execute_binary_as_root: binary_path withArguments: args]
                   : [EBTerminalCommander execute_binary: binary_path withArguments: args];
}

+ (NSString *)execute_binary:(NSString *)binary_path withArguments:(NSArray *)args
{
    NSTask *task = [[NSTask alloc] init];
	
	if (binary_path) { 
        [task setLaunchPath:binary_path];
    } else {
        [task release];
        return nil;
    }
	if (args) { 
        [task setArguments: args];
    }
    
	NSPipe *pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	[task setStandardInput : [NSPipe pipe]];
	
	/* This is a handle of a file which store an all output data */
	NSFileHandle *handle = [pipe fileHandleForReading];
	[task launch];
    [task waitUntilExit];
	/* So, read them once process of binary's performing was completed */
	NSData *data = [handle readDataToEndOfFile];
	[task release];
	
	return [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
}

+ (NSString *)execute_binary_as_root:(NSString *)binary_path withArguments:(NSArray *)args
{
    OSStatus os_status = noErr;
    /* Asks for superuser's password and gets the root access */
    if (auth_ref == NULL) {
        AuthorizationItem rights[2] = {{kApplicationIdentifier, 0, NULL, 0}, {"system.privilege.admin", 0, NULL, 0}};
        AuthorizationRights rightSet = {2, rights};
        AuthorizationFlags authFlags =  kAuthorizationFlagDefaults | kAuthorizationFlagPreAuthorize |kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights;
        os_status= AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, authFlags, &auth_ref);
        if (os_status != errAuthorizationSuccess) return nil;
        os_status = AuthorizationCopyRights(auth_ref, &rightSet, kAuthorizationEmptyEnvironment, authFlags, NULL);
        if (os_status != errAuthorizationSuccess) return nil;
    }
    FILE *output_pipe = NULL;
    unsigned args_c = (unsigned)[args count];
    char *arguments[args_c + 1];
    /* Convert NSString arguments to c-strings */
    for (short i = 0; i < args_c; i++) {
        arguments[i] = (char*)[[args objectAtIndex: i] cStringUsingEncoding: NSASCIIStringEncoding];
    }
    /* Add ended '/0' */
    arguments[args_c] = NULL;
    
    /* 
    TODO: because this way is deprecated now, we have to execute a binary file via the ServiceMangement.framework... 
    */
	os_status = AuthorizationExecuteWithPrivileges(auth_ref,
												(char*)[binary_path cStringUsingEncoding:NSASCIIStringEncoding], 
												kAuthorizationFlagDefaults, 
												arguments, 
												&output_pipe);
    if (os_status == errAuthorizationSuccess) {
        NSFileHandle *outputFileHandle = [[[NSFileHandle alloc] initWithFileDescriptor: fileno(output_pipe) closeOnDealloc: YES] autorelease];
        return [[[NSString alloc] initWithData: [outputFileHandle readDataToEndOfFile] 
                                      encoding: NSUTF8StringEncoding] 
                autorelease];
    } else {
        return nil;
    }
}
@end
