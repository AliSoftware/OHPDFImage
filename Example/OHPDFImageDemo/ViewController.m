//
//  ViewController.m
//  OHPDFImageDemo
//
//  Created by Olivier Halligon on 13/12/2014.
//  Copyright (c) 2014 AliSoftware. All rights reserved.
//

#import "ViewController.h"
#import <OHPDFImage/OHPDFImage.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UISwitch *bkgColorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *tintColorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shadowSwitch;
@end

@implementation ViewController

-(void)viewDidLayoutSubviews
{
    // In particular once loaded or on orientation change
    [self reloadImage];
}

- (IBAction)sliderDidChange:(UISlider *)sender
{
    [self reloadImage];
}
- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    [self reloadImage];
}
- (IBAction)switchChanged:(UISwitch *)sender
{
    [self reloadImage];
}

- (void)reloadImage
{
    float scale = self.slider.value / self.slider.maximumValue;
    CGSize imageSize = (CGSize){
        .width  = CGRectGetWidth(self.imageView.superview.bounds)*scale,
        .height = CGRectGetHeight(self.imageView.superview.bounds)*scale
    };
    
    NSString* imageName = (NSString* []){
        @"dingbats", @"circle", @"check", @"dotmask"
    }[self.segmentedControl.selectedSegmentIndex];
    
    UIImage* image = nil;
    // If no option needed, we can simply use:
    // image = [UIImage imageWithPDFNamed:imageName fitInSize:imageSize];

    // But here we want to show all the advanced options, so we manipulate the
    // OHVectorImage object to configure it before rendering it as a bitmap image
    OHVectorImage* vImage = [OHVectorImage imageWithPDFNamed:imageName];
    
    if (self.bkgColorSwitch.on)
    {
        vImage.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:1.0];
    }
    if (self.tintColorSwitch.on)
    {
        vImage.tintColor = [UIColor redColor];
    }
    if (self.shadowSwitch.on)
    {
        vImage.shadow = [NSShadow new];
        vImage.shadow.shadowOffset = CGSizeMake(2, 2);
        vImage.shadow.shadowBlurRadius = 3.f;
        vImage.shadow.shadowColor = [UIColor darkGrayColor];
        vImage.insets = UIEdgeInsetsMake(0, 0, 5, 5);
    }
    CGSize fitSize = [vImage sizeThatFits:imageSize];
    image = [vImage renderAtSize:fitSize];
    
    self.imageView.image = image;
}


@end
