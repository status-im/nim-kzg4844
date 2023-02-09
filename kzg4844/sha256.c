/*
 * Single-short SHA-256 hash function.
 */
#include "csources/blst/src/sha256.h"

void blst_sha256(unsigned char md[32], const void *msg, size_t len)
{
    SHA256_CTX ctx;

    sha256_init(&ctx);
    sha256_update(&ctx, msg, len);
    sha256_final(md, &ctx);
}
