(module
  (import "console" "log" (func $log (param i32)))

  (memory (export "memory") 1)

  (global $width (mut i32) (i32.const 0))
  (global $height (mut i32) (i32.const 0))
  (global $frontBufferIndex (mut i32) (i32.const 0))
  (global $backBufferIndex (mut i32) (i32.const 1))

  (func $init (param $w i32) (param $h i32)
    local.get $w
    global.set $width

    local.get $h
    global.set $height)

  (func $getFrontBufferOffset (result i32)
    (local $bufSize i32)
    (local $bufOffset i32)
    (local.set $bufSize (i32.mul (global.get $width) (global.get $height)))
    (local.set $bufOffset (i32.mul
      (global.get $frontBufferIndex)
      (local.get $bufSize)))
    (local.get $bufOffset))

  (func $tick
    (local $i i32)
    (local $j i32)
    (local.set $i (i32.const 0))

    (loop $rowLoop
      ;;(call $log (i32.const 1111111))
      ;;(call $log (local.get $i))
      (local.set $j (i32.const 0))
      (loop $colLoop
        ;;(call $log (i32.const 2222222))
        ;;(call $log (local.get $j))
        (call $updateCell (local.get $i) (local.get $j))
        (br_if $colLoop
          (i32.lt_s
            (local.tee $j (i32.add (local.get $j) (i32.const 1)))
            (global.get $width))))
      (br_if $rowLoop
        (i32.lt_s
          (local.tee $i (i32.add (local.get $i) (i32.const 1)))
          (global.get $height))))
    (call $swapBuffers))

  (func $swapBuffers
    (local $temp i32)
    
    (local.set $temp (global.get $frontBufferIndex))
    (global.set $frontBufferIndex (global.get $backBufferIndex))
    (global.set $backBufferIndex (local.get $temp)))

  (func $updateCell (param $row i32) (param $col i32)

    (local $curVal i32)
    (local $numLive i32)
    (local.set $numLive (i32.const 0))

    ;; northwest
    (local.set $numLive
      (i32.add (local.get $numLive)
      (call $getCell
        (i32.sub (local.get $row) (i32.const 1))
        (i32.sub (local.get $col) (i32.const 1)))))
    ;; north
    (local.set $numLive
      (i32.add (local.get $numLive)
      (call $getCell
        (i32.sub (local.get $row) (i32.const 1))
        (local.get $col))))
    ;; northeast
    (local.set $numLive
      (i32.add (local.get $numLive)
      (call $getCell
        (i32.sub (local.get $row) (i32.const 1))
        (i32.add (local.get $col) (i32.const 1)))))
    ;; east
    (local.set $numLive
      (i32.add (local.get $numLive)
      (call $getCell
        (local.get $row)
        (i32.add (local.get $col) (i32.const 1)))))
    ;; southeast
    (local.set $numLive
      (i32.add 
        (local.get $numLive)
        (call $getCell
          (i32.add (local.get $row) (i32.const 1))
          (i32.add (local.get $col) (i32.const 1)))))
    ;; south
    (local.set $numLive
      (i32.add 
        (local.get $numLive)
        (call $getCell
          (i32.add (local.get $row) (i32.const 1))
          (local.get $col))))
    ;; southwest
    (local.set $numLive
      (i32.add 
        (local.get $numLive)
        (call $getCell
          (i32.add (local.get $row) (i32.const 1))
          (i32.sub (local.get $col) (i32.const 1)))))
    ;; west
    (local.set $numLive
      (i32.add 
        (local.get $numLive)
        (call $getCell
          (local.get $row)
          (i32.sub (local.get $col) (i32.const 1)))))

    ;;(call $log (local.get $numLive))

    (local.set $curVal (call $getCell (local.get $row) (local.get $col)))
    ;;(call $log (local.get $curVal))

    (if (i32.eq (i32.const 0) (local.get $curVal))
      (then
        (if (i32.eq (i32.const 3) (local.get $numLive))
          (then
            (call $setCell (local.get $row) (local.get $col) (i32.const 1)))
          (else
            (call $setCell (local.get $row) (local.get $col) (i32.const 0)))))
      (else
        (call $setCell (local.get $row) (local.get $col) (i32.const 0))
        (if (i32.eq (local.get $numLive) (i32.const 2))
          (then
            (call $setCell (local.get $row) (local.get $col) (i32.const 1))))
        (if (i32.eq (local.get $numLive) (i32.const 3))
          (then
            (call $setCell (local.get $row) (local.get $col) (i32.const 1))))))
    
    )

  (func $getCell (param $row i32) (param $col i32) (result i32)
    (local $bufSize i32)
    (local $bufOffset i32)
    (local $rowOffset i32)
    (local $cellOffset i32)

    (if (i32.lt_s (local.get $row) (i32.const 0))
      (then
        (return (i32.const 0))))
    (if (i32.lt_s (local.get $col) (i32.const 0))
      (then
        (return (i32.const 0))))

    (local.set $bufSize (i32.mul (global.get $width) (global.get $height)))
    (local.set $bufOffset (i32.mul
      (global.get $backBufferIndex)
      (local.get $bufSize)))
    (local.set $rowOffset (i32.add
      (local.get $bufOffset)
      (i32.mul
        (local.get $row)
        (global.get $width))))
    (local.set $cellOffset (i32.add
      (local.get $rowOffset)
      (local.get $col)))

    (return (i32.load8_u (local.get $cellOffset))))

  (func $setCell (param $row i32) (param $col i32) (param $val i32)
    (local $bufSize i32)
    (local $bufOffset i32)
    (local $rowOffset i32)
    (local $cellOffset i32)

    (if (i32.lt_s (local.get $row) (i32.const 0))
      (then
        (return)))
    (if (i32.lt_s (local.get $col) (i32.const 0))
      (then
        (return)))

    (local.set $bufSize (i32.mul (global.get $width) (global.get $height)))
    (local.set $bufOffset (i32.mul
      (global.get $frontBufferIndex)
      (local.get $bufSize)))
    (local.set $rowOffset (i32.add
      (local.get $bufOffset)
      (i32.mul
        (local.get $row)
        (global.get $width))))
    (local.set $cellOffset (i32.add
      (local.get $rowOffset)
      (local.get $col)))

    ;;(call $log (local.get $cellOffset))

    (return (i32.store8 (local.get $cellOffset) (local.get $val))))

  (export "init" (func $init))
  (export "tick" (func $tick))
  (export "getFrontBufferOffset" (func $getFrontBufferOffset))
  (export "swapBuffers" (func $swapBuffers))
  (export "setCell" (func $setCell))
)
