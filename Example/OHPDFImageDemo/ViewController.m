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
@property (weak, nonatomic) IBOutlet UISwitch *colorSwitch;
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
        @"circle", @"check", @"dingbats", @"dotmask"
    }[self.segmentedControl.selectedSegmentIndex];
    
    UIImage* image = nil;
    if (self.colorSwitch.on)
    {
        OHVectorImage* vImage = [OHVectorImage imageWithPDFNamed:imageName];
        CGSize fitSize = [vImage sizeThatFits:imageSize];
        vImage.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:1.0];
        vImage.tintColor = [UIColor redColor];
        image = [vImage imageWithSize:fitSize];
    }
    else
    {
        image = [UIImage imageWithPDFNamed:imageName fitInSize:imageSize];
    }
    
    self.imageView.image = image;
}


@end
