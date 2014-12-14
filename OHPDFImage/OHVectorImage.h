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

@interface OHVectorImage : NSObject

#pragma mark - Properties

/**
 *  The color to tint the image with.
 *
 *  - If nil (the default), no special tint is applied.
 *  - If non-nil, the image will be recolored entierly using this color.
 *    In that case, only the alpha component or the image is used
 */
@property(nonatomic, strong) UIColor* tintColor;

/**
 *  The background color to apply to the image when rendering into an UIImage.
 *  If nil (the default), the image will have transparent background.
 */
@property(nonatomic, strong) UIColor* backgroundColor;

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
 *  @return The OHVectorImage corresponding to the first page of the PDF.
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
 *                     If nil, will use the main bundle.
 *
 *  @return The OHVectorImage corresponding to the first page of the PDF.
 *
 *  @note PDF pages are cached, but requesting a OHVectorImage with the same name
 *        twice will still lead to a new OHVectorImage with independant tintColor
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
 *  @return The OHVectorImage corresponding to the first page of the PDF
 *
 *  @note PDF pages are cached, but requesting a OHVectorImage with the same name
 *        twice will still lead to a new OHVectorImage with independant tintColor
 *        and backgroundColor.
 */
+ (instancetype)imageWithPDFURL:(NSURL*)pdfURL;

/**
 *  Create a vector image from a PDF page
 *
 *  @param pdfPage The OHPDFPage to create the image from
 *
 *  @return The OHVectorImage corresponding to the given page of the PDF
 */
+ (instancetype)imageWithPDFPage:(OHPDFPage*)pdfPage;

#pragma mark - Rendering

/**
 *  Returns the CGSize that would make the OHVectorImage fit in the
 *  given size while keeping its aspect ratio.
 *
 *  @param size The bounding box size in which the image should fit
 *
 *  @return The maximum size of the image so that it fits in the given
 *          size without changing its aspect ratio.
 */
- (CGSize)sizeThatFits:(CGSize)size;

/**
 *  Render the OHVectorImage as a bitmap image with the given size
 *
 *  @param size The size to render the image
 *
 *  @return The UIImage obtained by rendering the vector image to the given size.
 *
 *  @note This method uses the `tintColor` and `backgroundColor` when rendering.
 */
- (UIImage*)imageWithSize:(CGSize)size;
@end
