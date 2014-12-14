/***********************************************************************************
 *
 * Copyright (c) 2014 Olivier Halligon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/

#import "OHVectorImage.h"
#import "OHPDFDocument.h"
#import "OHPDFPage.h"

/***********************************************************************************/

@interface OHVectorImage()
@property(nonatomic, strong) OHPDFPage* pdfPage;
@end



@implementation OHVectorImage

#pragma mark - Constructor

+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
{
    return [self imageWithPDFNamed:pdfName inBundle:nil];
}

+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
                         inBundle:(NSBundle*)bundleOrNil
{
    NSString* basename = [pdfName stringByDeletingPathExtension];
    NSString* ext = [pdfName pathExtension];
    if (ext.length == 0) ext = @"pdf";
    NSURL* url = [(bundleOrNil?:[NSBundle mainBundle]) URLForResource:basename withExtension:ext];
    return [self imageWithPDFURL:url];
}

+ (instancetype)imageWithPDFURL:(NSURL*)pdfURL
{
    static NSCache* pdfCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pdfCache = [NSCache new];
    });
    
    OHPDFPage* page = [pdfCache objectForKey:pdfURL];
    if (!page)
    {
        OHPDFDocument* doc = [OHPDFDocument documentWithURL:pdfURL];
        page = [doc pageAtIndex:1];
        if (page)
        {
            [pdfCache setObject:page forKey:pdfURL];
        }
    }
    
    return [self imageWithPDFPage:page];
}

+ (instancetype)imageWithPDFPage:(OHPDFPage*)pdfPage
{
    OHVectorImage* vImage = nil;
    if (pdfPage)
    {
        vImage = [self new];
        vImage.pdfPage = pdfPage;
        vImage->_nativeSize = pdfPage.mediaBox.size;
    }
    return vImage;
}

#pragma mark - Rendering

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat sx = 1.0;
    CGFloat sy = 1.0;
    
    if (!CGSizeEqualToSize(size, CGSizeZero))
    {
        sx = size.width / self.nativeSize.width;
        sy = size.height / self.nativeSize.height;
        sx = sy = MIN(sx,sy);
    }
    
    return CGSizeMake(self.nativeSize.width*sx, self.nativeSize.height*sy);
}

- (UIImage*)imageWithSize:(CGSize)size
{
    CGRect rect = (CGRect){ .origin = CGPointZero, .size = size };
    
    if (self.tintColor)
    {
        UIImage* mask = [self imageWithSize:size backgroundColor:nil drawingBlock:^(CGContextRef ctx) {
            // flipped=NO because we want to keep the image in the CoreGraphics coordinates system
            // as it will be used with CGContextClipToMask
            [self.pdfPage drawInContext:ctx rect:rect flipped:NO];
        }];

        return [self imageWithSize:size backgroundColor:self.backgroundColor drawingBlock:^(CGContextRef ctx) {
            CGContextClipToMask(ctx, rect, mask.CGImage);
            CGContextSetFillColorWithColor(ctx, self.tintColor.CGColor);
            CGContextFillRect(ctx, rect);
        }];
    }
    else
    {
        return [self imageWithSize:size backgroundColor:self.backgroundColor drawingBlock:^(CGContextRef ctx) {
            [self.pdfPage drawInContext:ctx rect:rect flipped:YES];
        }];
    }
}

#pragma mark - Private Methods

- (UIImage*)imageWithSize:(CGSize)size
             backgroundColor:(UIColor*)bkgColor
             drawingBlock:( void(^)(CGContextRef ctx) )block
{
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(size, (bkgColor != nil), 0.0);
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if (bkgColor != nil)
        {
            CGContextSetFillColorWithColor(ctx, bkgColor.CGColor);
            // Add 1 to width and height to fill everything, even the bottom and right borders
            CGRect rect = CGRectMake(0.0f, 0.0f, size.width+1, size.height+1);
            CGContextFillRect(ctx, rect);
        }
        block(ctx);
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return image;
};

@end
