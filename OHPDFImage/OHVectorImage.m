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
    if ((size.width <= 0) || (size.height <= 0))
    {
        return nil;
    }

    CGRect fullRect  = CGRectIntegral( (CGRect){ .origin = CGPointZero, .size = size } );
    CGSize imageSize = fullRect.size; // Extract it back, because CGRectIntegral may have rounded it

    CGSize scale = [self scaleForSize:size];
    UIEdgeInsets scaledInsets = (UIEdgeInsets){
        .top    = self.insets.top    * scale.height,
        .left   = self.insets.left   * scale.width,
        .bottom = self.insets.bottom * scale.height,
        .right  = self.insets.right  * scale.width
    };
    
    UIImage* rasterImage = [self generateImageWithSize:imageSize drawingBlock:^(CGContextRef ctx) {
        if (self.tintColor)
        {
            // Generate a mask using the PDF
            UIImage* mask = [self generateImageWithSize:imageSize drawingBlock:^(CGContextRef ctx) {
                // - flipped=YES because we will use its CGImage with CGContextClipToMask
                //   which is in CoreGraphics coordinate system — which is inverted compared
                //   to the UIKit coordinate system.
                CGRect insetRect = CGRectIntegral( UIEdgeInsetsInsetRect(fullRect, scaledInsets) );
                [self.pdfPage drawInContext:ctx rect:insetRect flipped:YES];
            }];
            // Use the mask to generate a tinted image
            CGContextClipToMask(ctx, fullRect, mask.CGImage);
            CGContextSetFillColorWithColor(ctx, self.tintColor.CGColor);
            CGContextFillRect(ctx, fullRect);
        }
        else
        {
            // Directly render the image in a bitmap context.
            // Note: we need to flip the insetRect to match the CoreGraphics orientation
            CGRect insetRect = CGRectIntegral( UIEdgeInsetsInsetRect(fullRect, (UIEdgeInsets){
                .top  = scaledInsets.bottom, .bottom = scaledInsets.top,
                .left = scaledInsets.left,    .right = scaledInsets.right
            }) );
            [self.pdfPage drawInContext:ctx rect:insetRect flipped:NO];
        }
    }];
    
    // Render the final image using prepareContextBlock, backgroundColor and shadow
    return [self generateImageWithSize:imageSize drawingBlock:^(CGContextRef ctx) {
        // If the user provided a block to execute before rendering, apply it now
        if (self.prepareContextBlock) self.prepareContextBlock(ctx);
        
        // If we have a background color, fill the image with it
        if (self.backgroundColor != nil)
        {
            CGContextSetFillColorWithColor(ctx, self.backgroundColor.CGColor);
            // Add 1 to width and height to fill everything, even the bottom and right borders
            CGRect rect = CGRectMake(0.0f, 0.0f, size.width+1, size.height+1);
            CGContextFillRect(ctx, rect);
        }
        
        // If we have a shadow, apply it now
        if (self.shadow)
        {
            UIColor* shadowColor = (UIColor*)self.shadow.shadowColor;
            // Convert offset and radius from nativeSize scale to target size scale
            CGSize offset = (CGSize){
                .width  = self.shadow.shadowOffset.width  * scale.width,
                .height = self.shadow.shadowOffset.height * scale.height
            };
            CGFloat radius = self.shadow.shadowBlurRadius * (scale.width+scale.height)/2;
            CGContextSetShadowWithColor(ctx, offset, radius, shadowColor.CGColor);
        }
        
        // Finally, draw the rastered image
        CGContextDrawImage(ctx, fullRect, rasterImage.CGImage);
    }];
}

- (UIImage*)renderAtSizeThatFits:(CGSize)size
{
    return [self renderAtSize:[self sizeThatFits:size]];
}

#pragma mark - Private Methods

- (UIImage*)generateImageWithSize:(CGSize)size
                     drawingBlock:( void(^)(CGContextRef ctx) )drawingBlock
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    drawingBlock( UIGraphicsGetCurrentContext() );
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
};

@end
