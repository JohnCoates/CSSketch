require 'open3'
def syscall(*cmd)
  begin
    # puts "Syscall: #{cmd}"
    stdout, stderr, status = Open3.capture3(*cmd)
    status.success? && stdout.slice!(0..-(1 + $/.size)) # strip trailing eol
  rescue
    puts "Error with command: #{cmd}"
  end
end


class XcodeBuild
  attr_reader :buildFolder

  def initialize(projectDirectory:nil, target:nil, configuration:"Release", sdk:"iphoneos", buildFolder:"Release")
    @projectDirectory = projectDirectory
    @target = target
    @configuration = configuration
    @sdk = sdk
    @buildFolder = buildFolder

    if projectDirectory == nil || target == nil
      puts "Error: Invalid projectDirectory or target passed to XcodeBuild"
      exit
    end
  end

  def build()
    Dir.chdir @projectDirectory do
      xcPrettyPath = syscall "which xcpretty"
      if xcPrettyPath
        useXCPRetty = true
      else
        useXCPRetty = false
      end

      puts "Building target #{@target}, configuration: #{@configuration}, sdk: #{@sdk} directory: #{@projectDirectory}, build folder:#{@buildFolder}"

      command = [
      "xcodebuild",
      "-target \"#{@target}\"",
      "-configuration", @configuration,
      "-sdk", @sdk,
      "build",
      "CONFIGURATION_BUILD_DIR=\"#{@buildFolder}\"",
      "CONFIGURATION_TEMP_DIR=\"#{@buildFolder}/temp\"",
      "BUILD_DIR=\"#{@buildFolder}\"",
      "PROJECT_TEMP_DIR=\"#{@buildFolder}/tempProject\"",
      "OBJROOT=\"#{@buildFolder}/Build\""
      ]

      if useXCPRetty
        # add to begining
        command.unshift "set -o pipefail && "

        command.push "| xcpretty -c -s"
      end

      command = command.join " "
      
      puts command



      # strip coloring for code runner
      if useXCPRetty && ENV['TERM_PROGRAM'] == "CodeRunner"
        command = command + " --no-color"
      end
      system command
      exitstatus = $?.exitstatus
      if exitstatus == 0
        return true
      else
        return false
      end
    end # project directory


  end

  def buildSetting(settingName)
    if !@buildSettings
      retrieveProperties
    end

    if !@buildSettings
      puts "Error: Couldn't read build settings for #{@target}"
      exit
    end

    if !@buildSettings[settingName]
      puts "Error: Couldn't get build setting #{settingName}"
      exit
    end

    return @buildSettings[settingName]
  end

  def retrieveProperties()
    Dir.chdir @projectDirectory do
      command = [
      "xcodebuild",
      "-target", @target,
      "-configuration", @configuration,
      "-sdk", @sdk,
      "build",
      "CONFIGURATION_BUILD_DIR=\"#{@buildFolder}\"",
      "OBJROOT=\"#{@buildFolder}/Build\"",
      "-showBuildSettings"].join " "

      xcodeRawBuildSettings = syscall command

      if !xcodeRawBuildSettings
        puts "Error: Couldn't get settings for #{@target}"
        exit;
      end

      # get xcode variables
      # taken from https://gist.github.com/Cocoanetics/6765089
      xcodeBuildSettings = Hash.new
      # pattern for each line
      linePattern = Regexp.new(/^\s*(.*?)\s=\s(.*)$/)
      # extract the variables
      xcodeRawBuildSettings.each_line do |line|
        match = linePattern.match(line)
        #store found variable in hash
        if (match)
          xcodeBuildSettings[match[1]] = match[2]
        end
      end
      @buildSettings = xcodeBuildSettings
    end # project directory

    return @buildSettings
  end # retrieveProperties

  def executableOutputPath()
    # get executable path
  	executablePath = buildSetting 'EXECUTABLE_PATH'

  	if !executablePath
  		puts "Error: Couldn't get variable EXECUTABLE_PATH for target #{@target}"
  		exit 1
  	end

    outputPath = "#{@buildFolder}/#{executablePath}"
    outputPath = File.expand_path(outputPath)

    if File.exists?(outputPath) == false
      puts "Error: Build binary missing from #{outputPath}!"
      exit 1
    end

    return outputPath
  end

  # signs executable file, returns path of executable file
  def signExecutableOutput(entitlementsPath = nil)
    executablePath = executableOutputPath
    # sign with entitlements
    if signBinary(executablePath, entitlementsPath) == false
      puts "failed to sign binary @ #{stagingBinary}"
      exit 1
    end

    return executablePath
  end

end # XcodeBuild

module Xcode
	def self.build(target:nil, configuration:"Release", sdk:"iphoneos", buildFolder:"Release")
		xcPrettyPath = syscall "which xcpretty"
		if xcPrettyPath
			useXCPRetty = true
		else
			useXCPRetty = false
		end

		command = [
		"xcodebuild",
		"-target=\"#{target}\"",
		"-configuration", configuration,
		"-sdk", sdk,
		"build",
		"CONFIGURATION_BUILD_DIR=\"#{buildFolder}\"",
		"CONFIGURATION_TEMP_DIR=\"#{buildFolder}/temp\"",
		"BUILD_DIR=\"#{buildFolder}\"",
		"PROJECT_TEMP_DIR=\"#{buildFolder}/tempProject\"",
		"OBJROOT=\"#{buildFolder}/Build\""
		]

		if useXCPRetty
			# add to begining
			command.unshift "set -o pipefail && "

			command.push "| xcpretty -c -s"
		end

		command = command.join " "

		# strip coloring for code runner
		if useXCPRetty && ENV['TERM_PROGRAM'] == "CodeRunner"
			command = command + " --no-color"
		end
		system command
		exitstatus = $?.exitstatus
		if exitstatus == 0
			return true
		else
			return false
		end
	end

	def self.getVariables(target:nil, configuration:"Release", sdk:"iphoneos", buildFolder:"Release")
		xcodeRawBuildSettings = syscall "xcodebuild",
		"-target \"#{target}\"",
		"-configuration", configuration,
		"-sdk", sdk,
		"build",
		"CONFIGURATION_BUILD_DIR=#{buildFolder}",
		"OBJROOT=#{buildFolder}/Build",
		"-showBuildSettings"

		if !xcodeRawBuildSettings
			puts "Error, couldn't get settings!"
		end

		# get xcode variables
		# taken from https://gist.github.com/Cocoanetics/6765089
		xcodeBuildSettings = Hash.new
		# pattern for each line
		linePattern = Regexp.new(/^\s*(.*?)\s=\s(.*)$/)
		# extract the variables
		xcodeRawBuildSettings.each_line do |line|
			match = linePattern.match(line)
			#store found variable in hash
			if (match)
				xcodeBuildSettings[match[1]] = match[2]
			end
		end
		return xcodeBuildSettings
	end
end
