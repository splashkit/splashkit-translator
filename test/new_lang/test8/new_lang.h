/**
 * @header new_lang
 * @attribute group test
 */

namespace splashkit_lib
{
  /**
   * [int  description]
   * @param  num [description]
   * @return           [description]
   */
  typedef int (func_name)(int num);

  /**
   * [int  description]
   * @param  num [description]
   */
  typedef void (proc_name)(int num);

  /**
   * [print_vector description]
   * @param v [description]
   */
  void run_func(func_name *v);

  /**
   * [print_vector description]
   * @param v [description]
   */
  void run_proc(proc_name *v);
}
