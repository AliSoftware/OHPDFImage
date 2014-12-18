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

@interface OHPDFPage()
- (instancetype)initWithRef:(CGPDFPageRef)pageRef NS_DESIGNATED_INITIALIZER;
@end

@implementation OHPDFPage

+ (instancetype)pageWithRef:(CGPDFPageRef)pageRef
{
    return [[self alloc] initWithRef:pageRef];
}

- (instancetype)initWithRef:(CGPDFPageRef)pageRef
{
    self = [super init];
    if (self)
    {
        CGPDFPageRetain(pageRef);
        _pageRef = pageRef;
    }
    return self;
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

#pragma mark - Drawing in a graphic context

- (void)drawInContext:(CGContextRef)context
{
    [self drawInContext:context rect:self.mediaBox flipped:NO];
}

- (void)drawInContext:(CGContextRef)context rect:(CGRect)rect flipped:(BOOL)flipped
{
    static CGFloat const kScaleFactorIdentity = 1.0;
    CGFloat sx = rect.size.width/self.mediaBox.size.width;
    CGFloat sy = rect.size.height/self.mediaBox.size.height;

    CGContextSaveGState(context);

    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y));
    CGContextConcatCTM(context, CGAffineTransformMakeScale(sx, sy));
    if (flipped)
    {
        CGContextConcatCTM(context, CGAffineTransformMakeScale(kScaleFactorIdentity, -kScaleFactorIdentity));
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(0, -self.mediaBox.size.height));
    }
    CGContextDrawPDFPage(context, _pageRef);
    
    CGContextRestoreGState(context);
}

@end
