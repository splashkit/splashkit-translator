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
    double values[9];
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
    double x, y;
  };

  /**
   * @field my_points points
   */
  struct triangle {
    point my_points[3];
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

}
