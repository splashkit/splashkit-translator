/**
 * @header new_lang2
 * @attribute group test
 */

#include <cstdint>

 namespace splashkit_lib
 {
    /**
     * Say yay!
     * @returns 10
     */
    int get_int();

    /**
     *
     * @attribute suffix with_initial_value
     * @param x [description]
     * @returns x
     */
    int get_int(int x);

    /**
     *
     * @param x [description]
     * @returns x
     */
    float get_float(float x);

    /**
     * [say_yay_double description];
     * @param x [description]
     * @returns x
     */
    double get_double(double x);

    /**
     * [say_yay_char description];
     * @param x [description]
     * @returns x
     */
    char get_char(char x);

    /**
     * [say_yay_bool description];
     * @param x [description]
     * @returns x
     */
    bool get_bool(bool x);

    /**
     * [say_yay_short description];
     * @param x [description]
     * @returns x
     */
    short get_short(short x);

    /**
     * [say_yay_long description];
     * @param x [description]
     * @returns x
     */
    int64_t get_long(int64_t x);

    /**
     * [say_yay_uint description];
     * @param x [description]
     * @returns x
     */
    unsigned int get_uint(unsigned int x);

    /**
     * [say_yay_ushort description];
     * @param x [description]
     * @returns x
     */
    unsigned short get_ushort(unsigned short x);

    /**
     * [say_yay_uchar description];
     * @param x [description]
     * @returns x
     */
    unsigned char get_uchar(unsigned char x);
}
