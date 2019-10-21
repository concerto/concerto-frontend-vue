<template>
  <div class="concerto-graphic" :style="myStyle"/>
</template>

<script>
  /* eslint no-console: 0 */

  import utils from '../utils'

  export default {
    name: 'ConcertoGraphic',
    props: {
      content: Object
    },

    computed: {
      myStyle: function () {
        let style = ''
        let url =  utils.prefixWithBase(this.content.path, this.content.baseUrl)
        style = "background-image: url('" + url + "');" + (this.content.style || '')
        return style
      },
    },
  }
</script>

<style>
  .concerto-graphic {
    display: block;
    position: absolute;
    margin: auto;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-size: contain;
    background-repeat: no-repeat;
    background-position: center;
  }
</style>
