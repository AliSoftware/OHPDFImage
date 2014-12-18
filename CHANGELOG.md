# CHANGELOG

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
