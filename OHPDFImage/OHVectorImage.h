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

#import <UIKit/UIKit.h>
@class OHPDFPage;

/***********************************************************************************/

/**
 *  This class represents a vector image, typically loaded from a PDF file.
 *
 *  It allows you to query the expected rendering size (mediaBox of the PDF)
 *  and render it as an `UIImage` using various parameters like a given
 *  backgroundColor, tintColor, drop shadow, margins/insets and custom size,
 *  and also compute the size that fits a given input size (for when you need
 *  to keep original aspect ratio).
 */
@interface OHVectorImage : NSObject <NSCopying>

#pragma mark - Properties

/**
 *  The color to tint the image with.
 *
 *  - If `nil` (the default), no special tint is applied.
 *  - If non-`nil`, the image will be recolored entierly using this color.
 *    In that case, only the alpha component or the image is used
 */
@property(nonatomic, strong) UIColor* tintColor;

/**
 *  The background color to apply to the image when rendering into an `UIImage`.
 *
 *  If `nil` (the default), the image will have a transparent background.
 */
@property(nonatomic, strong) UIColor* backgroundColor;

/**
 *  The drop shadow to add when rendering.
 *
 *  If `nil` (the default), no drop shadow will be added.
 *
 *  @note The shadow parameters (especially `shadowOffset` and `shadowBlurRadius`)
 *        are expressed in the coordinate system of the original vector image,
 *        (i.e. the scale of the values are the same as those of the `nativeSize`),
 *        so that they are independant of the size the vector image will be rendered.
 */
@property(nonatomic, strong) NSShadow* shadow;

/**
 *  The insets (margins) to add to the vector image.
 *
 *  You may use this property to add margins around the vector image
 *  when you have set a `shadow`, to ensure its shadow won't be clipped.
 *  You may also use this property to translate the image or to remove
 *  margins (using negative values) that are too large in the original PDF.
 *
 *  @note The insets are expressed in the coordinate system of the original
 *        vector image (i.e. the scale of the values are the same as those of
 *        the `nativeSize`), so that they are independant of the size the
 *        vector image will be rendered.
 */
@property(nonatomic, assign) UIEdgeInsets insets;

/**
 *  If non-`nil`, this block will be called right before drawing the PDF
 *  onto the bitmap context. Will allows you to fully customize the graphic
 *  context for rendering, like applying an affine transform, etc.
 */
@property(nonatomic, copy) void(^prepareContextBlock)(CGContextRef ctx);

/**
 *  The size the Vector image was designed to be rendered in.
 */
@property(nonatomic, readonly) CGSize nativeSize;

#pragma mark - Constructor

/**
 *  Returns a vector image from loading the first page of the PDF file
 *  with the given name in the main bundle.
 *
 *  @param pdfName The name of the PDF file in the main bundle
 *
 *  @return The `OHVectorImage` corresponding to the first page of the PDF.
 *
 *  @note PDF images are cached.
 */
+ (instancetype)imageWithPDFNamed:(NSString*)pdfName;

/**
 *  Returns a vector image from loading the first page of the PDF file
 *  with the given name in the given bundle.
 *
 *  @param pdfName     The name of the PDF file in the main bundle
 *  @param bundleOrNil The bundle in which to search the image in.
 *                     If `nil`, will use the main bundle.
 *
 *  @return The `OHVectorImage` corresponding to the first page of the PDF.
 *
 *  @note PDF pages are cached, but requesting a `OHVectorImage` with the same name
 *        twice will still lead to a new `OHVectorImage` with independant tintColor
 *        and backgroundColor.
 */
+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
                         inBundle:(NSBundle*)bundleOrNil;

/**
 *  Returns a vector image from loading the first page of the PDF file
 *  at the given URL.
 *
 *  @param pdfURL The URL of the PDF file to load
 *
 *  @return The `OHVectorImage` corresponding to the first page of the PDF
 *
 *  @note PDF pages are cached, but requesting a `OHVectorImage` with the same name
 *        twice will still lead to a new `OHVectorImage` with independant `tintColor`
 *        and `backgroundColor`.
 */
+ (instancetype)imageWithPDFURL:(NSURL*)pdfURL;

/**
 *  Create a vector image from a PDF page
 *
 *  @param pdfPage The OHPDFPage to create the image from
 *
 *  @return The `OHVectorImage` corresponding to the given page of the PDF
 */
+ (instancetype)imageWithPDFPage:(OHPDFPage*)pdfPage;

#pragma mark - Rendering at a given size

/**
 *  Returns the horizontal and vertical scales to apply if we want
 *  to render the PDF image to the given size.
 *
 *  @param size The size to scale the image to.  
 *
 *  @return The scale to apply horizontally and vertically to the
 *          `nativeSize` of the original PDF so that it fill the
 *          given `size`.
 *
 *  @note This takes the vector image's `insets` into account
 *        when computing the scale.
 *
 *  @note The method `sizeThatFits` uses the `MIN(width, height)` of the
 *        `CGSize` returned by this method.
 */
- (CGSize)scaleForSize:(CGSize)size;

/**
 *  Returns the CGSize that would make the `OHVectorImage` fit in the
 *  given size while keeping its aspect ratio.
 *
 *  @param size The bounding box size in which the image should fit.  
 *              Use `CGFLOAT_MAX` for either of the dimensions to force
 *              fitting only on the other dimension (e.g. use
 *              `CGSizeMake(20, CGFLOAT_MAX)` to get the size that fits
 *              a width of 20 points).
 *
 *  @return The maximum size of the image so that it fits in the given
 *          size without changing its aspect ratio.
 *
 *  @note If the size contains fractional width or height, it is rounded
 *        to the smallest integer value (using `roundf`) to avoid subpixelling
 *        and blurry edges on the final image)
 */
- (CGSize)sizeThatFits:(CGSize)size;

/**
 *  Render the `OHVectorImage` as a bitmap image with the given size
 *
 *  @param size The size to render the image
 *
 *  @return The `UIImage` obtained by rendering the vector image to the given size.
 *
 *  @note This method uses the various `OHVectorImage`'s properties
 *        (`tintColor`, `backgroundColor`, `shadow`, `insets`) when rendering.
 *
 *  @note If the size contains fractional width or height, it is rounded
 *        to the smallest integer value (using `roundf`) to avoid subpixelling
 *        and blurry edges on the final image)
 */
- (UIImage*)renderAtSize:(CGSize)size;


/**
 *  Render the `OHVectorImage` as a bitmap image with a size fitting the given size
 *
 *  @param size The bounding box size to render the image in.  
 *              Use `CGFLOAT_MAX` for either of the dimensions to force
 *              fitting only on the other dimension (e.g. use
 *              `CGSizeMake(20, CGFLOAT_MAX)` to get the size that fits
 *              a width of 20 points).
 *
 *  @return The `UIImage` obtained by rendering the vector image to size fitting
 *          the given size.
 *
 *  @note This method is a convenience method that basically calls `renderAtSize:`
 *        with the size obtained by calling `sizeThatFits:` on the given size.
 *
 *  @note This method uses the various `OHVectorImage`'s properties
 *        (`tintColor`, `backgroundColor`, `shadow`, `insets`) when rendering.
 */
- (UIImage*)renderAtSizeThatFits:(CGSize)size;

@end
