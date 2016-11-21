/**
 * @header new_lang
 * @attribute group test
 */

namespace splashkit_lib
{
    /**
     * Test enum
     *
     * @constant OPTION_1 First option
     * @constant OPTION_2 Second option... out of sync
     * @constant A_OPTION Last option
     */
    enum basic_flag
    {
      OPTION_1,
      OPTION_2 = 3,
      A_OPTION
    };

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
     *
     * @return [description]
     */
    basic_flag get_basic_flag();

    /**
     * Desc
     * @param bf [description]
     */
    void print_basic_flag(basic_flag bf);

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
