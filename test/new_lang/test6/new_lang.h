/**
 * @header new_lang6
 * @attribute group test
 */

namespace splashkit_lib
{
    /**
     * @field x
     * @field y
     */
    struct vector_2d
    {
      float x, y;
      int multi_name;
      bool mapped;
    };

    /**
     * [get_vector description]
     * @return [description]
     */
    vector_2d get_vector();

    /**
     * [print_vector description]
     * @param v [description]
     */
    void print_vector(const vector_2d &v);
}
