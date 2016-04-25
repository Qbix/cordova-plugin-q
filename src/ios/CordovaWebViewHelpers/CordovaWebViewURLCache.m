//
//  CordovaWebViewURLCache.m
//  QGroupsTest
//
//  Created by adventis on 10/6/15.
//
//

#import "CordovaWebViewURLCache.h"

@implementation CordovaWebViewURLCache

@synthesize listOfJsInjects;

- (NSString*) fileMIMEType:(NSString*) file {
    
    NSDictionary *mimeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"image/png",
                              @"png",
                              @"image/jpeg",
                              @"jpg",
                              @"image/gif",
                              @"gif",
                              @"application/x-javascript",
                              @"js",
                              @"text/css",
                              @"css",
                              nil];
    
    return [mimeDict objectForKey:[file pathExtension]];
}

-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSURL *requestUrl = [request URL];
    
    // Get the path for the request
    NSString *pathString = [requestUrl relativePath];
    NSString *filePath = nil;
    
    NSString* host = [requestUrl host];
    if([host isEqualToString:[self remoteCacheId]] && [self isReturnCahceFilesFromBundle]) {
        filePath = [self handleForGroupsCache:pathString];
    } else {
        NSString* pathToLocalFile = [self isFileInListOfInjects:[requestUrl relativePath]];
        if(pathToLocalFile == nil) {
            return [super cachedResponseForRequest:request];
        }
        
        filePath = pathToLocalFile;
    }
    
    // Load the data
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if(data == nil) return [super cachedResponseForRequest:request];
    
    // Create the cacheable response
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:[self fileMIMEType: pathString] expectedContentLength:[data length] textEncodingName:nil];
    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
    
    return cachedResponse;
}

-(NSString*) handleForGroupsCache:(NSString*) pathString {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], [self pathToBundle], pathString];
    NSAssert(filePath, @"File %@ didn't exist", filePath);
    
    return filePath;
}

-(NSString*) isFileInListOfInjects:(NSString*) fileToSearch {
    if(listOfJsInjects == nil || fileToSearch == nil) {
        return nil;
    }
    
    NSString *fileName = [self getFilenameWithFolder:fileToSearch];
    
    for (NSString* file in listOfJsInjects) {
        if([[self getFilenameWithFolder:file] isEqualToString:fileName]) {
            return file;
        }
    }
    
    return nil;
}


-(NSString*) getFilenameWithFolder:(NSString*) path {
    NSArray * array = [path componentsSeparatedByString:@"/"];
    NSUInteger size = [array count];
    NSString *folder = [array objectAtIndex:size-2];
    NSString *file = [array objectAtIndex:size-1];
    
    return [NSString stringWithFormat:@"%@/%@", folder, file ];
}

@end
