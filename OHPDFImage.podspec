Pod::Spec.new do |s|

  s.name         = 'OHPDFImage'
  s.version      = '3.1.3'
  s.summary      = "OHPDFImage allows you to use a PDF as a vector UIImage"

  s.description  = <<-DESC
                   OHPDFImage will open PDF files and make it easy to access
                   each page of the PDF as a vector image, then render it as
                   an UIImage of any size.

                   This will allow you to use PDF files as vector images in
                   your applications, and ensure smooth resizing at any size.
                   DESC

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Olivier Halligon' => 'olivier.halligon+ae@gmail.com' }
  s.homepage     = 'http://github.com/AliSoftware/OHPDFImage'
  
  s.platform     = :ios, '5.0'

  s.source       = { :git => 'https://github.com/AliSoftware/OHPDFImage.git', :tag => s.version.to_s }

  s.source_files  = 'OHPDFImage/**/*.{h,m}'
  

  s.frameworks = 'QuartzCore', 'UIKit'

  s.requires_arc = true

end

