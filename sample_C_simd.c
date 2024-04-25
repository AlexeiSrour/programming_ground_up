#include <immintrin.h>

int input_array[] = {0,1,2,3,4,5,6,7};

int main(int argc, char* argv[])
{
		__m256i vector = _mm256_load_si256((__m256i *)input_array);
		__m256i temp  = _mm256_shuffle_epi32(vector, 0b10110001);

		vector = _mm256_max_epi32(vector, temp);

		__m256i shuffle = _mm256_set_epi32(0,4,1,5,2,6,3,7);

		vector = _mm256_permutevar8x32_epi32(vector, shuffle);

		int final[4];
		_mm256_store_si256((__m256i *)final, vector);

		return final[0];
}
