if(this.Conway == null) {
  this.Conway = {}
}
this.Conway.getNextCellState = function(cell, opinions) {
  liveNeighbors = opinions.liveNeighbors;

  switch (liveNeighbors.length) {
    case 0:
    case 1:
      return 'off';
    case 2:
      return cell.state;
    case 3:
      return 'on';
    default:
      return 'off';
  }
};
