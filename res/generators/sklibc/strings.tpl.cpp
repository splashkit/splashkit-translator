typedef struct { char *string; int size; } __sklib_string;
__sklib_string __to_sklib_string(std::string s)
{
  __sklib_string result;
  result.size = s.length();
  result.string = (char *)malloc(result.size + 1);
  strcpy(result.string, s.c_str());
  return result;
}
void __sklib_free_sklib_string(__sklib_string s)
{
  free(s.string);
}
std::string __to_string(__sklib_string s)
{
  return std::string(s.string);
}
