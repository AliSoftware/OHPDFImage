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

#import "OHPDFPage.h"
#import <UIKit/UIKit.h>

/***********************************************************************************/

@implementation OHPDFPage

+ (instancetype)pageWithRef:(CGPDFPageRef)pageRef
{
    OHPDFPage* page = [self new];
    CGPDFPageRetain(pageRef);
    page->_pageRef = pageRef;
    return page;
}

- (void)dealloc
{
    if (_pageRef)
    {
        CGPDFPageRelease(_pageRef);
        _pageRef = nil;
    }
}

#pragma mark - PDF Page Box Rects

- (CGRect)mediaBox
{
    return CGPDFPageGetBoxRect(_pageRef, kCGPDFMediaBox);
}

- (CGRect)cropBox
{
    return CGPDFPageGetBoxRect(_pageRef, kCGPDFCropBox);
}
- (CGRect)bleedBox
{
    return CGPDFPageGetBoxRect(_pageRef, kCGPDFBleedBox);
}
- (CGRect)trimBox
{
    return CGPDFPageGetBoxRect(_pageRef, kCGPDFTrimBox);
}
- (CGRect)artBox
{
    return CGPDFPageGetBoxRect(_pageRef, kCGPDFArtBox);
}

#pragma mark - Drawing and transforming to UIImage

- (void)drawInContext:(CGContextRef)context
{
    CGContextDrawPDFPage(context, _pageRef);
}

- (UIImage*)imageWithSize:(CGSize)size
                aspectFit:(BOOL)aspectFit
{
    return [self imageWithSize:size aspectFit:aspectFit opaque:NO scale:0.0];
}

- (UIImage*)imageWithSize:(CGSize)size
                aspectFit:(BOOL)aspectFit
                   opaque:(BOOL)opaque
                    scale:(CGFloat)scale
{
    CGFloat sx = 1.0;
    CGFloat sy = 1.0;
    CGSize mediaBoxSize = self.mediaBox.size;
    
    if (!CGSizeEqualToSize(size, CGSizeZero))
    {
        sx = size.width / mediaBoxSize.width;
        sy = size.height / mediaBoxSize.height;
        if (aspectFit)
        {
            sx = sy = MIN(sx,sy);
        }
    }
    CGRect rect = CGRectMake(0.f, 0.f, mediaBoxSize.width*sx, mediaBoxSize.height*sy);
    UIImage* image = nil;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale);
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if (opaque)
        {
            CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextFillRect(ctx, rect);
        }
        
        CGContextConcatCTM(ctx, CGAffineTransformMakeScale(sx, -sy));
        CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(0, -self.mediaBox.size.height));
        [self drawInContext:ctx];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return image;
}
@end
