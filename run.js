async function run(wasm) {

  const compiled = await WebAssembly.compile(wasm);

  const obj = {
    console: {
      log: (i) => {
        console.log(i);
      },
    },
  };

  const instance = await WebAssembly.instantiate(compiled, obj);

  const mem = instance.exports.memory;
  const universe = new Uint8Array(mem.buffer);
  //universe[1] = 1;
  //universe[10] = 1;
  //universe[110] = 1;

  const WIDTH = 30;
  const HEIGHT = 30;

  instance.exports.init(WIDTH, HEIGHT);

  instance.exports.setCell(1, 2, 1);
  instance.exports.setCell(2, 3, 1);
  instance.exports.setCell(3, 1, 1);
  instance.exports.setCell(3, 2, 1);
  instance.exports.setCell(3, 3, 1);
  instance.exports.swapBuffers();

  setInterval(() => {
    render();
    instance.exports.tick();
  }, 200);
  //console.log(universe);

  function render() {
    const frontBufferOffset = instance.exports.getFrontBufferOffset();

    for (let i = 0; i < HEIGHT; i++) {
      let row = '';
      for (let j = 0; j < WIDTH; j++) {
        const cellIndex = frontBufferOffset + (i * WIDTH) + j;
        const cell = universe[cellIndex];
        row += cell === 0 ? '.' : 'O';
      }
      console.log(row);
    }
  }
}


export { run };
