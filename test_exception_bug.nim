proc foo() =
  try:
    try:
      raise newException(Exception, "1")
    except:
      echo "EXCEPT1: ", getCurrentExceptionMsg()
      return # Prevents exception clearing
      # raise newException(Exception, "2") # also prevents clearing
    finally:
      echo "FINALLY1: ", getCurrentExceptionMsg()
  except:
    echo "EXCEPT2: ", getCurrentExceptionMsg()
  finally:
    echo "FINALLY2: ", getCurrentExceptionMsg()

  echo "LAST: ", getCurrentExceptionMsg()

foo()
