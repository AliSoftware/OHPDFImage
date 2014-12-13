# OHPDFImage


[![Version](http://cocoapod-badges.herokuapp.com/v/OHPDFImage/badge.png)](http://cocoadocs.org/docsets/OHPDFImage)
[![Platform](http://cocoapod-badges.herokuapp.com/p/OHPDFImage/badge.png)](http://cocoadocs.org/docsets/OHPDFImage)
[![Build Status](https://travis-ci.org/AliSoftware/OHPDFImage.png?branch=master)](https://travis-ci.org/AliSoftware/OHPDFImage)


This library intends to easily load PDF documents to use them as images.

## Installation

The recommended way to install this library is using [CocoaPods](http://cocoapods.org). Simply add it to your `Podfile`:

```
pod 'OHPDFImage'
```

## Using a PDF as an image

If you simply intend to use a PDF as an image:

* Add the PDF to your project — as a resource included in your app target
* Use the following code to build an `UIImage` with the wanted size:

```objc
CGSize size =  self.imageView.bounds.size;
UIImage* image = [UIImage imageWithPDFNamed:@"NameOfPDFImage" size:someSize aspectFit:YES];
self.imageView.image = image;
```

This will load the PDF, and create an `UIImage` using the content of its first page, and render this image as a bitmap of the requested size.

The image will be scaled to the requested size with the assurance of using the vector image from the PDF document as source, assuring that the scaling is smooth.

> Note: This library also has methods to create the image as opaque or with a different scale (@1x/@2x/@3x) than the one of the current device (which is the default).

## Loading a PDF document

The main goal of this library is to use PDF as images using the `UIImage` category directly.

However, you can also use the `OHPDFDocument` and `OHPDFPage` classes to load a PDF document and get its pages, and render those pages individually, either as `UIImage` objects or directly in a graphic context (`CGContextRef`) you provide.

> Note: `UIImage` category methods are merely wrapper methods that loads an `OHPDFDocument` and its first `OHPDFPage` and renders it as `UIImage` objets.  
> However, the `UIImage` category methods have the advantages of caching the PDF pages into an `NSCache` so that you can request an image from the same PDF file multiple times with different sizes without having to load the PDF each time.

## License

This library is authored by Olivier Halligon and is distributed under the MIT License (see `LICENSE` file).
