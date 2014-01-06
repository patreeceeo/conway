if(this.Conway == null) {
  this.Conway = {}
}
this.Conway.updateCell = function(cell) {
  cell.document.state = (function() {
    var neighbors = cell.neighbors({
      state: 'on'
    }).fetch();

    switch (neighbors.length) {
      case 0:
      case 1:
        return 'off';
      case 2:
        return cell.document.state;
      case 3:
        return 'on';
      default:
        return 'off';
    }
  })();
  return cell;
};
