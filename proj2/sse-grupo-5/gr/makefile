
#SOURCE = simd_128.cpp
SOURCE = simd_256.cpp
TARGET = sse5

$(TARGET): $(SOURCE)
	#initicc
	icc $(SOURCE) -o $@ -O0 -lpapi -g

.PHONY: c

c:
	$(RM) *.csv
