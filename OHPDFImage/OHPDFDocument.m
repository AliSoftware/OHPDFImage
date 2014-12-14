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

#import "OHPDFDocument.h"
#import "OHPDFPage.h"

/***********************************************************************************/

@implementation OHPDFDocument

#pragma mark - Constructors

+ (instancetype)documentWithURL:(NSURL*)url
{
    CGPDFDocumentRef docRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    OHPDFDocument* doc = nil;
    if (docRef)
    {
        doc = [self documentWithRef:docRef];
        CGPDFDocumentRelease(docRef);
    }
    return doc;
}

+ (instancetype)documentWithRef:(CGPDFDocumentRef)docRef
{
    OHPDFDocument* doc = [self new];
    CGPDFDocumentRetain(docRef);
    doc->_documentRef = docRef;
    doc->_pagesCount = CGPDFDocumentGetNumberOfPages(docRef);
    return doc;
}

- (void)dealloc
{
    if (_documentRef)
    {
        CGPDFDocumentRelease(_documentRef);
        _documentRef = nil;
    }
}

#pragma mark - Getting a page

- (OHPDFPage*)pageAtIndex:(size_t)pageNumber
{
    if (pageNumber > 0 && pageNumber <= _pagesCount)
    {
        CGPDFPageRef pageRef = CGPDFDocumentGetPage(_documentRef, pageNumber);
        if (pageRef)
        {
            return [OHPDFPage pageWithRef:pageRef];
        }
    }
    return nil;
}

@end
