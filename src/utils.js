import _ from 'lodash'

export default {
  debounce: _.debounce,

  prefixWithBase: function(path, base) {
    let bl = base.length;
    let pl = path.length;
    if (pl > bl && bl != 0 && path.substring(0, bl) == base)
    {
      return path;
    }
    return base + path;
  },

  /**
   * Use iterative binary search to find optimal content font size given 
   * a parent element's dimensions as constraints.
   */
  setOptimalFontSize: function(maxWidth, maxHeight, el, maxFontSize, minFontSize) {
    // Font size and container constraints
    maxFontSize = (!isNaN(maxFontSize) && typeof maxFontSize !== 'undefined' && maxFontSize > 4) ? maxFontSize : 200;
    let midSize = 0;

    // console.debug('optimalFontSize called maxHeight', maxHeight, ', maxWidth', maxWidth)

    // Binary search to find optimal font size
    while (maxFontSize > minFontSize + 1) {
      // calculate mid point of max and min font sizes
      midSize = Math.floor((maxFontSize - minFontSize) / 2) + minFontSize;
      // set el node font size to mid point
      el.style.fontSize = midSize + "px";

      // console.debug('  --', minFontSize, midSize, maxFontSize, 'el.offsetHeight', el.offsetHeight, 'el.offsetWidth', el.offsetWidth)

      // check if el node exceeds height constraint
      if (!(el.offsetHeight <= maxHeight && el.offsetWidth <= maxWidth)) {
        // continue search on smaller font sizes
        // console.debug('     -- set max to', midSize)
        maxFontSize = midSize;
      } else {
        // continue search on larger font sizes
        // console.debug('     -- set min to', midSize)
        minFontSize = midSize;
      }
    }

    // Set final font size
    // console.debug('  ==', minFontSize)
    el.style.fontSize = minFontSize + "px";
    return minFontSize
  }


}
