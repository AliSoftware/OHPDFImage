//
//  ViewController.m
//  OHPDFImageDemo
//
//  Created by Olivier Halligon on 13/12/2014.
//  Copyright (c) 2014 AliSoftware. All rights reserved.
//

#import "ViewController.h"
#import <OHPDFImage/UIImage+OHPDF.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
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

- (void)reloadImage
{
    float scale = self.slider.value / self.slider.maximumValue;
    CGSize imageSize = (CGSize){
        .width  = CGRectGetWidth(self.imageView.superview.bounds)*scale,
        .height = CGRectGetHeight(self.imageView.superview.bounds)*scale
    };

    UIImage* checkImage = [UIImage imageWithPDFNamed:@"check" size:imageSize aspectFit:YES];
    self.imageView.image = checkImage;

}


@end
