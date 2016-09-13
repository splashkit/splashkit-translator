#
# Logging module
#
module Logger
  #
  # Defines variables
  #
  def warnings
    @@warnings ||= []
  end

  #
  # Defines errors
  #
  def errors
    @@errors ||= []
  end

  private

  #
  # Warning in parser
  #
  def warn(msg)
    warnings << msg
  end

  #
  # Error in parser
  #
  def error(msg)
    errors << msg.to_s
  end
end
