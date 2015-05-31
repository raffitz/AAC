
#SOURCE = simd_128.cpp
SOURCE = simd_256.cpp
TARGET = sse5

$(TARGET): $(SOURCE)
	#initicc
	icc $(SOURCE) -o $@ -O0 -lpapi

.PHONY: c

c:
	$(RM) *.csv
