//
//  CustomMarker.h
//  GoogleMapsView
//
//  Created by Andy Wu on 12/16/16.
//  Copyright © 2016 Andy Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomMarker : UIView

@property (weak, nonatomic) IBOutlet UIImageView *Icon;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UILabel *Subtitle;

@end
