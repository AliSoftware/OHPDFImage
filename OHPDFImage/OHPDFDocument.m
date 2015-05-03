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

@interface OHPDFDocument()
- (instancetype)initWithRef:(CGPDFDocumentRef)docRef NS_DESIGNATED_INITIALIZER;
@end

@implementation OHPDFDocument

#pragma mark - Constructors

+ (instancetype)documentWithData:(NSData *)data
{
    if (!data) return nil;
    CGDataProviderRef dataRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    if (!dataRef) return nil;
    CGPDFDocumentRef docRef = CGPDFDocumentCreateWithProvider(dataRef);
    CGDataProviderRelease(dataRef);
    
    if (!docRef) return nil;
    OHPDFDocument* doc = [self documentWithRef:docRef];
    CGPDFDocumentRelease(docRef);
    
    return doc;
}


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
    return [[self alloc] initWithRef:docRef];
}

- (instancetype)initWithRef:(CGPDFDocumentRef)docRef
{
    self = [super init];
    if (self)
    {
        CGPDFDocumentRetain(docRef);
        _documentRef = docRef;
        _pagesCount = CGPDFDocumentGetNumberOfPages(docRef);
    }
    return self;
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
