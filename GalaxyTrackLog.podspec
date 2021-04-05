Pod::Spec.new do |s|
  s.name          = "GalaxyTrackLog"
  s.version       = "0.0.1"
  s.summary       = "iOS SDK tracking event Galaxy"
  s.description   = "Using for iOS tracking event Galaxy"
  s.homepage      = "https://github.com/peteranny/"
  s.license       = "MIT"
  s.author        = "DungVu"
  s.source        = {
    :git => "https://github.com/dung00275/GalaxyTrackLog.git"
  }
  s.platform      = :ios, "10.0"
  s.source_files        = "GalaxyTrackLog/*.{h,m,swift}"
  s.public_header_files = "GalaxyTrackLog/*.h"
end
