//
//  ViewController.h
//  GoogleMapsView
//
//  Created by Andy Wu on 12/15/16.
//  Copyright © 2016 Andy Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;
@import GooglePlaces;
@import GooglePlacePicker;


@interface ViewController : UIViewController <GMSMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate> {
    
    GMSPlacePicker *placePicker;
}

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;

@property(nonatomic,strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *pinLocs;

- (IBAction)Terrain:(UISegmentedControl *)sender;



@end

