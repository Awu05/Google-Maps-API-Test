//
//  ViewController.m
//  GoogleMapsView
//
//  Created by Andy Wu on 12/15/16.
//  Copyright © 2016 Andy Wu. All rights reserved.
//

#import "ViewController.h"
#import "CustomMarker.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.pinLocs = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //[self.locationManager startUpdatingLocation];
    
    /*
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
    // change the camera, set the zoom, whatever.  Just make sure to call the animate* method.
    [self.googleMapView animateToCameraPosition: [self newCamera]];
    [CATransaction commit];
    */
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.708368 longitude:-74.014811 zoom:16];

    self.googleMapView.camera = camera;
    
    self.googleMapView.myLocationEnabled = YES;
    self.searchBar.delegate = self;
    self.googleMapView.delegate = self;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(40.708368, -74.014811);
    marker.title = @"TurnToTech";
    marker.snippet = @"New York";
    marker.map = self.googleMapView;
    
    
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake(40.708054, -74.013938);
    marker2.title = @"Dunkin Donuts";
    marker2.snippet = @"America On The Run";
    marker2.map = self.googleMapView;
    marker2.infoWindowAnchor = CGPointMake(0.5, -0.25);
    
    GMSMarker *marker3 = [[GMSMarker alloc] init];
    marker3.position = CLLocationCoordinate2DMake(40.7084394, -74.0111636);
    marker3.title = @"Subways";
    marker3.snippet = @"Always Eat Fresh";
    marker3.map = self.googleMapView;
    marker3.infoWindowAnchor = CGPointMake(0.5, -0.25);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Terrain:(UISegmentedControl *)sender {
    NSUInteger selectedMapType = sender.selectedSegmentIndex;
    
    switch (selectedMapType) {
        case 0:
            self.googleMapView.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.googleMapView.mapType = kGMSTypeHybrid;
            break;
        case 2:
            self.googleMapView.mapType = kGMSTypeSatellite;
            break;
            
        default:
            self.googleMapView.mapType = kGMSTypeNormal;
            break;
    }
}

-(UIView*) mapView: (GMSMapView*)mapView markerInfoWindow:(GMSMarker *)marker
{
    CustomMarker * infoWindow = [[[NSBundle mainBundle]loadNibNamed:@"CustomMarker" owner:self options:nil]objectAtIndex:0];
    
    infoWindow.Title.text = marker.title;
    infoWindow.Subtitle.text = marker.snippet;
    infoWindow.Icon.image = [UIImage imageNamed:@"stock company"];
    
    return infoWindow;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
    //Opens up tapped pin in a webview
    NSString *url = [NSString stringWithFormat:@"https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=%@", marker.title];
    
    NSString *fixedURL = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"
                                                           options:NSRegularExpressionSearch range:NSMakeRange(0, url.length)];
    
    //NSLog(@"URL: %@\n", fixedURL);
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.url = fixedURL;
    
    [self presentViewController:webVC animated:YES completion:nil];
    
}

- (void) searchWeb {
    //Allows you to input to search bar
    
    NSString *searchString = self.searchBar.text;
    NSLog(@"Searching for: %@\n", searchString);
    
    NSString *searchURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.708368,-74.014811&radius=500&keyword=%@&key= AIzaSyCPgMqcQSiPsHGHaBe8nmpVQtPsdDopfF8", searchString];
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodedUrlAsString = [searchURL stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:[NSURL URLWithString:encodedUrlAsString]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                [self parseData:data];
                NSLog(@"RESPONSE: %@",response);
                NSLog(@"DATA: %@",data);
                
                if (!error) {
                    // Success
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        NSError *jsonError;
                        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                        
                        if (jsonError) {
                            // Error Parsing JSON
                            
                        } else {
                            // Success Parsing JSON
                            // Log NSDictionary response:
                            NSLog(@"%@",jsonResponse);
                        }
                    }  else {
                        //Web server is returning an error
                    }
                } else {
                    // Fail
                    NSLog(@"error : %@", error.description);
                }
            }] resume];
    
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //    [self searchWeb];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    for (GMSMarker *pin in self.pinLocs) {
        pin.map = nil;
    }
    
    self.searchBar.text = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [self searchWeb];
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void) parseData: (NSData*) data {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    NSArray* nearByPlaces = [json objectForKey:@"results"];
    NSLog(@"%@\n", nearByPlaces);
    
    for (NSDictionary *properties in nearByPlaces) {
        NSLog(@"Iterating through nearByPlaces Array\n");
        double xCoord = 0.0;
        double yCoord = 0.0;
        NSDictionary* geometry = [properties objectForKey:@"geometry"];
        NSLog(@"Setting Geometry array, count: %lu.\n", (unsigned long)[geometry count]);
        NSLog(@"Geometry Results: %@\n", geometry);
        
        NSDictionary *coords = [geometry objectForKey:@"location"];
        xCoord = [[coords objectForKey:@"lat"] doubleValue];
        yCoord = [[coords objectForKey:@"lng"] doubleValue];
        NSLog(@"XCoord: %f, YCoord: %f\n", xCoord, yCoord);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            GMSMarker *pinsToAdd = [[GMSMarker alloc] init];
            
            pinsToAdd.title = [properties objectForKey:@"name"];
            pinsToAdd.snippet = [properties objectForKey:@"vicinity"];
            pinsToAdd.position = CLLocationCoordinate2DMake(xCoord, yCoord);
            NSLog(@"Title: %@, snippet: %@\n", pinsToAdd.title, pinsToAdd.snippet);
            
            pinsToAdd.map = self.googleMapView;
            [self.pinLocs addObject:pinsToAdd];
        });
        
    }
    
}



@end
