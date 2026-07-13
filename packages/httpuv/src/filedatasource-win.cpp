#ifdef _WIN32

#include "filedatasource.h"
#include "utils.h"
#include "winutils.h"
#include <Windows.h>
#include <limits>

// Windows gets a whole different implementation of FileDataSource
// so we can use FILE_FLAG_DELETE_ON_CLOSE, which is not available
// using the POSIX file functions.


FileDataSourceResult FileDataSource::initialize(const std::string& path, bool owned) {
  // This can be called from either the main thread or background thread.

  DWORD flags = FILE_FLAG_SEQUENTIAL_SCAN;
  if (owned)
    flags |= FILE_FLAG_DELETE_ON_CLOSE;


  _hFile = CreateFileW(utf8ToWide(path).data(),
                      GENERIC_READ,
                      FILE_SHARE_READ, // allow other processes to read
                      NULL, // security attributes
                      OPEN_EXISTING,
                      flags,
                      NULL);

  if (_hFile == INVALID_HANDLE_VALUE) {
    if (GetLastError() == ERROR_FILE_NOT_FOUND || GetLastError() == ERROR_PATH_NOT_FOUND) {
      _lastErrorMessage = "File does not exist: " + path + "\n";
      return FDS_NOT_EXIST;

    } else if (GetLastError() == ERROR_ACCESS_DENIED &&
               (GetFileAttributesA(path.c_str()) & FILE_ATTRIBUTE_DIRECTORY)) {
      // Note that the condition tested here has a potential race between the
      // CreateFile() call and the GetFileAttributesA() call. It's not clear
      // to me how to try to open a file and then detect if the file is a
      // directory, in an atomic operation. The probability of this race
      // condition is very low, and the result is relatively harmless for our
      // purposes: it will fall through to the generic FDS_ERROR path.
      _lastErrorMessage = "File data source is a directory: " + path + "\n";
      return FDS_ISDIR;

    } else {
      _lastErrorMessage = "Error opening file " + path + ": " + toString(GetLastError()) + "\n";
      return FDS_ERROR;
    }
  }


  if (!GetFileSizeEx(_hFile, &_length)) {
    CloseHandle(_hFile);
    _hFile = INVALID_HANDLE_VALUE;
    _lastErrorMessage = "Error retrieving file size for " + path + ": " + toString(GetLastError()) + "\n";
    return FDS_ERROR;
  }

  _remaining = static_cast<uint64_t>(_length.QuadPart);

  return FDS_OK;
}

bool FileDataSource::setRange(uint64_t offset, uint64_t length) {
  const uint64_t max_offset = static_cast<uint64_t>(std::numeric_limits<LONGLONG>::max());
  if (offset > max_offset || length > max_offset) {
    return false;
  }

  LARGE_INTEGER distance;
  distance.QuadPart = static_cast<LONGLONG>(offset);
  if (!SetFilePointerEx(_hFile, distance, NULL, FILE_BEGIN)) {
    return false;
  }

  _length.QuadPart = static_cast<LONGLONG>(length);
  _remaining = length;
  return true;
}

uint64_t FileDataSource::size() const {
  return static_cast<uint64_t>(_length.QuadPart);
}

uv_buf_t FileDataSource::getData(size_t bytesDesired) {
  ASSERT_BACKGROUND_THREAD()
  if (bytesDesired == 0 || _remaining == 0)
    return uv_buf_init(NULL, 0);

  uint64_t bytesToRead = static_cast<uint64_t>(bytesDesired);
  if (bytesToRead > _remaining) {
    bytesToRead = _remaining;
  }
  if (bytesToRead > static_cast<uint64_t>(MAXDWORD)) {
    bytesToRead = static_cast<uint64_t>(MAXDWORD);
  }

  char* buffer = (char*)malloc(static_cast<size_t>(bytesToRead));
  if (!buffer) {
    throw std::runtime_error("Couldn't allocate buffer");
  }

  DWORD bytesRead;
  if (!ReadFile(_hFile, buffer, static_cast<DWORD>(bytesToRead), &bytesRead, NULL)) {

    err_printf("Error reading: %d\n", GetLastError());
    free(buffer);
    throw std::runtime_error("File read failed");
  }

  _remaining -= static_cast<uint64_t>(bytesRead);

  return uv_buf_init(buffer, bytesRead);
}

void FileDataSource::freeData(uv_buf_t buffer) {
  free(buffer.base);
}

time_t FileTimeToTimeT(const FILETIME& ft) {
  ULARGE_INTEGER ull;
  ull.LowPart  = ft.dwLowDateTime;
  ull.HighPart = ft.dwHighDateTime;
  return ull.QuadPart / 10000000ULL - 11644473600ULL;
}

time_t FileDataSource::getMtime() {
  FILETIME ftWrite;

  if (!GetFileTime(_hFile, NULL, NULL, &ftWrite)) {
    return 0;
  }

  return FileTimeToTimeT(ftWrite);
}

void FileDataSource::close() {
  if (_hFile != INVALID_HANDLE_VALUE) {
    CloseHandle(_hFile);
    _hFile = INVALID_HANDLE_VALUE;
  }
}

std::string FileDataSource::lastErrorMessage() const {
  return _lastErrorMessage;
}


#endif // #ifdef _WIN32
