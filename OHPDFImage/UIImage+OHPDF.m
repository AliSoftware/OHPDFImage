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

#import "UIImage+OHPDF.h"
#import "OHVectorImage.h"

/***********************************************************************************/

@implementation UIImage (OHPDFImage)

+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
                        fitInSize:(CGSize)size;
{
    return [self imageWithPDFNamed:pdfName inBundle:nil fitInSize:size];
}


+ (instancetype)imageWithPDFNamed:(NSString *)pdfName
                      fitInHeight:(CGFloat)height
{
    CGSize size = CGSizeMake(CGFLOAT_MAX, height) ;
    
    return [self imageWithPDFNamed:pdfName fitInSize:size] ;
}


+ (instancetype)imageWithPDFNamed:(NSString *)pdfName
                      fitInWidth:(CGFloat)width
{
    CGSize size = CGSizeMake(width, CGFLOAT_MAX) ;
    
    return [self imageWithPDFNamed:pdfName fitInSize:size] ;
}


+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
                         inBundle:(NSBundle*)bundleOrNil
                        fitInSize:(CGSize)size
{
    OHVectorImage* vImage = [OHVectorImage imageWithPDFNamed:pdfName inBundle:bundleOrNil];
    CGSize fitSize = [vImage sizeThatFits:size];
    return [vImage renderAtSize:fitSize];
}

@end
