//
//  UKWebSaverView.m
//  WebSaver
//
//  Created by Thomas Robinson on 10/13/09.
//  Copyright (c) 2009, 280 North. All rights reserved.
//

#import "UKWebSaverView.h"
#import <WebKit/WebKit.h>
#import <AppKit/NSNibLoading.h>
#include <stdlib.h>


NSString*	UKWebSaverURL = @"UKWebSaverURL";
NSString*	UKWebSaverScaleFactor = @"UKWebSaverScaleFactor";
NSString*	UKWebSaver = @"UKWebSaver";


@implementation UKWebSaverView

-(id)	initWithFrame: (NSRect)frame isPreview: (BOOL)isPreview
{
    self = [super initWithFrame: frame isPreview: isPreview];
    if( self )
	{
        srandomdev();
		webView = [[WebView alloc] initWithFrame:[ self bounds] frameName: nil groupName: nil];
		[(NSScrollView*)webView setBackgroundColor: [NSColor blackColor]];	// Looks a little nicer on loading.
		[self addSubview: webView];
		
		NSRect		spinnerBox = [self bounds];
		spinnerBox.size.width = 800.0;
		spinnerBox.size.height = 50.0;
		spinnerBox = SSCenteredRectInRect( spinnerBox, [self bounds] );
		pleaseWaitField = [[NSTextField alloc] initWithFrame: spinnerBox];
		[pleaseWaitField setStringValue: @"One moment please…"];
		[pleaseWaitField setFont: [NSFont systemFontOfSize: 48]];
		[pleaseWaitField setAlignment: NSCenterTextAlignment];
		[pleaseWaitField setTextColor: [NSColor whiteColor]];
		[pleaseWaitField setDrawsBackground: NO];
		[pleaseWaitField setBordered: NO];
		[pleaseWaitField setBezeled: NO];
		[pleaseWaitField setEditable: NO];
		[[pleaseWaitField cell] setWraps: NO];
		[self addSubview: pleaseWaitField];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(webViewProgressStarted:)
													name: WebViewProgressStartedNotification
													object: webView];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(webViewProgressFinished:)
													name: WebViewProgressFinishedNotification
													object: webView];

        pages = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:@"html" inDirectory:nil];
		
		[self reloadSettings];
    }
    return self;
}


-(void)	dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self name: WebViewProgressStartedNotification object: webView];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: WebViewProgressFinishedNotification object: webView];
	
	[configureSheet release];
	configureSheet = nil;
	
	[webView release];
	webView = nil;
	
	[pleaseWaitField release];
	pleaseWaitField = nil;
	
	[super dealloc];
}


-(void)	webViewProgressStarted: (NSNotification*)notif
{
	[pleaseWaitField setHidden: NO];
}


-(void)	webViewProgressFinished: (NSNotification*)notif
{
	[pleaseWaitField setHidden: YES];
}


-(void)	reloadSettings
{
	if( !webView )
		return;
	
	// Set up any scaling:
	NSNumber*	scaleFactorObj = [[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] objectForKey: UKWebSaverScaleFactor];
	float		scaleFactor = scaleFactorObj ? [scaleFactorObj floatValue] : 1.0;
	[webView setTextSizeMultiplier: scaleFactor];
	
	// Load URL:
	NSString*	urlString = [[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] objectForKey: UKWebSaverURL];
	if( !urlString )	// No URL? Use one of the defaults.
        urlString = [NSString stringWithFormat: @"file://%@", [pages objectAtIndex:(random() % [pages count])]];
	
	[webView setMainFrameURL: urlString];
}


- (BOOL)hasConfigureSheet
{
    return YES;
}


-(NSWindow*)	configureSheet
{
	// Create a sheet from the NIB, unless we already loaded it earlier:
	if( !configureSheet )
 	{
		NSBundle*	myBundle = [NSBundle bundleForClass: [self class]];
		[myBundle loadNibFile: [myBundle pathForResource: @"TANWebSaverConfigureSheet" ofType: @"nib"]
					externalNameTable: [NSDictionary dictionaryWithObject: self forKey: @"NSOwner"] withZone: [self zone]];
	}
	
	// urlString == nil means default URL, so check the "default" radio, otherwise
	//	put the URL string in the edit field and check the other one:
	NSString*	urlString = [[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] objectForKey: UKWebSaverURL];
	[radioChoices selectCellAtRow: urlString ? 1 : 0 column: 0];
	if( urlString )
		[urlField setStringValue: urlString];
	
	// Scale factor:
	NSNumber*	scaleFactorObj = [[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] objectForKey: UKWebSaverScaleFactor];
	float		scaleFactor = scaleFactorObj ? [scaleFactorObj floatValue] : 1.0;
	[scaleFactorSlider setDoubleValue: scaleFactor];
	
	return configureSheet;
}


-(IBAction)	doOKButton: (id)sender
{
	[configureSheet orderOut: self];
	
	// Use the user's radio choice to decide which URL to save:
	if( [radioChoices selectedRow] == 0 )
		[[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] removeObjectForKey: UKWebSaverURL];	// No URL? Default.
	else
		[[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] setObject: [urlField stringValue] forKey: UKWebSaverURL];
	
	[[ScreenSaverDefaults defaultsForModuleWithName: UKWebSaver] setFloat: [scaleFactorSlider doubleValue] forKey: UKWebSaverScaleFactor];
	
	[self reloadSettings];
	
	[NSApp endSheet: configureSheet];
}


-(IBAction)	doCancelButton: (id)sender
{
	[configureSheet orderOut: self];
	[NSApp endSheet: configureSheet];
}


-(void)	setConfigureSheet: (NSWindow*)wd
{
	if( configureSheet != wd )
	{
		[configureSheet release];
		configureSheet = [wd retain];
	}
}


@end
