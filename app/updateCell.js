if(this.Conway == null) {
  this.Conway = {}
}
this.Conway.getNextCellState = function(cell, opinions) {
  var liveNeighbors = opinions.liveNeighbors;
  var frequencyTable = {
      e: 12.02,
      t: 9.10,
      a: 8.12,
      o: 7.68,
      i: 7.31,
      n: 6.95,
      s: 6.28,
      r: 6.02,
      h: 5.92,
      d: 4.32,
      l: 3.98,
      u: 2.88,
      c: 2.71,
      m: 2.61,
      f: 2.30,
      y: 2.11,
      w: 2.09,
      g: 2.03,
      p: 1.82,
      b: 1.49,
      v: 1.11,
      k: 0.69,
      x: 0.17,
      q: 0.11,
      j: 0.10,
      z: 0.07
    };
  var getRandomSymbol = function() {
    var dart, frequency, letter, old_total, total, _ref;
    dart = Math.random() * 100;
    total = old_total = 0;
    _ref = frequencyTable;
    for (letter in _ref) {
      frequency = _ref[letter];
      total += frequency * 0.37;
      if ((old_total < dart && dart < total)) {
        return letter;
      }
      old_total = total;
    }
    return ' ';
  };

  switch (liveNeighbors.length) {
    case 0:
    case 1:
      return {alive: false, stage: 1, symbol: cell.state.symbol};
    case 2:
      return {alive: cell.state.alive, stage: 1, symbol: cell.state.symbol, showSymbol: true};
    case 3:
      return {alive: true, stage: 2, symbol: getRandomSymbol(), showSymbol: true};
    default:
      return {alive: false, stage: 2, symbol: cell.state.symbol, showSymbol: true};
  }
};
