if(this.Conway == null) {
  this.Conway = {}
}
this.Conway.updateCell = function(cell) {
  var newState = (function() {
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
  retval = {
    changed: cell.document.state != newState
  };
  cell.document.state = newState;
  return retval;
};
