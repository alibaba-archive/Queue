#
#  Created by teambition-ios on 2020/7/27.
#  Copyright © 2020 teambition. All rights reserved.
#     

Pod::Spec.new do |s|
  s.name             = 'TBQueue'
  s.version          = '2.0.0'
  s.summary          = 'a task queue with local persistent by Swift'
  s.description      = <<-DESC
  a task queue with local persistent by Swift.
                       DESC

  s.homepage         = 'https://github.com/teambition/Queue'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'teambition mobile' => 'teambition-mobile@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/teambition/Queue.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'Queue/*.swift'

end
