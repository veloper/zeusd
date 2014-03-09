module Helpers

  def file_write(file, data, options = {})
    file.write(data)
    file.flush
    file.fsync
    sleep(0.1)
    file.rewind if options.fetch(:rewind, false)
    file
  end

end