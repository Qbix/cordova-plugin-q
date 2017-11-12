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
                              @"image/png", @"png",
                              @"image/jpeg", @"jpg",
                              @"image/jpeg", @"jpeg",
                              @"image/gif", @"gif",
                              @"application/javascript", @"js",
                              @"application/javascript", @"javascript",
                              @"application/json", @"json",
                              @"text/css", @"css",
                              @"text/html", @"html",
                              @"application/octet-stream", @"handlebars",
                              @"audio/m4a", @"m4a",
                              @"audio/wav", @"wav",
                              @"audio/mp3", @"mp3",
                              @"video/mp4", @"mp4",
                              nil];
    
    return [mimeDict objectForKey:[file pathExtension]];
}

-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSURL *requestUrl = [request URL];
    
    // Get the path for the request
    NSString *pathString = [requestUrl relativePath];
    NSLog(@"%@", [requestUrl absoluteString]);
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
    
    if([[[fileToSearch componentsSeparatedByString:@"/"] lastObject] isEqualToString:@"cordova.js"]) {
        return [listOfJsInjects objectAtIndex:0];
    }
    
    if([[[fileToSearch componentsSeparatedByString:@"/"] lastObject] isEqualToString:@"cordova_plugins.js"]) {
        return [listOfJsInjects objectAtIndex:1];
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
