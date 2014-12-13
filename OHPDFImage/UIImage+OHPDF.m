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
#import "OHPDFDocument.h"
#import "OHPDFPage.h"

/***********************************************************************************/

@implementation UIImage (OHPDF)

+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
                             size:(CGSize)size
                        aspectFit:(BOOL)aspectFit;
{
    return [self imageWithPDFNamed:pdfName inBundle:nil size:size aspectFit:aspectFit];
}

+ (instancetype)imageWithPDFNamed:(NSString*)pdfName
                         inBundle:(NSBundle*)bundleOrNil
                             size:(CGSize)size
                        aspectFit:(BOOL)aspectFit
{
    static NSCache* pdfPagesCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pdfPagesCache = [NSCache new];
    });
    
    OHPDFPage* page = [pdfPagesCache objectForKey:pdfName];
    if (!page)
    {
        NSString* basename = [pdfName stringByDeletingPathExtension];
        NSString* ext = [pdfName pathExtension];
        if (ext.length == 0) ext = @"pdf";
        NSURL* url = [(bundleOrNil?:[NSBundle mainBundle]) URLForResource:basename withExtension:ext];
        OHPDFDocument* doc = [OHPDFDocument documentWithURL:url];
        page = [doc pageAtIndex:1];
        if (page)
        {
            [pdfPagesCache setObject:page forKey:pdfName];
        }
    }
    
    return [page imageWithSize:size aspectFit:aspectFit];
}

@end
