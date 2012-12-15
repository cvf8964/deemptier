//
//  main.m
//  Deemptier
//
//  Created by Andrew A.A. on 12/15/12.
//  Copyright (c) 2012 Andrew A.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

void printUsage (BOOL shouldTerminate);


int main(int argc, const char * argv[])
{

	@autoreleasepool {

		if (argc == 1)
			printUsage(YES);

		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *rootDirectoryPath = [[NSString alloc] initWithCString:argv[1] encoding:NSUTF8StringEncoding];

		if (![rootDirectoryPath.stringByStandardizingPath isAbsolutePath])
			printUsage(YES);

		NSURL *rootDirectoryURL = [NSURL fileURLWithPath:rootDirectoryPath];
		NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:rootDirectoryURL includingPropertiesForKeys:@[NSURLIsDirectoryKey] options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants) errorHandler:^BOOL(NSURL *url, NSError *error) {
			return YES;
		}];
		

		NSMutableArray *directoryArray = [[NSMutableArray alloc] initWithCapacity:50];

	    for (NSURL *fileNodeURL in enumerator) {

			NSNumber *isDirectory = nil;

			[fileNodeURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];

			if (isDirectory.boolValue) {
				NSArray *contents = [fileManager contentsOfDirectoryAtURL:fileNodeURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
				if (contents.count == 0)
					[directoryArray addObject:fileNodeURL.path];
			}
		}

		printf("\n1: List empty folders;\n");
		printf("2: Export list of empty folders;\n");
		printf("3: Remove all empty folder;\n");
		printf("4: Nothing!\n");
		printf("Select an action: ");

		char aCharacter = '\0';

		scanf("%c", &aCharacter);
		printf("\n");

		switch (aCharacter) {
			case '1': {
				printf("Empty directories:\n");
				for (NSString *directoryPath in directoryArray)
					printf("%s\n", directoryPath.UTF8String);
				printf("\n");
				break;
			}

			case '2': {

				NSString *outputFilePath = [@"~/Desktop/Empty Directories.txt" stringByExpandingTildeInPath];
				BOOL isSuccessful = [directoryArray.description writeToFile:outputFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
				if (isSuccessful)
					[[NSWorkspace sharedWorkspace] openFile:outputFilePath];
				else
					printf("ERROR: cannot write to folder at path \"%s\"\n\n", outputFilePath.UTF8String);
				break;
			}

			case '3': {
				for (NSURL *directoryURL in directoryArray)
					[fileManager removeItemAtURL:directoryURL error:nil];
				break;
			}

			default:
				return 0;
		}

	}
    return 0;
}

void printUsage (BOOL shouldTerminate)
{
	printf("\nUsage: deemptier root_dir_path\n\n");
	
	if (shouldTerminate)
		exit(101);
}
