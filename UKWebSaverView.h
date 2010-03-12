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
	IBOutlet NSWindow	*	configureSheet;
	IBOutlet NSTextField *	urlField;
	IBOutlet NSMatrix	*	radioChoices;
}

-(IBAction)	doOKButton: (id)sender;
-(IBAction)	doCancelButton: (id)sender;

-(void)		setConfigureSheet: (NSWindow*)wd;

@end
