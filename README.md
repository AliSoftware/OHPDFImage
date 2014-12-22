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

## Adding PDF files to your project

If you intend to use a PDF as a vector image, you should add it as a resource in your project. Especially, you should **NOT** add the PDF in you `Images.xcassets` Assets Catalog.

#### Don't use Assets Catalog for PDF files

Xcode 6 accept PDF files to be added to an Assets Catalog, but when you do so, it in fact re-create PNG assets at compile time, embedding the rasterized bitmaps in the final application instead of embedding the original PDF vector image. That's why you should add the PDF file as a standard resource and not in the `xcassets` catalog.

#### Exporting PDF files from Photoshop

If your vector image has been created using Photoshop and you intend to export it as PDF, you may choose the "Save As…" menu item and choose the "Photoshop PDF" file format to create the PDF.  
In that case, be careful to select the **"High Quality Print" preset**, which is the only preset that conserve the PDF transparency / alpha channel.

## Using a PDF as an image

### The `UIImage` category

If you simply intend to use the PDF as an image as-is, you can use:

```objc
self.imageView.image = [UIImage imageWithPDFNamed:@"vector_image"
                                        fitInSize:self.imageView.bounds.size];
```

This will load the PDF, use its first page to create an `OHVectorImage`, then rasterize this vector image as an `UIImage` of the requested size, ensuring to keep its aspect ratio.

> Note: PDF pages are cached, so that requesting an image with the same PDF name, even with a different size, will use the cached version of the PDF instead of loading it again from disk. Thus, only the rasterization into a bitmap image is recreated.

### More control with the `OHVectorImage` class

If you need more options on how the vector image will be rendered, you can directly manipulate `OHVectorImage` objects. Here is what you can do when using `OHVectorImage`:

* **Change the background color** of the generated image using the `backgroundColor` property (`nil` to generate transparent images);
* **Re-tint the image** using the `tintColor` property (in that case the PDF is merely used as a mask for which only its alpha channel is used);
* **Add a drop shadow** using the `shadow` property (a `NSShadow` object that lets you customize the shadow offset, blur radius and color);
* **Add insets** (`UIEdgeInsets`) to the image when rendering:
  * either to translate the image to any direction,
  * or to add margins to the image (useful when you add a drop shadow to ensure it is not clipped),
  * or to reduce/remove margins present in the original PDF (by using negative insets)
  * ...
* **Customize the graphic context** before the vector image is rendered, using the `prepareContextBlock` property
  * This is mostly intended for advanced usage, like applying a custom transform or adding a custom clipping path to the `CGContextRef` before rendering the PDF vector image.

#### Drop shadow and insets

Drop shadow values (offset and blur radius) as well as insets are expressed in the coordinate system of the vector image (i.e. with the same scale as when the vector image is rendered using its `nativeSize`), so that they can be resolution-independant.

This way, if you add a drop shadow with `shadowOffset = (CGSize){2,2}` and `blurRadius = 3` then you can safely use an `inset = (UIEdgeInsets){ .right = 5, .bottom = 5 }` to ensure the shadow won't be clipped, without worrying about the size at which the image will be rendered.

#### Keeping aspect ratio

* When you call `-[OHVectorImage renderAtSize:]` with the expected size, it does not try to keep the aspect ratio, and simply use the given size as-is, stretching the image if necessary ("Scale to Fill" behavior).

* If you want to keep the aspect ratio of the original PDF, you can compute the size that fits a given size using `-[OHVectorImage sizeThatFits:]` first, and then use this size when calling `-[OHVectorImage renderAtSize:]`.

> _Note: This is actually what `+[UIImage imageWithPDFNamed:fitInSize:]` does internally._

The `sizeThatFits:` method takes the vector image's `insets` property into account when computing the fitting size — as these `insets` values will be applied when rendering as well.

* As wanting to keep the aspect ratio is a quite common case, a convenience method `-[OHVectorImage renderAtSizeThatFits:]` is provided that simply calls the two aforementioned methods one after the other.

* You may also use the `-[OHVectorImage scaleForSize:]` method that returns a `CGSize` containing the scale factors (both horizontal and vertical) to apply to scale the vector image to the given size. This basically returns the result of dividing the given `size` by the vector image's `nativeSize`, but also taking the `insets` into account.

> Note: `sizeThatFits:` actually uses `MIN(width, height)` of these scale factors to determine the scale factor to "aspect fit" the image in the provided size. If you instead need to scale the image so it does an "aspect fill" scaling — cropping the image if necessary to fill the whole size — you may instead use `MAX(width, height)` to compute the scale and thus the size at which to render the image.

#### Example

```objc
OHVectorImage* vImage = [OHVectorImage imageWithPDFNamed:@"vector_image"];
vImage.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:1.0];
vImage.tintColor = [UIColor redColor];
// Shadow & Insets
vImage.shadow = [NSShadow new];
vImage.shadow.shadowOffset = CGSizeMake(2,2);
vImage.shadow.shadowBlurRadius = 3.f;
vImage.shadow.shadowColor = [UIColor darkGrayColor];
vImage.insets = UIEdgeInsetsMake(0,0,5,5);
// Render as an UIImage, ensuring to keep aspect ratio
UIImage* image = [vImage renderAtSizeThatFits:imageViewSize];
```

A complete example is also available in the Demo project provided in this repo.
Don't hesitate to try it (you may use `pod try OHPDFImage` to give it a try even if you haven't cloned the repo yet!)

## Loading a PDF document

The main goal of this library is to use PDF as images using the `UIImage` category or `OHVectorImage` class directly.

However, you can also use the `OHPDFDocument` and `OHPDFPage` classes to load a PDF document and get its pages, and render those pages individually in a graphic context (`CGContextRef`) you provide.

You can also use this to fetch an arbitrary page of a given PDF to generate a vector image (instead of using the first page, which is the default).  
For example, the following code read every page of a PDF as a vector image and build an animated `UIImage` from it:

```objc
NSURL* pdfURL = [[NSBundle mainBundle] URLForResource:@"vector_images" withExtension:@"pdf"];
OHPDFDocument* doc = [OHPDFDocument documentWithURL:pdfURL];
NSMutableArray* frames = [NSMutableArray arrayWithCapacity:doc.pagesCount];
CGSize frameSize = CGSizeMake(100,100);
for(size_t pageNum = 0; pageNum < doc.pagesCount; ++pageNum)
{
  OHPDFPage* page = [doc pageAtIndex:pageNum+1]; // Note: page indexes start at 1
  OHVectorImage* vImage = [OHVectorImage imageWithPDFPage:page];
  [frames addObject:[vImages renderAtSize:frameSize]];
}

NSTimeInterval duration = doc.pagesCount * 2.0; // 2.0s per frame 
UIImage* animatedImage = [UIImage animatedImageWithImages:frames
                                                 duration:duration];
```

## License

This library is authored by Olivier Halligon and is distributed under the MIT License (see `LICENSE` file).
