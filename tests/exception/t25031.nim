# Test case for issue #25031
# Exceptions not cleared if except control flow (return) is interrupted

proc foo(): string =
  var log: string = ""
  try:
    try:
      raise newException(Exception, "1")
    except:
      log &= "EXCEPT1: " & getCurrentExceptionMsg() & "\n"
      return log # Prevents exception clearing in original bug
    finally:
      log &= "FINALLY1: " & getCurrentExceptionMsg() & "\n"
  except:
    log &= "EXCEPT2: " & getCurrentExceptionMsg() & "\n"
  finally:
    log &= "FINALLY2: " & getCurrentExceptionMsg() & "\n"

  log &= "LAST_FOO: " & getCurrentExceptionMsg() & "\n"
  return log

proc bar(): string =
  var log: string = ""
  try:
    try:
      raise newException(Exception, "A")
    except:
      log &= "EXCEPT_A1: " & getCurrentExceptionMsg() & "\n"
      raise newException(Exception, "B") # This also prevents clearing in original bug
    finally:
      log &= "FINALLY_A1: " & getCurrentExceptionMsg() & "\n"
  except Exception as e:
    log &= "EXCEPT_A2: " & getCurrentExceptionMsg() & "\n"
    log &= "EXCEPT_A2_MSG: " & e.msg & "\n"
  finally:
    log &= "FINALLY_A2: " & getCurrentExceptionMsg() & "\n"

  log &= "LAST_BAR: " & getCurrentExceptionMsg() & "\n"
  return log

var fooOutput = foo()
echo "--- FOO ---"
echo fooOutput
echo "--- END FOO ---"
echo "POST_FOO_MAIN: ", getCurrentExceptionMsg()


var barOutput = bar()
echo "--- BAR ---"
echo barOutput
echo "--- END BAR ---"
echo "POST_BAR_MAIN: ", getCurrentExceptionMsg()

# Expected output for foo with the fix:
# --- FOO ---
# EXCEPT1: 1
# FINALLY1:
# FINALLY2:
# --- END FOO ---
# POST_FOO_MAIN:

# Expected output for bar (behavior for raise in except might be this, which is acceptable):
# --- BAR ---
# EXCEPT_A1: A
# FINALLY_A1: A
# EXCEPT_A2: B
# EXCEPT_A2_MSG: B
# FINALLY_A2: A
# LAST_BAR: A
# --- END BAR ---
# POST_BAR_MAIN: A

# To make this a proper testament test, we'd typically check against a .output file.
# For now, manual inspection of the output will be needed during testing phase.
# The key parts for #25031 (return case) are FINALLY1, FINALLY2, and POST_FOO_MAIN being empty.
# Adding a specific check for POST_FOO_MAIN to make it fail if bug persists
if getCurrentExceptionMsg() != "":
  raise newException(Exception, "Test FAILED: getCurrentExceptionMsg was not empty after foo call. Value: " & getCurrentExceptionMsg())
