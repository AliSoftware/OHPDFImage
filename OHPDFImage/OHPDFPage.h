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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
@class UIImage;

/***********************************************************************************/

/**
 *  A given page of a PDF document.
 */
@interface OHPDFPage : NSObject

/**
 *  The CoreGraphics reference (CGPDFPageRef) to the PDF page.
 */
@property(nonatomic, assign, readonly) CGPDFPageRef pageRef;

#pragma mark - PDF Page Box Rects

/**
 *  The PDF page media box. See kCGPDFMediaBox documentation for details.
 */
@property(nonatomic, readonly) CGRect mediaBox;
/**
 *  The PDF page crop box. See kCGPDFCropBox documentation for details.
 */
@property(nonatomic, readonly) CGRect cropBox;
/**
 *  The PDF page bleed box. See kCGPDFBleedBox documentation for details.
 */
@property(nonatomic, readonly) CGRect bleedBox;
/**
 *  The PDF page trim box. See kCGPDFTrimBox documentation for details.
 */
@property(nonatomic, readonly) CGRect trimBox;
/**
 *  The PDF page art box. See kCGPDFArtBox documentation for details.
 */
@property(nonatomic, readonly) CGRect artBox;

#pragma mark - Constructor

/**
 *  Create a new OHPDFPage from a CGPDFPageRef
 *
 *  @param pageRef The CGPDFPageRef to use
 *
 *  @return An OHPDFPage object wrapping the CGPDFPageRef
 */
+ (instancetype)pageWithRef:(CGPDFPageRef)pageRef;

#pragma mark - Drawing in a graphic context

/**
 *  Draws the page in a Graphic Context
 *
 *  @param context The context to draw the PDF page into
 */
- (void)drawInContext:(CGContextRef)context;

/**
 *  Draws the page in a Graphic Context
 *
 *  @param context The context to draw the PDF page into
 *  @param rect    The destination rectangle to draw the image into
 *  @param flipped If YES, the drawing is flipped when rendered in the context.
 *                 Useful if the context has been created using
 *                 `UIGraphicsBeginImageContext` and not CoreGraphics functions
 */
- (void)drawInContext:(CGContextRef)context rect:(CGRect)rect flipped:(BOOL)flipped;

@end
