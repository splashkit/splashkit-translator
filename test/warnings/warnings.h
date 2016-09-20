/**
 * @header Test
 *
 * File header...
 */

/**
 *
 */
void should_warn_about_missing_param(int param);

/**
 * Also warn about overload...
 *
 * @param param_a Param a desc!
 */
void should_warn_about_missing_param(int param_a, int other);

/**
 * [should_warn_about_return description]
 */
int should_warn_about_return();

/**
 * @param happy
 */
void extra_param();

/**
 * @return extr
 */
void extra_return();

/**
 * The enum decl
 *
 * @constant A  Test A
 * @fred
 */
enum Test
{
  A,
  B
}
