#!/usr/bin/ruby

require 'fileutils'

# require XcodeBuild class
classesDirectory = File.expand_path(File.dirname(__FILE__) + "/Classes")
xcodeClassPath = File.expand_path("#{classesDirectory}/Xcode")
require xcodeClassPath

rootDirectory = File.expand_path(File.dirname(__FILE__) + "/../")
projectDirectory = rootDirectory + "/CSSketch Helper"
releaseDirectory = "#{rootDirectory}/Release"

releaseBuild = XcodeBuild.new(projectDirectory:projectDirectory,
target:"CSSketch Install",
configuration:"Release",
sdk:"macosx",
buildFolder:releaseDirectory)

# build device
if releaseBuild.build == false
	exit 1
end

Dir.chdir releaseDirectory do
	system "zip -r CSSketch_Install.zip \"./CSSketch Install.app/\""
end

system "open \"#{releaseDirectory}\""

puts "Release built"