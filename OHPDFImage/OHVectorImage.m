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
- (instancetype)initWithPDFPage:(OHPDFPage*)pdfPage NS_DESIGNATED_INITIALIZER;
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
    if (!pdfName) return nil;
    
    NSString* basename = [pdfName stringByDeletingPathExtension];
    NSString* ext = [pdfName pathExtension];
    if (ext.length == 0) ext = @"pdf";
    NSURL* url = [(bundleOrNil?:[NSBundle mainBundle]) URLForResource:basename withExtension:ext];
    return [self imageWithPDFURL:url];
}

+ (instancetype)imageWithPDFURL:(NSURL*)pdfURL
{
    if (!pdfURL) return nil;
    
    static size_t const kDefaultPDFPageIndexForVectorImage = 1; // Use first page by default
    static NSCache* pdfCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pdfCache = [NSCache new];
    });
    
    OHPDFPage* page = [pdfCache objectForKey:pdfURL];
    if (!page)
    {
        OHPDFDocument* doc = [OHPDFDocument documentWithURL:pdfURL];
        page = [doc pageAtIndex:kDefaultPDFPageIndexForVectorImage];
        if (page)
        {
            [pdfCache setObject:page forKey:pdfURL];
        }
    }
    
    return [self imageWithPDFPage:page];
}

+ (instancetype)imageWithPDFPage:(OHPDFPage*)pdfPage
{
    return [[self alloc] initWithPDFPage:pdfPage];
}

- (instancetype)initWithPDFPage:(OHPDFPage*)pdfPage
{
    if (!pdfPage) return nil;
    
    self = [super init];
    if (self)
    {
        _pdfPage = pdfPage;
        _nativeSize = pdfPage.mediaBox.size;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    OHVectorImage* copy = [OHVectorImage imageWithPDFPage:self.pdfPage];
    copy.tintColor = [self.tintColor copy];
    copy.backgroundColor = [self.backgroundColor copy];
    copy.shadow = [self.shadow copy];
    copy.insets = self.insets;
    copy.prepareContextBlock = [self.prepareContextBlock copy];
    return copy;
}

#pragma mark - Rendering at a given size

- (CGSize)insetNativeSize
{
    return (CGSize){
        .width  = self.nativeSize.width + self.insets.left + self.insets.right,
        .height = self.nativeSize.height + self.insets.top + self.insets.bottom
    };
}
- (CGSize)scaleForSize:(CGSize)size
{
    static CGFloat const kScaleFactorIdentity = 1.0;
    CGFloat sx = kScaleFactorIdentity;
    CGFloat sy = kScaleFactorIdentity;
    
    CGSize insetSize = self.insetNativeSize;
    if (!CGSizeEqualToSize(insetSize, CGSizeZero))
    {
        sx = size.width / insetSize.width;
        sy = size.height / insetSize.height;
    }
    
    return CGSizeMake(sx,sy);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize scale = [self scaleForSize:size];
    CGFloat minScale = MIN(scale.width, scale.height);
    
    return (CGSize){
        .width  = roundf(self.insetNativeSize.width * minScale),
        .height = roundf(self.insetNativeSize.height * minScale)
    };
}

- (UIImage*)renderAtSize:(CGSize)size
{
    CGSize scale = [self scaleForSize:size];
    UIEdgeInsets scaledInsets = (UIEdgeInsets){
        .top    = self.insets.top    * scale.height,
        .left   = self.insets.left   * scale.width,
        .bottom = self.insets.bottom * scale.height,
        .right  = self.insets.right  * scale.width
    };
    CGRect fullRect  = CGRectIntegral( (CGRect){ .origin = CGPointZero, .size = size } );
    CGRect insetRect = CGRectIntegral( UIEdgeInsetsInsetRect(fullRect, scaledInsets) );
    
    return [self generateImageWithSize:fullRect.size backgroundColor:self.backgroundColor drawingBlock:^(CGContextRef ctx) {
        if (self.prepareContextBlock) self.prepareContextBlock(ctx);
        
        if (self.shadow)
        {
            UIColor* shadowColor = (UIColor*)self.shadow.shadowColor;
            CGSize offset = self.shadow.shadowOffset;
            offset.height *= -1; // inverted coordinates between CoreGraphics and UIKit
            CGContextSetShadowWithColor(ctx, offset, self.shadow.shadowBlurRadius, shadowColor.CGColor);
        }
        [self.pdfPage drawInContext:ctx rect:insetRect flipped:YES];
        
        if (self.tintColor)
        {
            UIImage* mask = [self generateImageWithSize:fullRect.size backgroundColor:nil drawingBlock:^(CGContextRef ctx) {
                // - flipped=NO because we want to keep the image in the CoreGraphics coordinates system
                //   as it will be used with CGContextClipToMask
                // - fullRect because the mask image will be mapped to the insetRect by
                //   the CGContextClipToMask function itself
                [self.pdfPage drawInContext:ctx rect:fullRect flipped:NO];
            }];
            CGContextClipToMask(ctx, insetRect, mask.CGImage);
            CGContextSetFillColorWithColor(ctx, self.tintColor.CGColor);
            CGContextFillRect(ctx, fullRect);
        }
    }];
}

#pragma mark - Private Methods

- (UIImage*)generateImageWithSize:(CGSize)size
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
