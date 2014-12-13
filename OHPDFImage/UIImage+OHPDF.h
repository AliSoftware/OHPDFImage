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

/***********************************************************************************/

@interface UIImage (OHPDF)
/**
 *  Returns an UIImage build from loading the first page of the PDF file
 *  with the given name in the main bundle and rendering it as the given size
 *
 *  @param pdfName The name of the PDF file in the main bundle
 *  @param size    The size at which to render the image.
 *                 If CGSizeZero, it will be rendered using the PDF's MediaBox
 *  @param aspectFit If YES, the image will keep its original aspect ratio
 *                   to fit in the size provided
 *
 *  @return The UIImage corresponding to the first page of the PDF rendered at the given size.
 *
 *  @note PDF Images are cached so that requesting it a second time with a different size will
 *        not load the PDF file again.
 */
+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
                             size:(CGSize)size
                        aspectFit:(BOOL)aspectFit;

/**
 *  Returns an UIImage build from loading the first page of the PDF file
 *  with the given name in the given bundle and rendering it as the given size
 *
 *  @param pdfName The name of the PDF file in the main bundle
 *  @param bundleOrNil The bundle in which to search the image in. If nil, will use the main bundle.
 *  @param size    The size at which to render the image.
 *                 If CGSizeZero, it will be rendered using the PDF's MediaBox
 *  @param aspectFit If YES, the image will keep its original aspect ratio
 *                   to fit in the size provided
 *
 *  @return The UIImage corresponding to the first page of the PDF rendered at the given size.
 *
 *  @note PDF Images are cached so that requesting it a second time with a different size will
 *        not load the PDF file again.
 */
+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
                         inBundle:(NSBundle*)bundleOrNil
                             size:(CGSize)size
                        aspectFit:(BOOL)aspectFit;
@end
