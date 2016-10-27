/**
 * @header new_lang
 * @attribute group test
 */

namespace splashkit_lib
{
    /**
     * Test enum
     *
     * @constant FLAG_1   Flag 1
     * @constant FLAG_10  Flag 10
     */
    enum flag
    {
      FLAG_1 = 1,
      FLAG_10 = 10
    };

    /**
     * [get_vector description]
     * @return [description]
     */
    flag get_flag();

    /**
     * [print_vector description]
     * @param v [description]
     */
    void print_flag(flag v);
}
