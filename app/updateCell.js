if(this.Conway == null) {
  this.Conway = {}
}
this.Conway.updateCell = function(cell) {
  cell.document.state = (function() {
    var neighbors = cell.neighbors({
      state: 'on'
    }).fetch();

    switch (neighbors.length) {
      // Fill me in
    }
  })();
  return cell;
};
