#!/usr/bin/ruby
# Setup Symlinks for easy development debugging
require 'fileutils'
require 'open3'

projectDirectory = File.expand_path(File.dirname(__FILE__) + "/../")
plugin = projectDirectory + "/CSSketch.sketchplugin"
frameworkPlugin = projectDirectory + "/External/SketchKit/SketchKit.sketchplugin"

pluginsFolder = File.expand_path("~/Library/Application Support/com.bohemiancoding.sketch3/Plugins")

pluginDestination = pluginsFolder + "/CSSketch.sketchplugin"
if File.exists?(pluginDestination) == true
	FileUtils.rm_r(pluginDestination)
end

if File.symlink(plugin, pluginDestination)  == false
	puts "Failed to make plugin symlink!"
	exit 1
end

puts "Made plugin symlink."