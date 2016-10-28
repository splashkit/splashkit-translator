/**
 * @header new_lang
 * @attribute group test
 */

namespace splashkit_lib
{
  /**
   * [int  description]
   * @field values description
   */
  struct array_1d {
    int values[2];
  };

  /**
   * [int  description]
   * @field values description
   */
  struct array_2d {
    int values[2][3];
  };

  /**
   * [print_vector description]
   * @param v [description]
   */
  void update_1d(array_1d &v);

  /**
   * [print_vector description]
   * @param v [description]
   */
  void update_2d(array_2d &v);
}
