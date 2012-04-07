//
//  UKWebSaverView.h
//  WebSaver
//
//  Created by Thomas Robinson on 10/13/09.
//  Copyright (c) 2009, 280 North. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

#import <WebKit/WebKit.h>

@interface UKWebSaverView : ScreenSaverView 
{
	WebView				*	webView;
	NSTextField			*	pleaseWaitField;
	IBOutlet NSWindow	*	configureSheet;
	IBOutlet NSTextField *	urlField;
	IBOutlet NSMatrix	*	radioChoices;
	IBOutlet NSSlider	*	scaleFactorSlider;
    NSArray             *   pages;
}

-(IBAction)	doOKButton: (id)sender;
-(IBAction)	doCancelButton: (id)sender;

-(void)		setConfigureSheet: (NSWindow*)wd;

-(void)		reloadSettings;

@end
