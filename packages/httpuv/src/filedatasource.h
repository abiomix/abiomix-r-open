#ifndef FILEDATASOURCE_H
#define FILEDATASOURCE_H

#include "uvutil.h"


// Status codes for FileDataSource::initialize().
enum FileDataSourceResult {
  FDS_OK = 0,     // Initialization worked
  FDS_NOT_EXIST,    // File did not exist
  FDS_ISDIR,      // File is a directory
  FDS_ERROR       // Other error
};


class FileDataSource : public DataSource {
#ifdef _WIN32
  HANDLE _hFile;
  LARGE_INTEGER _length;
#else
  int _fd;
  off_t _length;
#endif
  uint64_t _remaining;
  std::string _lastErrorMessage;

public:
  FileDataSource() : _remaining(0) {
#ifdef _WIN32
    _hFile = INVALID_HANDLE_VALUE;
#else
    _fd = -1;
#endif
  }

  ~FileDataSource() {
    close();
  }

  FileDataSourceResult initialize(const std::string& path, bool owned);
  bool setRange(uint64_t offset, uint64_t length);
  uint64_t size() const;
  uv_buf_t getData(size_t bytesDesired);
  void freeData(uv_buf_t buffer);
  // Get the mtime of the file. If there's an error, return 0.
  time_t getMtime();
  void close();
  std::string lastErrorMessage() const;
};

#endif // FILEDATASOURCE_H
