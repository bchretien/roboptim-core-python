
# Check roboptim-py internal API.
ADD_TEST(wrap "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/wrap.py")

# Check high-level API.
ADD_TEST(function
  "${PYTHON_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/function.py")
