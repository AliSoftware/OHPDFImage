# CHANGELOG

## 3.0.0

* Added `shadow` and `insets` properties to `OHVectorImage`
* Refactor the code used to tint the image rendering to be compatible with the shadow (especially avoid tinting the shadow itself)
* Added `<NSCopying>` conformance to `OHVectorImage`
* Improved documentation

## 2.0.1

* Code cleaning & reducing magic numbers in code.

## 2.0.0

* New API: Introducting `OHVectorImage` with `backgroundColor` and `tintColor` properties to customize the rendering.

## 1.0.0

* Initial version with basic API : `OHPDFDocument`, `OHPDFPage` and a `UIImage` category.
