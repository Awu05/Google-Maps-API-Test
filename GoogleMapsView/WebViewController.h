//
//  WebViewController.h
//  
//
//  Created by Andy Wu on 12/19/16.
//
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
- (IBAction)backBtn:(id)sender;

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *name;


@end
