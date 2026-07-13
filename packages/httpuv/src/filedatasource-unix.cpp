#ifndef _WIN32

#include "filedatasource.h"
#include "utils.h"
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <limits>

FileDataSourceResult FileDataSource::initialize(const std::string& path, bool owned) {
  // This can be called from either the main thread or background thread.

  _fd = open(path.c_str(), O_RDONLY);
  if (_fd == -1) {
    if (errno == ENOENT) {
      _lastErrorMessage = "File does not exist: " + path + "\n";
      return FDS_NOT_EXIST;
    } else {
      _lastErrorMessage = "Error opening file " + path + ": " + toString(errno) + "\n";
      return FDS_ERROR;
    }
  }
  else {
    struct stat info = {0};
    if (fstat(_fd, &info)) {
      _lastErrorMessage = "Error opening path " + path + ": " + toString(errno) + "\n";
      ::close(_fd);
      return FDS_ERROR;
    }

    if (S_ISDIR(info.st_mode)) {
      _lastErrorMessage = "File data source is a directory: " + path + "\n";
      ::close(_fd);
      return FDS_ISDIR;
    }

    _length = info.st_size;
    _remaining = static_cast<uint64_t>(_length);

    if (owned && unlink(path.c_str())) {
      // Print this (on either main or background thread), since we're not
      // returning 1 to indicate an error.
      err_printf("Couldn't delete temp file %s: %d\n", path.c_str(), errno);
      // It's OK to continue
    }

    return FDS_OK;
  }
}

bool FileDataSource::setRange(uint64_t offset, uint64_t length) {
  const uint64_t max_offset = static_cast<uint64_t>(std::numeric_limits<off_t>::max());
  if (offset > max_offset || length > max_offset) {
    return false;
  }

  if (lseek(_fd, static_cast<off_t>(offset), SEEK_SET) == static_cast<off_t>(-1)) {
    return false;
  }

  _length = static_cast<off_t>(length);
  _remaining = length;
  return true;
}

uint64_t FileDataSource::size() const {
  return static_cast<uint64_t>(_length);
}

uv_buf_t FileDataSource::getData(size_t bytesDesired) {
  ASSERT_BACKGROUND_THREAD()
  if (bytesDesired == 0 || _remaining == 0)
    return uv_buf_init(NULL, 0);

  if (static_cast<uint64_t>(bytesDesired) > _remaining) {
    bytesDesired = static_cast<size_t>(_remaining);
  }

  char* buffer = (char*)malloc(bytesDesired);
  if (!buffer) {
    throw std::runtime_error("Couldn't allocate buffer");
  }

  ssize_t bytesRead = read(_fd, buffer, bytesDesired);
  if (bytesRead == -1) {
    err_printf("Error reading: %d\n", errno);
    free(buffer);
    throw std::runtime_error("File read failed");
  }

  _remaining -= static_cast<uint64_t>(bytesRead);

  return uv_buf_init(buffer, bytesRead);
}

void FileDataSource::freeData(uv_buf_t buffer) {
  free(buffer.base);
}

time_t FileDataSource::getMtime() {
  struct stat res;
  int retval = fstat(_fd, &res);
  if (retval == -1) {
    return 0;
  }
  return res.st_mtime;
}

void FileDataSource::close() {
  if (_fd != -1)
    ::close(_fd);
  _fd = -1;
}

std::string FileDataSource::lastErrorMessage() const {
  return _lastErrorMessage;
}


#endif // #ifndef _WIN32
