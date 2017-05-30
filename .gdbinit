set disassembly-flavor intel
define hook-stop
  echo CODE:\n
  x/15i ($eip-5)
  echo \n\nSTACK:\n
  x/48x $esp
end

