/**
 * @header new_lang
 * @attribute group test
 */

namespace splashkit_lib
{
  /**
   * [int  description]
   * @field value description
   */
  struct a_struct {
    int value;
  };

  /**
   * Description
   */
  typedef struct a_struct *struct_ptr;

  /**
   * [print_vector description]
   * @param v [description]
   */
  void update_struct(struct_ptr v);
}
