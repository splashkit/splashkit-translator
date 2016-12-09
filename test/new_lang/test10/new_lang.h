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
   * point
   * @field x desc
   * @field y desc
   */
  struct point {
    float x, y;
  };

  /**
   * @field points points
   */
  struct triangle {
    point points[3];
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

  /**
   * [get_triangle description]
   * @return [description]
   */
  triangle get_triangle();

  /**
   * [print_triangle description]
   * @param t [description]
   */
  void print_triangle(triangle t);

  /**
   * [update_triangle description]
   * @param t [description]
   */
  void update_triangle(triangle &t);

  /**
  * The free notifier can be registered with the system. It is called every
  * time a resource is freed.
  *
  * @param pointer   The pointer to the resource that is being freed.
  */
  typedef void (free_notifier)(void *pointer);

  /**
   * Register a function to be called when any resource is freed.
   *
   * @param fn The function to be called when a resource is freed.
   */
  void register_free_notifier(free_notifier *fn);

  /**
   * Remove the function from the list of functions receiving notification
   * of resource freeing.
   *
   * @param handler The function to remove
   */
  void deregister_free_notifier(free_notifier *handler);
}
