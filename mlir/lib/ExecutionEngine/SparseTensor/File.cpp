//===- File.cpp - Reading/writing sparse tensors from/to files ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements reading and writing sparse tensor files.
//
//===----------------------------------------------------------------------===//

#include "mlir/ExecutionEngine/SparseTensor/File.h"

#include <cctype>
#include <cstring>

using namespace mlir::sparse_tensor;

/// Opens the file for reading.
void SparseTensorReader::openFile() {
  if (file) {
    fprintf(stderr, "Already opened file %s\n", filename);
    exit(1);
  }
  file = fopen(filename, "r");
  if (!file) {
    fprintf(stderr, "Cannot find file %s\n", filename);
    exit(1);
  }
}

/// Closes the file.
void SparseTensorReader::closeFile() {
  if (file) {
    fclose(file);
    file = nullptr;
  }
}

/// Attempts to read a line from the file.
void SparseTensorReader::readLine() {
  if (!fgets(line, kColWidth, file)) {
    fprintf(stderr, "Cannot read next line of %s\n", filename);
    exit(1);
  }
}

/// Reads and parses the file's header.
void SparseTensorReader::readHeader() {
  assert(file && "Attempt to readHeader() before openFile()");
  if (strstr(filename, ".mtx")) {
    readMMEHeader();
  } else if (strstr(filename, ".tns")) {
    readExtFROSTTHeader();
  } else {
    fprintf(stderr, "Unknown format %s\n", filename);
    exit(1);
  }
  assert(isValid() && "Failed to read the header");
}

/// Asserts the shape subsumes the actual dimension sizes.  Is only
/// valid after parsing the header.
void SparseTensorReader::assertMatchesShape(uint64_t rank,
                                            const uint64_t *shape) const {
  assert(rank == getRank() && "Rank mismatch");
  for (uint64_t r = 0; r < rank; r++)
    assert((shape[r] == 0 || shape[r] == idata[2 + r]) &&
           "Dimension size mismatch");
}

bool SparseTensorReader::canReadAs(PrimaryType valTy) const {
  switch (valueKind_) {
  case ValueKind::kInvalid:
    assert(false && "Must readHeader() before calling canReadAs()");
    return false; // In case assertions are disabled.
  case ValueKind::kPattern:
    return true;
  case ValueKind::kInteger:
    // When the file is specified to store integer values, we still
    // allow implicitly converting those to floating primary-types.
    return isRealPrimaryType(valTy);
  case ValueKind::kReal:
    // When the file is specified to store real/floating values, then
    // we disallow implicit conversion to integer primary-types.
    return isFloatingPrimaryType(valTy);
  case ValueKind::kComplex:
    // When the file is specified to store complex values, then we
    // require a complex primary-type.
    return isComplexPrimaryType(valTy);
  case ValueKind::kUndefined:
    // The "extended" FROSTT format doesn't specify a ValueKind.
    // So we allow implicitly converting the stored values to both
    // integer and floating primary-types.
    return isRealPrimaryType(valTy);
  }
  fprintf(stderr, "Unknown ValueKind: %d\n", static_cast<uint8_t>(valueKind_));
  return false;
}

/// Helper to convert C-style strings (i.e., '\0' terminated) to lower case.
static inline void toLower(char *token) {
  for (char *c = token; *c; c++)
    *c = tolower(*c);
}

/// Idiomatic name for checking string equality.
static inline bool streq(const char *lhs, const char *rhs) {
  return strcmp(lhs, rhs) == 0;
}

/// Idiomatic name for checking string inequality.
static inline bool strne(const char *lhs, const char *rhs) {
  return strcmp(lhs, rhs); // aka `!= 0`
}

/// Read the MME header of a general sparse matrix of type real.
void SparseTensorReader::readMMEHeader() {
  char header[64];
  char object[64];
  char format[64];
  char field[64];
  char symmetry[64];
  // Read header line.
  if (fscanf(file, "%63s %63s %63s %63s %63s\n", header, object, format, field,
             symmetry) != 5) {
    fprintf(stderr, "Corrupt header in %s\n", filename);
    exit(1);
  }
  // Convert all to lowercase up front (to avoid accidental redundancy).
  toLower(header);
  toLower(object);
  toLower(format);
  toLower(field);
  toLower(symmetry);
  // Process `field`, which specify pattern or the data type of the values.
  if (streq(field, "pattern")) {
    valueKind_ = ValueKind::kPattern;
  } else if (streq(field, "real")) {
    valueKind_ = ValueKind::kReal;
  } else if (streq(field, "integer")) {
    valueKind_ = ValueKind::kInteger;
  } else if (streq(field, "complex")) {
    valueKind_ = ValueKind::kComplex;
  } else {
    fprintf(stderr, "Unexpected header field value in %s\n", filename);
    exit(1);
  }
  // Set properties.
  isSymmetric_ = streq(symmetry, "symmetric");
  // Make sure this is a general sparse matrix.
  if (strne(header, "%%matrixmarket") || strne(object, "matrix") ||
      strne(format, "coordinate") ||
      (strne(symmetry, "general") && !isSymmetric_)) {
    fprintf(stderr, "Cannot find a general sparse matrix in %s\n", filename);
    exit(1);
  }
  // Skip comments.
  while (true) {
    readLine();
    if (line[0] != '%')
      break;
  }
  // Next line contains M N NNZ.
  idata[0] = 2; // rank
  if (sscanf(line, "%" PRIu64 "%" PRIu64 "%" PRIu64 "\n", idata + 2, idata + 3,
             idata + 1) != 3) {
    fprintf(stderr, "Cannot find size in %s\n", filename);
    exit(1);
  }
}

/// Read the "extended" FROSTT header. Although not part of the documented
/// format, we assume that the file starts with optional comments followed
/// by two lines that define the rank, the number of nonzeros, and the
/// dimensions sizes (one per rank) of the sparse tensor.
void SparseTensorReader::readExtFROSTTHeader() {
  // Skip comments.
  while (true) {
    readLine();
    if (line[0] != '#')
      break;
  }
  // Next line contains RANK and NNZ.
  if (sscanf(line, "%" PRIu64 "%" PRIu64 "\n", idata, idata + 1) != 2) {
    fprintf(stderr, "Cannot find metadata in %s\n", filename);
    exit(1);
  }
  // Followed by a line with the dimension sizes (one per rank).
  for (uint64_t r = 0; r < idata[0]; r++) {
    if (fscanf(file, "%" PRIu64, idata + 2 + r) != 1) {
      fprintf(stderr, "Cannot find dimension size %s\n", filename);
      exit(1);
    }
  }
  readLine(); // end of line
  // The FROSTT format does not define the data type of the nonzero elements.
  valueKind_ = ValueKind::kUndefined;
}
