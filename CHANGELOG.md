# CHANGELOG

## 3.1.1

* Added compatiblity for people still building with Xcode 5 / SDK 7  
  _(`NS_DESIGNATED_INITIALIZER` was not yet defined back then)_

## 3.1.0

* Added `-renderAtSizeThatFits:` convenience method, as this is a common use case. (@colasjojo - #1)
* Added `-scaleForSize:` method (was private, exposed publicly).
* Fixed issue when using a translucent `backgroundColor` (like `[UIColor clearColor]`) (#2)  
  _(`backgroundColor != nil` generated an opaque image)_
* Fixed subpixelling issue when rendering. (#2)  
  _(`CGSize` with non-integral dimensions did generate blurry edges especially visible when using a `tintColor`)_
* Improved documentation

## 3.0.1

* Fixed an issue when passing `nil` to `OHVectorImage` initializers

## 3.0.0

* Added `shadow` and `insets` properties to `OHVectorImage`
* Renamed `imageWithSize:` to `renderAtSize:` _(to clarify API and avoid confusion with convenience initializers)_
* Refactor the code used to tint the image rendering _(to avoid tinting the shadow itself)_
* Added `<NSCopying>` conformance to `OHVectorImage`
* Using `NS_DESIGNATED_INITIALIZER`
* Improved documentation

## 2.0.1

* Code cleaning & reducing magic numbers in code.

## 2.0.0

* New API: Introducting `OHVectorImage` with `backgroundColor` and `tintColor` properties to customize the rendering.

## 1.0.0

* Initial version with basic API : `OHPDFDocument`, `OHPDFPage` and a `UIImage` category.
