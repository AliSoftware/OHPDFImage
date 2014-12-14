# OHPDFImage


[![Version](http://cocoapod-badges.herokuapp.com/v/OHPDFImage/badge.png)](http://cocoadocs.org/docsets/OHPDFImage)
[![Platform](http://cocoapod-badges.herokuapp.com/p/OHPDFImage/badge.png)](http://cocoadocs.org/docsets/OHPDFImage)
[![Build Status](https://travis-ci.org/AliSoftware/OHPDFImage.png?branch=master)](https://travis-ci.org/AliSoftware/OHPDFImage)


This library intends to easily load PDF documents to use them as vector images.

## Installation

The recommended way to install this library is using [CocoaPods](http://guides.cocoapods.org). Simply add it to your `Podfile`:

```
pod 'OHPDFImage'
```

## Using a PDF as an image

First, add the PDF to your project — as a resource included in your app target.

### Use the `UIImage` category

If you simply intend to use the PDF as an image as-is, you can use:

```objc
self.imageView.image = [UIImage imageWithPDFNamed:@"NameOfPDFImage"
                                        fitInSize:self.imageView.bounds.size];
```

This will load the PDF, use its first page to create an `OHVectorImage`, then rasterize this vector image as an `UIImage` of the requested size, ensuring to keep its aspect ratio.

> Note: PDF pages are cached, so that requesting an image with the same PDF name, even with a different size, will use the cached version of the PDF instead of loading it again from disk. Thus, only the rasterization into a bitmap image is recreated.

### Use the `OHVectorImage` class for more control

If you need more control on the vector image, you can directly manipulate `OHVectorImage` objects.
Here is what you can do when using `OHVectorImage`:

#### Force the size without keeping the aspect ratio

When you call `[OHVectorImage imageWithSize:]` with the expected size, it does not try to keep the aspect ratio, and simply use the given size as-is.

On the contrary, if you want to ensure to keep the aspect ratio of the original PDF, you can compute the size that fits a given size using `[OHVectorImage sizeThatFits:]`, and then use this size when calling `imageWithSize:`.  
_(This is actually what `+[UIImage imageWithPDFNamed:fitInSize:]` does internally)_

#### Change the background color of the generated image

You can use the `backgroundColor` property to change the background color of the rendered image.  
A `nil` `backgroundColor` will generate a transparent `UIImage`, while a non-`nil` `backgroundColor` will generate an opaque `UIImage` with the given background color.

#### Re-tint the image

You can use the `tintColor` property to recolor the vector image, so that the vector graphics are merely used as a mask and rendered using a new color.

In such case, the generated image will only use the alpha channel of the PDF vector image. It will fill the opaque parts of the PDF with the `tintColor`, keep the transparent parts transparent, and fill semi-transparent parts depending on their alpha value.

#### Complete Example

```objc
OHVectorImage* vImage = [OHVectorImage imageWithPDFNamed:imageName];
CGSize fitSize = [vImage sizeThatFits:imageSize]; // Ensure to keep aspect ratio
vImage.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:1.0];
vImage.tintColor = [UIColor redColor];
image = [vImage imageWithSize:fitSize];
```


## Loading a PDF document

The main goal of this library is to use PDF as images using the `UIImage` category or `OHVectorImage` class directly.

However, you can also use the `OHPDFDocument` and `OHPDFPage` classes to load a PDF document and get its pages, and render those pages individually in a graphic context (`CGContextRef`) you provide.

You can also use this to fetch an arbitrary page of a given PDF to generate a vector image (instead of using the first page, which is the default):

```objc
NSURL* pdfURL = …
OHPDFDocument* doc = [OHPDFDocument documentWithURL:pdfURL];
OHPDFPage* page = [doc pageAtIndex:3]; // Note: page indexes starts at 1
OHVectorImage* vImage = [OHVectorImage imageWithPDFPage:page];
```

## License

This library is authored by Olivier Halligon and is distributed under the MIT License (see `LICENSE` file).
