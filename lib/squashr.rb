require 'open3'
require 'logger'


module Squashr

  class SourceDirNotFound  < StandardError; end
  class SourceNotDirectory < StandardError; end
  class TargetExists       < StandardError; end
  class CompressionFailed  < StandardError; end

  VERSION = "0.0.2"

  MKSQUASHFS_BIN = File.expand_path "../../ext/squashfs3.4/squashfs-tools/mksquashfs", __FILE__

  attr_accessor :logger

  module_function

  def log(message: message, level: Logger::INFO)
    return unless logger
    logger.send(level, message, "#{$PROGRAM_NAME}/squashfs")
  end

  def squash(source, target, options=[])
    raise SourceDirNotFound  unless File.exist?(source)
    raise SourceNotDirectory unless File.directory?(source)
    raise TargetExists       if     File.exist?(target)

    so, se, status = Open3.capture3 "#{MKSQUASHFS_BIN} #{source} #{target} #{options.join(' ')}"

    log message: so, level: Logger::DEBUG

    if status.success?
      log message: se, level: Logger::INFO
    else
      log message: "Squash fs failed", level: Logger::Error
      log message: se, level: Logger::Error
      raise CompressionFailed, se
    end
  end
end
